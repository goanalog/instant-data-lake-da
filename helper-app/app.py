import os
import json
import logging
from flask import Flask, render_template, jsonify
from ibm_secrets_manager_sdk.secrets_manager_v2 import SecretsManagerV2
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
# ibm_db requires DB2 drivers to be installed separately
# Ensure your Dockerfile handles this installation
try:
    import ibm_db
except ImportError:
    print("-------------------------------------------------------------------------")
    print("ERROR: ibm_db module not found.")
    print("Ensure IBM Db2 drivers and the ibm_db Python package are installed.")
    print("Refer to https://github.com/ibmdb/python-ibmdb for installation instructions.")
    print("-------------------------------------------------------------------------")
    # Allow app to start but DB operations will fail
    ibm_db = None

app = Flask(__name__)

# --- Configuration (Pulled from Environment Variables) ---
db2_hostname = os.environ.get('DB2_HOSTNAME')
db2_port = os.environ.get('DB2_PORT')
db2_database = os.environ.get('DB2_DATABASE', 'BLUDB')
db2_protocol = os.environ.get('DB2_PROTOCOL', 'TCPIP')
db2_uid = os.environ.get('DB2_UID', 'iamuser') # Using IAM authentication
db2_pwd_secret_crn = os.environ.get('DB2_PWD_SECRET_CRN') # CRN of the API key secret
secrets_manager_url = os.environ.get('SECRETS_MANAGER_URL') # Endpoint URL for Secrets Manager
public_sample_data_url_base = os.environ.get('PUBLIC_SAMPLE_DATA_URL_BASE') # e.g., cos://us-east/your-public-bucket

# --- NEW: User Resource Info ---
user_cos_bucket_name = os.environ.get('USER_COS_BUCKET_NAME', '#N/A#')
user_cos_bucket_url = os.environ.get('USER_COS_BUCKET_URL', '#')
user_db2_console_url = os.environ.get('USER_DB2_CONSOLE_URL', '#')
user_helper_app_console_url = os.environ.get('USER_HELPER_APP_CONSOLE_URL', '#')
user_secrets_manager_url = os.environ.get('USER_SECRETS_MANAGER_URL', '#')
deployed_region = os.environ.get('DEPLOYED_REGION', '#N/A#')

# --- Global Variables ---
db2_api_key = None # Will be fetched from Secrets Manager
db2_conn = None # Global connection object

# --- Logging ---
logging.basicConfig(level=logging.INFO)

# --- Helper Functions ---

def get_db2_api_key():
    """Fetches the Db2 API Key from IBM Cloud Secrets Manager."""
    global db2_api_key
    if db2_api_key:
        return db2_api_key

    if not db2_pwd_secret_crn or not secrets_manager_url:
        logging.error("Secrets Manager CRN or URL not configured.")
        return None

    try:
        # Authenticate using the SDK's default authenticator (reads env vars like IBMCLOUD_API_KEY if needed for SM access itself)
        # or bind credentials if running in Code Engine with binding
        authenticator = IAMAuthenticator(os.environ.get("IBMCLOUD_API_KEY", "")) # Fallback, assumes env var or CE binding provides access TO Secrets Manager
        secrets_manager = SecretsManagerV2(authenticator=authenticator)
        secrets_manager.set_service_url(secrets_manager_url)

        # Parse CRN to get Secret ID
        # Example CRN: crn:v1:bluemix:public:secrets-manager:us-south:a/accountid:instanceid:secret:secretid
        parts = db2_pwd_secret_crn.split(':')
        if len(parts) < 9 or parts[7] != 'secret':
             raise ValueError(f"Invalid Secret CRN format: {db2_pwd_secret_crn}")
        secret_id = parts[8]

        logging.info(f"Attempting to get secret by ID: {secret_id}")
        response = secrets_manager.get_secret(
            secret_type='arbitrary', # Assuming API key stored as arbitrary
            id=secret_id
        )
        secret_data = response.get_result()
        api_key_value = secret_data.get('secret_data', {}).get('payload') # Adjust if stored differently

        if not api_key_value:
             raise ValueError("API Key not found in secret payload.")

        db2_api_key = api_key_value
        logging.info("Successfully retrieved Db2 API Key from Secrets Manager.")
        return db2_api_key

    except Exception as e:
        logging.error(f"Error fetching secret from Secrets Manager: {e}")
        return None

def get_db2_connection():
    """Establishes or returns the existing Db2 connection."""
    global db2_conn
    if db2_conn:
        try:
            # Check if connection is still active
            stmt = ibm_db.active(db2_conn)
            if stmt: # Note: active returns statement handle if active, False otherwise
               logging.info("Reusing existing Db2 connection.")
               return db2_conn
        except Exception as e:
            logging.warning(f"Existing connection check failed: {e}. Reconnecting.")
            db2_conn = None # Force reconnect

    if not ibm_db:
        logging.error("ibm_db module not loaded. Cannot connect to Db2.")
        return None

    api_key = get_db2_api_key()
    if not api_key:
        logging.error("Could not retrieve API Key for Db2 connection.")
        return None

    if not all([db2_hostname, db2_port, db2_database]):
        logging.error("Db2 connection details (hostname, port, database) missing.")
        return None

    # Construct the connection string for IAM (API Key) authentication
    conn_string = (
        f"DATABASE={db2_database};"
        f"HOSTNAME={db2_hostname};"
        f"PORT={db2_port};"
        f"PROTOCOL={db2_protocol};"
        f"UID={db2_uid};"
        f"PWD={api_key};"
        f"SECURITY=SSL;" # Db2 Warehouse on Cloud requires SSL
        f"AUTHENTICATION=GSS_PLUGIN;" # Use GSS_PLUGIN for IAM
        f"PLUGINNAME=IBMIAMauth;" # Specify the IAM plugin
        f"SSLServerCertificate=/opt/ibm/db2/ssl_keystore/DigiCertGlobalRootCA.arm;" # Default path in many IBM containers
    )

    try:
        logging.info(f"Attempting to connect to Db2: {db2_hostname}:{db2_port}, Database: {db2_database}")
        db2_conn = ibm_db.connect(conn_string, "", "")
        logging.info("Successfully connected to Db2.")
        return db2_conn
    except Exception as e:
        logging.error(f"Db2 connection failed: {e}")
        db2_conn = None
        return None

def execute_sql(sql_command):
    """Executes a SQL command against the Db2 database."""
    conn = get_db2_connection()
    if not conn:
        return False, "Database connection failed."

    try:
        logging.info(f"Executing SQL: {sql_command[:100]}...") # Log truncated SQL
        stmt = ibm_db.exec_immediate(conn, sql_command)
        logging.info("SQL command executed successfully.")
        # For non-SELECT statements, stmt is usually True or a statement handle
        # ibm_db.num_rows might not be reliable for non-SELECT in all cases
        # We assume success if no exception is raised for CREATE/INSERT etc.
        return True, "Command executed successfully."
    except Exception as e:
        error_msg = f"SQL execution error: {e}"
        logging.error(error_msg)
        return False, error_msg

def fetch_sql_results(sql_query):
    """Executes a SELECT SQL query and fetches results."""
    conn = get_db2_connection()
    if not conn:
        return None, "Database connection failed."

    results = []
    try:
        logging.info(f"Fetching SQL: {sql_query[:100]}...") # Log truncated SQL
        stmt = ibm_db.exec_immediate(conn, sql_query)

        # Get column names
        column_names = []
        num_fields = ibm_db.num_fields(stmt)
        if num_fields > 0:
             for i in range(num_fields):
                 column_names.append(ibm_db.field_name(stmt, i))

             # Fetch rows
             row = ibm_db.fetch_assoc(stmt)
             while row:
                 # Process row values (handle potential non-JSON serializable types like dates if necessary)
                 processed_row = {col: str(row[col]) if row[col] is not None else None for col in column_names}
                 results.append(processed_row)
                 row = ibm_db.fetch_assoc(stmt)

        ibm_db.free_result(stmt) # Important to free resources
        logging.info(f"SQL query fetched {len(results)} rows.")
        return results, "Query executed successfully."

    except Exception as e:
        error_msg = f"SQL query error: {e}"
        logging.error(error_msg)
        return None, error_msg


# --- Flask Routes ---

@app.route('/')
def index():
    """Serves the main HTML page, passing resource info."""
    resource_links = {
        "cos_bucket_name": user_cos_bucket_name,
        "cos_bucket_url": user_cos_bucket_url,
        "db2_console_url": user_db2_console_url,
        "helper_app_console_url": user_helper_app_console_url,
        "secrets_manager_url": user_secrets_manager_url,
        "region": deployed_region
    }
    # Pass the dictionary to the template under the key 'links'
    return render_template('index.html', links=resource_links)

@app.route('/setup', methods=['POST'])
def setup_table():
    """API endpoint to run the CREATE EXTERNAL TABLE command."""
    if not public_sample_data_url_base:
        return jsonify({"status": "Error", "message": "Public sample data URL base not configured."}), 400

    # IMPORTANT: Ensure column definitions EXACTLY match customers.csv
    # This should be validated or ideally dynamically generated if schema varies
    create_sql = f"""
    CREATE EXTERNAL TABLE SAMPLE_CUSTOMERS (
        CustomerID INT, FirstName VARCHAR(50), LastName VARCHAR(50), Company VARCHAR(100),
        City VARCHAR(50), Country VARCHAR(50), Phone1 VARCHAR(30), Phone2 VARCHAR(30),
        Email VARCHAR(100), SubscriptionDate DATE, Website VARCHAR(100)
    ) USING (
        DATAOBJECT('{public_sample_data_url_base}/customers.csv')
        FORMAT CSV
        DELIMITER ','
        QUOTE '"'
        SKIPHEADER 1
        LOGERRORS TRUE
        REMOTESOURCE 'COS'
        CTRLCHARS TRUE
    )
    """
    # Check if table already exists first to make endpoint idempotent
    check_sql = "SELECT 1 FROM SYSCAT.TABLES WHERE TABSCHEMA = CURRENT SCHEMA AND TABNAME = 'SAMPLE_CUSTOMERS'"
    try:
        conn = get_db2_connection()
        if not conn: raise ConnectionError("Failed to connect to Db2")
        stmt_check = ibm_db.exec_immediate(conn, check_sql)
        exists = ibm_db.fetch_tuple(stmt_check)
        ibm_db.free_result(stmt_check)
        if exists:
            logging.info("Table SAMPLE_CUSTOMERS already exists. Skipping creation.")
            return jsonify({"status": "OK", "message": "Sample table link already exists."})
    except Exception as e:
         # Table might not exist, that's okay, proceed with CREATE
         if "SQLCODE=-204" in str(e): # Specific Db2 code for 'object not found'
             logging.info("Table SAMPLE_CUSTOMERS does not exist yet. Proceeding with creation.")
         else:
             logging.warning(f"Error checking if table exists (will attempt create anyway): {e}")
             # Optionally return error if check fails unexpectedly:
             # return jsonify({"status": "Error", "message": f"Failed to check table existence: {e}"}), 500


    # Proceed with CREATE TABLE
    success, message = execute_sql(create_sql)
    if success:
        return jsonify({"status": "OK", "message": "Sample table link created successfully!"})
    else:
        # Check for specific "already exists" error (though the check above should handle it)
        if "SQLCODE=-601" in message: # Specific Db2 code for 'object already exists'
             logging.warning("CREATE TABLE failed because table already exists (check succeeded).")
             return jsonify({"status": "OK", "message": "Sample table link already exists."})
        return jsonify({"status": "Error", "message": message}), 500


@app.route('/query', methods=['POST'])
def query_data():
    """API endpoint to run the sample SELECT query."""
    select_sql = "SELECT CustomerID, FirstName, LastName, Country FROM SAMPLE_CUSTOMERS WHERE Country = 'USA' LIMIT 10"

    results, message = fetch_sql_results(select_sql)
    if results is not None:
        return jsonify({"status": "OK", "message": "Query successful!", "data": results})
    else:
        # Check if the error is "table not found"
        if "SQLCODE=-204" in message: # Specific Db2 code for 'object not found'
             return jsonify({"status": "Error", "message": "Sample table not found. Please click 'Prepare Sample Data Table' first."}), 400
        return jsonify({"status": "Error", "message": message}), 500


if __name__ == '__main__':
    # Fetch API key on startup
    get_db2_api_key()
    # Port needs to be 8080 for Code Engine by default unless overridden
    port = int(os.environ.get('PORT', 8080))
    # Run on 0.0.0.0 to be accessible within Code Engine
    app.run(host='0.0.0.0', port=port)


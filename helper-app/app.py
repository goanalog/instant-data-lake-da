import os
import json
import logging
from flask import Flask, render_template, jsonify
from ibm_secrets_manager_sdk.secrets_manager_v2 import SecretsManagerV2
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator, VpcInstanceAuthenticator, ContainerAuthenticator
# ibm_db requires DB2 drivers to be installed separately
# Ensure your Dockerfile handles this installation
try:
    import ibm_db
    IBM_DB_LOADED = True
except ImportError:
    print("-------------------------------------------------------------------------", flush=True)
    print("ERROR: ibm_db module not found.", flush=True)
    print("Ensure IBM Db2 drivers and the ibm_db Python package are installed in the container image.", flush=True)
    print("Refer to https://github.com/ibmdb/python-ibmdb for installation instructions.", flush=True)
    print("-------------------------------------------------------------------------", flush=True)
    # Allow app to start but DB operations will fail
    ibm_db = None
    IBM_DB_LOADED = False

app = Flask(__name__)

# --- Configuration (Pulled from Environment Variables) ---
db2_hostname = os.environ.get('DB2_HOSTNAME')
db2_port = os.environ.get('DB2_PORT')
db2_database = os.environ.get('DB2_DATABASE', 'BLUDB')
db2_protocol = os.environ.get('DB2_PROTOCOL', 'TCPIP')
db2_uid = os.environ.get('DB2_UID', 'iamuser') # Using IAM authentication
db2_pwd_secret_crn = os.environ.get('DB2_PWD_SECRET_CRN') # CRN of the API key secret

# Secrets Manager URL: Prioritize binding, fallback to Terraform-provided URL
secrets_manager_url = os.environ.get('BINDING_SECRETS_MANAGER_URL', os.environ.get('SECRETS_MANAGER_URL'))

public_sample_data_url_base = os.environ.get('PUBLIC_SAMPLE_DATA_URL_BASE') # e.g., cos://us-east/your-public-bucket

# --- User Resource Info ---
user_cos_bucket_name = os.environ.get('USER_COS_BUCKET_NAME', '#N/A#')
user_cos_bucket_url = os.environ.get('USER_COS_BUCKET_URL', '#')
user_db2_console_url = os.environ.get('USER_DB2_CONSOLE_URL', '#')
user_helper_app_console_url = os.environ.get('USER_HELPER_APP_CONSOLE_URL', '#')
user_secrets_manager_url = os.environ.get('USER_SECRETS_MANAGER_URL', '#') # Link to SM instance UI
deployed_region = os.environ.get('DEPLOYED_REGION', '#N/A#')

# --- Global Variables ---
db2_api_key = None # Will be fetched from Secrets Manager
db2_conn = None # Global connection object

# --- Logging ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# --- Helper Functions ---

def get_secrets_manager_authenticator():
    """ Determines the best authenticator for Secrets Manager based on env vars """
    # Priority 1: Use Code Engine binding API Key if present
    binding_apikey = os.environ.get('BINDING_SECRETS_MANAGER_APIKEY')
    if binding_apikey:
        logging.info("Using Code Engine binding API key for Secrets Manager authentication.")
        return IAMAuthenticator(binding_apikey)

    # Priority 2: Use generic IBMCLOUD_API_KEY if present (less ideal)
    generic_apikey = os.environ.get('IBMCLOUD_API_KEY')
    if generic_apikey:
        logging.warning("Using IBMCLOUD_API_KEY for Secrets Manager authentication (fallback).")
        return IAMAuthenticator(generic_apikey)

    # Add other authenticators if relevant for other environments (VPC, Container)
    # authenticator = VpcInstanceAuthenticator(...)
    # authenticator = ContainerAuthenticator(...)

    logging.error("No suitable authenticator found for Secrets Manager.")
    return None


def get_db2_api_key():
    """Fetches the Db2 API Key from IBM Cloud Secrets Manager."""
    global db2_api_key
    if db2_api_key:
        return db2_api_key

    if not db2_pwd_secret_crn or not secrets_manager_url:
        logging.error("Secrets Manager CRN or URL not configured via environment variables.")
        return None

    authenticator = get_secrets_manager_authenticator()
    if not authenticator:
        logging.error("Failed to create Secrets Manager authenticator.")
        return None

    try:
        secrets_manager = SecretsManagerV2(authenticator=authenticator)
        secrets_manager.set_service_url(secrets_manager_url)

        # Parse CRN to get Secret ID
        parts = db2_pwd_secret_crn.split(':')
        if len(parts) < 9 or parts[7] != 'secret':
             logging.error(f"Invalid Secret CRN format received: {db2_pwd_secret_crn}")
             raise ValueError(f"Invalid Secret CRN format")
        secret_id = parts[8]

        logging.info(f"Attempting to get secret by ID: {secret_id} from {secrets_manager_url}")
        response = secrets_manager.get_secret(
            secret_type='arbitrary', # Assuming API key stored as arbitrary
            id=secret_id
        )
        secret_data = response.get_result()

        # Check structure carefully based on how Terraform stores the API key secret
        # Adjust 'payload' if using iam_credentials type secret or different structure
        api_key_value = secret_data.get('secret_data', {}).get('payload')
        if not api_key_value:
             # Try common structure for 'iam_credentials' type secrets
             api_key_value = secret_data.get('secret_data', {}).get('apikey')

        if not api_key_value:
             logging.error("API Key not found in secret payload. Structure might be unexpected.")
             raise ValueError("API Key not found in secret payload.")

        db2_api_key = api_key_value
        logging.info("Successfully retrieved Db2 API Key from Secrets Manager.")
        return db2_api_key

    except ApiException as e:
        logging.error(f"Secrets Manager API error fetching secret: {e.code} - {e.message}")
        return None
    except Exception as e:
        logging.error(f"Unexpected error fetching secret from Secrets Manager: {e}")
        return None

def get_db2_connection():
    """Establishes or returns the existing Db2 connection."""
    global db2_conn
    if db2_conn:
        try:
            # Check if connection is still active - simple check
            ibm_db.active(db2_conn)
            # A more robust check might involve executing a simple query like "SELECT 1 FROM SYSIBM.SYSDUMMY1"
            logging.info("Reusing existing Db2 connection.")
            return db2_conn
        except Exception as e:
            logging.warning(f"Existing connection check failed or connection lost: {e}. Reconnecting.")
            try:
                ibm_db.close(db2_conn) # Attempt to close gracefully
            except:
                pass # Ignore errors during close
            db2_conn = None # Force reconnect

    # Check if ibm_db loaded successfully at startup
    if not IBM_DB_LOADED or not ibm_db:
        logging.error("ibm_db module not loaded. Cannot connect to Db2.")
        return None

    api_key = get_db2_api_key()
    if not api_key:
        # Error logged in get_db2_api_key()
        return None

    if not all([db2_hostname, db2_port, db2_database]):
        logging.error("Db2 connection details (hostname, port, database) missing in environment variables.")
        return None

    # Default SSL Cert path - maybe make this configurable via env var if needed
    ssl_cert_path = "/opt/ibm/db2/ssl_keystore/DigiCertGlobalRootCA.arm"
    # Fallback/alternative path sometimes seen
    if not os.path.exists(ssl_cert_path):
        ssl_cert_path_alt = "/certs/db2_ssl/DigiCertGlobalRootCA.arm" # Adjust if your Dockerfile puts it elsewhere
        if os.path.exists(ssl_cert_path_alt):
            ssl_cert_path = ssl_cert_path_alt
        else:
             logging.warning(f"Default SSL Cert path not found: {ssl_cert_path}. Connection might fail if system trust store isn't sufficient.")
             # Optionally remove the SSLServerCertificate param if path not found, relying on system trust? Risky.
             # Or hard fail here if cert is mandatory. For now, we'll try without it specified.
             # ssl_cert_param = "" # Option to remove it
             ssl_cert_param = f"SSLServerCertificate={ssl_cert_path};" # Keep trying default path

    conn_string = (
        f"DATABASE={db2_database};"
        f"HOSTNAME={db2_hostname};"
        f"PORT={db2_port};"
        f"PROTOCOL={db2_protocol};"
        f"UID={db2_uid};"
        f"PWD={api_key};"
        f"SECURITY=SSL;" # Db2 Warehouse on Cloud requires SSL
        f"AUTHENTICATION=GSS_PLUGIN;"
        f"PLUGINNAME=IBMIAMauth;"
        # f"SSLServerCertificate={ssl_cert_path};" # Make conditional or ensure path exists
        f"{ssl_cert_param}"
    )

    try:
        logging.info(f"Attempting to connect to Db2: {db2_hostname}:{db2_port}, Database: {db2_database}")
        db2_conn = ibm_db.connect(conn_string, "", "")
        logging.info("Successfully connected to Db2.")
        return db2_conn
    except Exception as e:
        # Provide more specific feedback if possible
        error_code = str(e) # ibm_db often includes SQLCODE in the error string
        logging.error(f"Db2 connection failed: {error_code}")
        db2_conn = None
        # Map common errors to user-friendly messages
        if "SQLCODE=-1391" in error_code or "SQLCODE=-30082" in error_code:
            return None, "Db2 Connection Failed: Authentication error. Check API Key or IAM permissions."
        elif "SQLCODE=-1097" in error_code or "SQLCODE=-1031" in error_code:
             return None, "Db2 Connection Failed: Database server unavailable or hostname/port incorrect."
        elif "SSL" in error_code.upper():
             return None, f"Db2 Connection Failed: SSL error. Certificate issue? Path tried: {ssl_cert_path}"
        else:
            return None, f"Db2 Connection Failed: {error_code}" # Generic fallback


def execute_sql(sql_command):
    """Executes a SQL command against the Db2 database."""
    # Check driver first
    if not IBM_DB_LOADED:
        return False, "Db2 driver (ibm_db) failed to load during application startup. Cannot execute SQL."

    conn_result = get_db2_connection()
    # Check if get_db2_connection returned a tuple (error case)
    if isinstance(conn_result, tuple):
        conn, error_message = conn_result
        if conn is None:
            return False, error_message # Return specific connection error
    else:
        conn = conn_result # Normal connection object

    if not conn:
        return False, "Database connection failed." # Fallback generic message

    try:
        logging.info(f"Executing SQL: {sql_command[:100]}...") # Log truncated SQL
        stmt = ibm_db.exec_immediate(conn, sql_command)
        # Check for errors after execution attempt (ibm_db might return None on failure)
        if stmt is None:
           raise Exception(ibm_db.stmt_errormsg()) # Try to get specific error

        logging.info("SQL command executed successfully.")
        # Attempt to close statement handle if one was returned
        try:
            ibm_db.free_stmt(stmt)
        except:
            pass # Ignore freeing errors
        return True, "Command executed successfully."
    except Exception as e:
        error_msg = f"SQL execution error: {e}"
        logging.error(error_msg)
        return False, error_msg


def fetch_sql_results(sql_query):
    """Executes a SELECT SQL query and fetches results."""
    # Check driver first
    if not IBM_DB_LOADED:
        return None, "Db2 driver (ibm_db) failed to load during application startup. Cannot execute SQL."

    conn_result = get_db2_connection()
    # Check if get_db2_connection returned a tuple (error case)
    if isinstance(conn_result, tuple):
        conn, error_message = conn_result
        if conn is None:
            return None, error_message # Return specific connection error
    else:
        conn = conn_result # Normal connection object

    if not conn:
        return None, "Database connection failed." # Fallback generic message

    results = []
    stmt = None # Initialize stmt
    try:
        logging.info(f"Fetching SQL: {sql_query[:100]}...") # Log truncated SQL
        stmt = ibm_db.exec_immediate(conn, sql_query)

        if stmt is None:
           raise Exception(ibm_db.stmt_errormsg())

        # Get column names
        column_names = []
        num_fields = ibm_db.num_fields(stmt)
        if num_fields > 0:
             for i in range(num_fields):
                 col_name = ibm_db.field_name(stmt, i)
                 if col_name: # Ensure column name is valid
                     column_names.append(col_name)
                 else:
                     logging.warning(f"Could not retrieve name for column index {i}")
                     column_names.append(f"COLUMN_{i}") # Use placeholder


             # Fetch rows
             row = ibm_db.fetch_assoc(stmt)
             while row is not False: # fetch_assoc returns False when no more rows
                 # Process row values
                 processed_row = {}
                 for col in column_names:
                     # Check if column exists in fetched row (can happen with invalid col names)
                     if col in row:
                         # Convert common non-serializable types safely
                         val = row[col]
                         if isinstance(val, (datetime.date, datetime.datetime)):
                             processed_row[col] = val.isoformat()
                         elif isinstance(val, decimal.Decimal):
                              processed_row[col] = float(val) # Or str(val) if precision needed
                         else:
                              processed_row[col] = str(val) if val is not None else None
                     else:
                         processed_row[col] = None # Placeholder if column name wasn't fetched correctly

                 results.append(processed_row)
                 row = ibm_db.fetch_assoc(stmt)

        logging.info(f"SQL query fetched {len(results)} rows.")
        return results, "Query executed successfully."

    except Exception as e:
        error_msg = f"SQL query error: {e}"
        logging.error(error_msg)
        return None, error_msg
    finally:
        # Ensure statement resources are freed
        if stmt is not None:
             try:
                 ibm_db.free_result(stmt)
                 ibm_db.free_stmt(stmt)
             except Exception as free_e:
                 logging.warning(f"Error freeing Db2 statement resources: {free_e}")

# --- Flask Routes ---

@app.route('/')
def index():
    """Serves the main HTML page, passing resource info."""
    # Ensure Db2 driver loaded check
    driver_status = "OK" if IBM_DB_LOADED else "Error: Db2 driver (ibm_db) failed to load. Check container logs."

    resource_links = {
        "cos_bucket_name": user_cos_bucket_name,
        "cos_bucket_url": user_cos_bucket_url,
        "db2_console_url": user_db2_console_url,
        "helper_app_console_url": user_helper_app_console_url,
        "secrets_manager_url": user_secrets_manager_url,
        "region": deployed_region,
        "driver_status": driver_status # Add driver status
    }
    return render_template('index.html', links=resource_links)

@app.route('/setup', methods=['POST'])
def setup_table():
    """API endpoint to run the CREATE EXTERNAL TABLE command."""
    # Check driver first
    if not IBM_DB_LOADED:
        return jsonify({"status": "Error", "message": "Db2 driver (ibm_db) is not loaded. Cannot perform setup. Check container logs."}), 500

    if not public_sample_data_url_base:
        return jsonify({"status": "Error", "message": "Public sample data URL base not configured."}), 400

    # SQL commands (as before)
    create_sql = f"""
    CREATE EXTERNAL TABLE SAMPLE_CUSTOMERS (
        CustomerID INT, FirstName VARCHAR(50), LastName VARCHAR(50), Company VARCHAR(100),
        City VARCHAR(50), Country VARCHAR(50), Phone1 VARCHAR(30), Phone2 VARCHAR(30),
        Email VARCHAR(100), SubscriptionDate DATE, Website VARCHAR(100)
    ) USING (
        DATAOBJECT('{public_sample_data_url_base}/customers.csv')
        FORMAT CSV DELIMITER ',' QUOTE '"' SKIPHEADER 1 LOGERRORS TRUE REMOTESOURCE 'COS' CTRLCHARS TRUE
    )"""
    check_sql = "SELECT 1 FROM SYSCAT.TABLES WHERE TABSCHEMA = CURRENT SCHEMA AND TABNAME = 'SAMPLE_CUSTOMERS'"

    # Check existence
    table_exists = False
    try:
        conn_result = get_db2_connection()
        if isinstance(conn_result, tuple):
             conn, error_message = conn_result
             if conn is None: return jsonify({"status": "Error", "message": f"Db2 Connection Error: {error_message}"}), 500
        else:
             conn = conn_result
        if not conn: return jsonify({"status": "Error", "message": "Failed to connect to Db2"}), 500

        stmt_check = ibm_db.exec_immediate(conn, check_sql)
        if stmt_check is None: raise Exception(f"Failed to execute table check: {ibm_db.stmt_errormsg()}")
        exists = ibm_db.fetch_tuple(stmt_check)
        ibm_db.free_result(stmt_check)
        if exists:
            table_exists = True
            logging.info("Table SAMPLE_CUSTOMERS already exists. Skipping creation.")
            return jsonify({"status": "OK", "message": "Sample table link already exists."})
    except Exception as e:
         # Table might not exist, that's okay, proceed with CREATE
         if "SQLCODE=-204" in str(e): # Specific Db2 code for 'object not found'
             logging.info("Table SAMPLE_CUSTOMERS does not exist yet. Proceeding with creation.")
         else:
             logging.warning(f"Error checking if table exists (will attempt create anyway): {e}")
             # Return error if check fails unexpectedly:
             # return jsonify({"status": "Error", "message": f"Failed to check table existence: {e}"}), 500

    # Proceed with CREATE TABLE only if it doesn't exist
    if not table_exists:
        success, message = execute_sql(create_sql)
        if success:
            return jsonify({"status": "OK", "message": "Sample table link created successfully!"})
        else:
            # Check for specific "already exists" error - defensive check
            if "SQLCODE=-601" in message:
                 logging.warning("CREATE TABLE failed because table already exists (check may have failed).")
                 return jsonify({"status": "OK", "message": "Sample table link already exists."})
            return jsonify({"status": "Error", "message": f"Failed to create table link: {message}"}), 500

    # Should not be reached if exists check works, but as a fallback
    return jsonify({"status": "OK", "message": "Sample table link already exists (fallback)."}), 200


@app.route('/query', methods=['POST'])
def query_data():
    """API endpoint to run the sample SELECT query."""
     # Check driver first
    if not IBM_DB_LOADED:
        return jsonify({"status": "Error", "message": "Db2 driver (ibm_db) is not loaded. Cannot query data. Check container logs."}), 500

    select_sql = "SELECT CustomerID, FirstName, LastName, Country FROM SAMPLE_CUSTOMERS WHERE Country = 'USA' LIMIT 10"

    results, message = fetch_sql_results(select_sql)
    if results is not None:
        return jsonify({"status": "OK", "message": "Query successful!", "data": results})
    else:
        # Check if the error is "table not found" specifically
        if "SQLCODE=-204" in message: # Specific Db2 code for 'object not found'
             return jsonify({"status": "Error", "message": "Sample table not found. Please click 'Prepare Sample Data Table' first."}), 400
        # Return specific connection errors if they occurred during fetch
        elif "Db2 Connection Failed" in message:
             return jsonify({"status": "Error", "message": message}), 500
        else:
            return jsonify({"status": "Error", "message": f"Query failed: {message}"}), 500


if __name__ == '__main__':
    # Add imports needed for safe JSON serialization if not already present
    import datetime
    import decimal

    # Attempt to fetch API key on startup - log error but don't prevent startup
    if not get_db2_api_key():
        logging.error("Failed to retrieve Db2 API Key on startup. Database operations will fail until resolved.")

    # Port needs to be 8080 for Code Engine by default unless overridden
    port = int(os.environ.get('PORT', 8080))
    # Run on 0.0.0.0 to be accessible within Code Engine
    logging.info(f"Starting Flask app on 0.0.0.0:{port}")
    app.run(host='0.0.0.0', port=port)

z
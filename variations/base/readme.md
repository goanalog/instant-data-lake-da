# Instant Data Lake — Base

Welcome! You’ve stood up your data lake — nice move ✨

## Your next steps
1. **Open upload UI** → upload a CSV to see your lake in action.
2. **Open storage console** → explore your bucket and objects.
3. **Open observability dashboard** → confirm events and health.

## What’s next?
You’ve built your lake — now unlock automation ✨  
Deploy **App Connect** to orchestrate your data flows 🚀  
Data is flowing — now turn it into insights ✨  
Deploy **Cognos Analytics** and build your first dashboard 🚀

## Deep links
> **Deep links**
> - Storage console: `https://cloud.ibm.com/objectstorage/buckets/<bucket>?region=<region>`
> - Projects redeploy: `https://cloud.ibm.com/projects/{project_id}/configurations/{config_id}?tab=deploy`
> - Observability dashboard: `https://cloud.ibm.com/observe/overview`
> - Watson Query console: `https://cloud.ibm.com/services/watson-query`
> 
> The Terraform outputs above will render the correct links for your deployment.

# **Instant Data Lake (Serverless)**

This deployable architecture creates a simple, free, serverless data lake in about 90 seconds. You don't need to configure anything—just click deploy.

It provisions two **free 'Lite' tier** services:

1. **Cloud Object Storage (COS):** A bucket to store your files (CSV, JSON, Parquet).  
2. **SQL Query:** A serverless service to run SQL queries on those files.

The SQL Query service is automatically pre-configured to use your new COS bucket.

## **How to Use**

**Step 1\. Deploy the Architecture**

* Click the "Deploy" button from the catalog.  
* You do not need to enter any values.  
* Wait for the deployment to finish (approx. 90 seconds).

**Step 2\. Upload Your Data**

* Go to the deployment's **Outputs** section.  
* Click the 2\_Upload\_Files\_URL link.  
* Drag-and-drop a data file (e.g., sales.csv) into the bucket.

**Step 3\. Query Your Data**

* Go back to the deployment's **Outputs** section.  
* Click the 3\_Run\_SQL\_Queries\_URL link.  
* This opens the SQL Query UI. In the query box, type a query using your bucket name and file name.

### **Sample Query**

Copy this query and replace your-file.csv with the name of the file you uploaded.

SELECT \*  
FROM cos://\[YOUR\_BUCKET\_REGION\]/\[YOUR\_BUCKET\_NAME\]/your-file.csv  
LIMIT 10

You can find your exact bucket name and a pre-formatted sample query in the 1\_COS\_Bucket\_Name and 4\_Sample\_Query outputs.
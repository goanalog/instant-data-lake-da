# Instant Data Lake — Cognos Analytics

You’re ready to explore your data with dashboards and visualizations.

## Your next steps
1. **Open analytics dashboard** → view the preloaded visuals.
2. **Open storage console** → inspect the underlying files.
3. **Open Watson Query console** → query your lake like a database.

## What’s next?
Need pipelines? Deploy **App Connect** next 🚀  
Want simple hands-on control? Use the **Base** variation to upload files quickly.

## Deep links
> **Deep links**
> - Storage console: `https://cloud.ibm.com/objectstorage/buckets/<bucket>?region=<region>`
> - Projects redeploy: `https://cloud.ibm.com/projects/{project_id}/configurations/{config_id}?tab=deploy`
> - Observability dashboard: `https://cloud.ibm.com/observe/overview`
> - Watson Query console: `https://cloud.ibm.com/services/watson-query`
> 
> The Terraform outputs above will render the correct links for your deployment.

# **Instant Data Lake \+ Auto-Ingestion**

This deployable architecture creates a simple, free, serverless data lake in about 2-3 minutes. You don't need to configure anything—just click deploy.

It provisions three **free 'Lite' tier** services:

1. **Cloud Object Storage (COS):** A bucket to store your files (CSV, JSON, Parquet).  
2. **SQL Query:** A serverless service to run SQL queries on those files.  
3. **App Connect:** A tool to build "flows" that automatically pull data from other apps (like GMail, Salesforce, etc.) and save it to your bucket.

The SQL Query service is automatically pre-configured to use your new COS bucket.

## **How to Use**

**Step 1\. Deploy the Architecture**

* Click the "Deploy" button from the catalog.  
* You do not need to enter any values.  
* Wait for the deployment to finish (approx. 2-3 minutes).

**Step 2\. (OPTION A \- MANUAL) Upload Your Data**

* Go to the deployment's **Outputs** section.  
* Click the 2\_Upload\_Files\_URL link.  
* Drag-and-drop a data file (e.g., sales.csv) into the bucket.

**Step 2\. (OPTION B \- AUTOMATIC) Automate Data Ingestion**

* Go to the deployment's **Outputs** section.  
* Click the 5\_Automate\_Data\_Ingestion\_URL link.  
* In the App Connect UI, create a new "Event-driven flow".  
* **Example:** Create a flow that triggers "When a new email with an attachment arrives in GMail" and adds an action to "Create object in Cloud Object Storage" using your new bucket.

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
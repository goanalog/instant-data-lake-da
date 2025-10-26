# Instant Data Lake (Serverless)

This deployable architecture creates a simple, free, serverless data solution in about 3 minutes. You don't need to configure anything—just choose your variation and click deploy.

All variations use **free 'Lite' tier** services.

## Choose Your Variation

This product comes with three variations to solve different problems:

1.  **Base Data Lake (SQL Only)**
    * **What it is:** Provisions a Cloud Object Storage (COS) bucket and a SQL Query instance.
    * **Use it for:** Instantly running SQL queries on files (CSV, JSON, etc.) that you upload.

2.  **Data Lake + Auto-Ingestion (App Connect)**
    * **What it is:** Deploys the Base Data Lake *plus* an App Connect instance.
    * **Use it for:** Building no-code automated pipelines to pull data from SaaS apps (like Salesforce or GMail) and save it to your data lake.

3.  **Data Lake + BI Dashboard (Cognos)**
    * **What it is:** Deploys the Base Data Lake *plus* a Cognos Dashboard Embedded instance.
    * **Use it for:** Building and sharing rich, interactive, drag-and-drop dashboards from the data in your files.

## How to Use (Base Variation)

1.  **Deploy the Architecture:** Select the "Base Data Lake" variation and click deploy.
2.  **Upload Your Data:** Go to the deployment's **Outputs** section and click the `2_Upload_Files_URL` link. Drag-and-drop a data file (e.g., `sales.csv`) into the bucket.
3.  **Query Your Data:** Go back to the **Outputs** section and click the `3_Run_SQL_Queries_URL` link. This opens the SQL Query UI.
4.  **Run Query:** Use the `4_Sample_Query` from the outputs to run your first query.
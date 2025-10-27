# Instant Data Lake - Foundation Flavor

This flavor instantly deploys the core components for your simple, serverless data lake using free IBM Cloud plans, **plus a helper app** to get you querying sample data with just a few clicks!

## What You Can Do

* **Store Any Data:** Get an Object Storage (COS) bucket ready for your files.
* **Query with SQL Instantly:** Get a managed Db2 Warehouse instance.
* **Click-Button Setup:** Use the deployed Helper Web App to automatically link Db2 to public sample data and run your first query.

## Pricing - Free to Start! 🪙

This flavor uses free plans:

* **IBM Cloud Object Storage (COS):** Uses the **Lite Plan (free)**. *Note: Deprecated.*
* **IBM Db2 Warehouse on Cloud:** Uses the **Lite plan (free)**.
* **IBM Code Engine:** Uses the **Free Tier** (based on usage, this app is tiny).
* **IBM Secrets Manager:** Uses the **Lite Plan (free)**.

✅ **This setup runs for free within the plan limits.** Ensure your account doesn't already have conflicting Lite plan instances.

## Who Is This For?

* Anyone wanting the **absolute fastest, easiest, no-cost** way to store data and see SQL query results.
* Users **new to data lakes** wanting a guided, zero-config start.

## What Gets Created

* 1 x COS instance (`lite`) & bucket
* 1 x Db2 Warehouse instance (`lite`)
* 1 x Secrets Manager instance (`lite`) & secret
* 1 x Code Engine Project & Application (Helper App)
* IAM Service ID, API Key, and Policies

## Get Started Fast - Just Click!

Your data lake foundation and helper app are ready!

1.  **Check Outputs:** After deployment finishes (allow **10-15+ minutes** for the first build), go to the **Outputs** tab in your IBM Cloud Project or Schematics workspace.
2.  **Launch Helper App:** Click the URL provided in the `HELPER_APP_URL` output.
3.  **Click Button 1:** In the web app, click **"Prepare Sample Data Table"**. Wait for the success message (this links your Db2 to public sample data).
4.  **Click Button 2:** Click **"Run Sample Query"**.
5.  **✨ See Results Instantly! ✨** The sample data query results will appear right in the web app!

## Using Your Own Data (Next Steps)

1.  **Find Your Private Bucket:** Note the bucket name provided in the `YOUR_PRIVATE_BUCKET_INFO` output, or use the direct link in the `cos_bucket_console_url` output.
2.  **Locate Sample Files:** Find the `sample-data/` folder in the main project directory you downloaded/cloned (`customers.csv`, `devices.csv`, `sales.csv`).
3.  **Upload:** Use the COS UI (via the link or Resource List) to upload these files (or your own data) into **your private bucket**.
4.  **Create Your External Table:** Connect to your Db2 Warehouse instance using the IBM Cloud UI console (link in `db2_warehouse_console_url` output or find it in your Resource List). Adapt the `CREATE EXTERNAL TABLE` command from the Helper App's logic (or the example in `YOUR_PRIVATE_BUCKET_INFO` output) to point to *your* bucket and file. Run this command in the Db2 console.
5.  **Query Your Table:** Run `SELECT * FROM YOUR_TABLE LIMIT 10;` in the Db2 console.

## Deployment Outputs

Check the "Outputs" tab for:

* The URL for the Helper App (your main starting point!).
* Information about your private bucket and console link.
* Direct links to the consoles for Db2 Warehouse, Code Engine, and Secrets Manager.
* Names/IDs for the created instances.
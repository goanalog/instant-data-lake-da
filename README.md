# Instant Data Lake Starter Kit 🚀

Get a simple, serverless data lake up and running on IBM Cloud in **minutes**, with **zero configuration** required! This kit deploys the essential building blocks and lets you query sample data almost immediately using a simple web app.

## What You Get Instantly

This starter kit automatically sets up core data lake services (Cloud Object Storage for storing files and Db2 Warehouse on Cloud for running SQL on those files). It also deploys a small "Helper App" to guide you through running your first query on sample data with just button clicks. You can choose to add powerful analytics with Cognos or easy app integration with App Connect.

## Choose Your Kit Flavor ✨

Pick the starting point that's right for you:

1.  **Foundation (Free to Start):** Get the basics – object storage (COS), a Db2 Warehouse instance, and the Helper App. **Query public sample data right after setup via the app! Perfect for trying things out or small projects, as it runs on IBM Cloud's free plans (within limits).** ✅
2.  **Foundation + Analytics (Cognos Trial):** Adds IBM Cognos Analytics for creating dashboards and finding AI-driven insights in your data. **Cognos includes a 30-day free trial, but requires a paid plan for longer use.** ⚠️
3.  **Foundation + Integration (App Connect Free):** Adds IBM App Connect to easily connect your data lake to other apps and automate workflows. **Uses App Connect's free plan, which has monthly usage limits.** ✅ / ⚠️

**Important Note on Costs:** While the Foundation and Integration flavors use free plans, always check the current IBM Cloud pricing documentation for the latest details on limits and potential costs if you exceed them. The Analytics flavor *will* require payment after the 30-day Cognos trial.

## How it Works (Simple View)


## Instant Sample Query & Included Data 📊

To provide an **instant query experience**, the deployed Helper App includes buttons to connect your new Db2 Warehouse instance to a **publicly hosted version** of sample customer data and run a query – all without writing SQL yourself initially!

Additionally, this package includes sample CSV files (`customers.csv`, `devices.csv`, `sales.csv`) in the `sample-data/` folder for your own use. After running the instant demo query via the Helper App, the app and this documentation guide you on how to upload these files (or your own data) to **your private COS bucket** and query that data using the Db2 console.

## Quick Start Guide

1.  **Add to Your Catalog:** Add this starter kit to your private catalog in IBM Cloud using the release `.tgz` URL from the Git repository.
2.  **Find it:** Go to the IBM Cloud Catalog and select your private catalog. Find the "Instant Data Lake Starter Kit" tile.
3.  **Choose a Flavor:** Click the tile and pick the flavor (Foundation, Analytics, or Integration) you want to deploy.
4.  **Add to Project:** Click "Add to project" (create a new project if needed).
5.  **Validate (1 Click):** On the project screen (no settings to change!), click **"Validate"**. Check the plan.
6.  **Deploy (1 Click):** Click **"Apply"**. Resources (including the Helper App) will be created automatically. This might take **10-15 minutes** or more, especially the first time Code Engine builds the app image. 🎉
7.  **Use It!:** Check the "Outputs" tab after deployment for the `HELPER_APP_URL`.
    * Click the URL to open the Helper App.
    * Follow the simple steps in the app: Click Button 1 ("Prepare Sample Data Table"), then Click Button 2 ("Run Sample Query").
    * See instant results!
    * Refer to the app's "Next Steps" / "Handy References" and the detailed README for your chosen flavor (in the `variations/...` folder) to learn how to upload your own data and query it.

## What Gets Created

Depending on the flavor, you'll get instances of:

* IBM Cloud Object Storage (COS) & Bucket
* IBM Db2 Warehouse on Cloud
* IBM Secrets Manager & Secret
* IBM Code Engine Project & Application (the Helper App)
* IAM Service ID, API Key & Policies
* (Analytics Flavor) IBM Cognos Analytics
* (Integration Flavor) IBM App Connect



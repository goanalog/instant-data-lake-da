# Instant Data Lake - Foundation + Analytics Variation

This variation deploys the foundational data lake infrastructure and integrates IBM Cognos Analytics on Cloud for business intelligence.

## Features

* Includes all features from the Foundation variation (COS Instance, Bucket, SQL Query using free tiers/plans).
* Provisions an IBM Cognos Analytics on Cloud service instance.
* (Optional) Configures integration between Cognos and the data lake components (if defined in main.tf).

## Pricing Considerations 🪙

This variation deploys the following key IBM Cloud services:

* **IBM Cloud Object Storage (COS):** Utilizes free tier options (Standard Free Tier or potentially Lite Plan).
* **IBM SQL Query:** Utilizes the free Lite plan.
* **IBM Cognos Analytics on Cloud:** **Requires a paid subscription after an initial 30-day free trial.** ⚠️

✅ While the underlying storage and query services have free options, **the core Cognos Analytics component of this variation is a paid service after the trial period.** Ensure you understand the Cognos Analytics pricing plans before deploying for long-term use.

## Best For

* Users needing powerful business intelligence and analytics capabilities alongside their instant data lake.
* Organizations evaluating Cognos Analytics (utilizing the 30-day trial).
* Environments where advanced reporting, dashboarding, and data exploration are required on data stored in COS.

## Prerequisites

* Deployment of this variation via the main "Instant Data Lake" catalog entry.
* Acceptance of Cognos Analytics terms and conditions during deployment/first use.

## Deployed Resources

* 1 x IBM Cloud Object Storage instance (`standard` plan)
* 1 x IBM Cloud Object Storage bucket (`smart` tier)
* 1 x IBM SQL Query instance (`lite` plan)
* 1 x IBM Cognos Analytics instance (plan selected via default, e.g., `standard`)

## Getting Started with Sample Data

This deployable architecture creates the necessary infrastructure (COS bucket, SQL Query instance, Cognos instance). To analyze sample data:

1.  **Locate Sample Data:** Find the `sample-data/` folder in the root directory where you cloned this repository or extracted the downloaded bundle.
2.  **Find Your Bucket:** Go to your IBM Cloud Resource List, find the COS instance (`instant-dl-cos-XXX`), and navigate to the bucket (`instant-dl-bucket-XXX`). Check the **Outputs** tab for the exact bucket name.
3.  **Manual Upload:** Using the COS UI, **upload** the `customers.csv`, `devices.csv`, and `sales.csv` files into the bucket.
4.  **Access Cognos:** Go to your IBM Cloud Resource List and launch the Cognos Analytics instance (`instant-dl-cognos-XXX`).
5.  **Connect to Data:** Within Cognos, create a new Data Server connection using the SQL Query instance details and your IBM Cloud API Key. Then, create Data Modules or Reports referencing the CSV files in your COS bucket via the SQL Query connection. *(Detailed Cognos steps are beyond this README, refer to Cognos documentation)*. Alternatively, use the SQL Query UI first to explore (see deployment outputs).

## Outputs

Check the deployment Outputs tab for:

* Instructions for uploading sample data to the bucket.
* A sample SQL query to test connectivity via the SQL Query UI.
* The CRN of the provisioned COS instance.
* The CRN of the provisioned SQL Query instance.
* The CRN of the provisioned Cognos Analytics instance.
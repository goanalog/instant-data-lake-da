# Instant Data Lake - Foundation + Integration Variation

This variation deploys the foundational data lake infrastructure and integrates IBM App Connect using the free Lite tier.

## Features

* Includes all features from the Foundation variation (COS Instance, Bucket, SQL Query using free tiers/plans).
* Provisions an IBM App Connect service instance (Lite Plan).
* (Optional) Configures basic flows or connections relevant to the data lake (if defined in main.tf).

## Pricing Considerations 🪙

This variation deploys the following key IBM Cloud services:

* **IBM Cloud Object Storage (COS):** Utilizes free tier options (Standard Free Tier or potentially Lite Plan).
* **IBM SQL Query:** Utilizes the free Lite plan.
* **IBM App Connect:** Configured to use the **Lite plan (always free up to a certain number of flow runs/month)**.

✅ / ⚠️ **This variation can typically operate for free if usage remains within the App Connect Lite plan limits.** If you anticipate exceeding these limits (e.g., thousands of flow runs per month), you will need to upgrade to a paid App Connect plan.

## Best For

* Users needing basic application and data integration capabilities connected to their instant data lake.
* Automating simple, low-volume workflows involving data in COS (e.g., notifications on new file uploads).
* Environments where light integration tasks are sufficient and cost is a primary concern.

## Prerequisites

* Deployment of this variation via the main "Instant Data Lake" catalog entry.

## Deployed Resources

* 1 x IBM Cloud Object Storage instance (`standard` plan)
* 1 x IBM Cloud Object Storage bucket (`smart` tier)
* 1 x IBM SQL Query instance (`lite` plan)
* 1 x IBM App Connect instance (`lite` plan)

## Getting Started with Sample Data & Integration

This deployable architecture creates the necessary infrastructure (COS bucket, SQL Query instance, App Connect instance). To use the components:

1.  **Locate Sample Data:** Find the `sample-data/` folder in the root directory.
2.  **Find Your Bucket:** Go to your IBM Cloud Resource List, find the COS instance (`instant-dl-cos-XXX`), and navigate to the bucket (`instant-dl-bucket-XXX`). Check **Outputs** for the name.
3.  **Manual Upload:** Upload the sample CSV files (`customers.csv`, etc.) into the bucket using the COS UI.
4.  **Explore with SQL Query:** Use the sample query from the deployment **Outputs** (`STEP_2_RUN_SAMPLE_QUERY`) in the SQL Query UI (`instant-dl-sql-XXX`) to verify data access.
5.  **Configure App Connect:** Go to your IBM Cloud Resource List and launch the App Connect instance (`instant-dl-appc-XXX`). Within the App Connect UI, create flows. For example, you could create a flow triggered by a new file upload in your COS bucket that sends a notification or processes the data. *(Refer to App Connect documentation for flow creation specifics)*.

## Outputs

Check the deployment Outputs tab for:

* Instructions for uploading sample data to the bucket.
* A sample SQL query to test data access via the SQL Query UI.
* The CRN of the provisioned COS instance.
* The CRN of the provisioned SQL Query instance.
* The CRN of the provisioned App Connect instance.
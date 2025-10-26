# Instant Data Lake - Foundation Variation

This variation deploys the foundational components for a basic, serverless data lake setup on IBM Cloud using free tier services.

## Features

* Provisions an IBM Cloud Object Storage (COS) instance (Standard Plan for Free Tier access).
* Creates a COS bucket (Smart Tier for Free Tier access).
* Provisions an IBM SQL Query instance (Lite Plan).
* Configures SQL Query to use the created COS instance by default.

## Pricing Considerations 🪙

This variation deploys the following key IBM Cloud services:

* **IBM Cloud Object Storage (COS):** Configured using the **Standard Plan with a Smart Tier bucket** to leverage the **Free Tier (free up to 5GB/month for 12 months, plus request/egress allowances)**. Alternatively, you could modify the `main.tf` to use the **Lite Plan (always free up to 25GB/month)** if preferred, though Lite plans are being deprecated.
* **IBM SQL Query:** Configured to use the **Lite plan (always free up to a certain data scanned limit per month)**.

✅ **This variation is designed to operate within the free tiers/plans of its core components under typical usage.** Exceeding free tier limits (e.g., storing more data, exceeding request limits, scanning large amounts of data) will incur standard pay-as-you-go charges.

## Best For

* Users needing instant, cost-effective object storage and serverless data querying capabilities.
* Getting started with data lake concepts on IBM Cloud at little to no cost.
* Foundation layer for potentially adding other services later.

## Prerequisites

* Deployment of this variation via the main "Instant Data Lake" catalog entry.

## Deployed Resources

* 1 x IBM Cloud Object Storage instance (`standard` plan)
* 1 x IBM Cloud Object Storage bucket (`smart` tier)
* 1 x IBM SQL Query instance (`lite` plan)

## Getting Started with Sample Data

This deployable architecture creates the necessary infrastructure (COS bucket, SQL Query instance). To query sample data:

1.  **Locate Sample Data:** Find the `sample-data/` folder in the root directory where you cloned this repository or extracted the downloaded bundle. It contains `customers.csv`, `devices.csv`, and `sales.csv`.
2.  **Find Your Bucket:** Go to your IBM Cloud Resource List, find the Cloud Object Storage instance (named similar to `instant-dl-cos-XXX`), and navigate to the bucket created by this deployment (named similar to `instant-dl-bucket-XXX`). Check the **Outputs** tab of your deployment for the exact bucket name.
3.  **Manual Upload:** Using the COS UI, **upload** the `customers.csv`, `devices.csv`, and `sales.csv` files directly into the root of the bucket.
4.  **Run Sample Query:** Go to the SQL Query instance UI (named similar to `instant-dl-sql-XXX`). Use the sample query provided in the Terraform deployment **Outputs** section (`STEP_2_RUN_SAMPLE_QUERY`) to query the `customers.csv` data you just uploaded. You can easily adapt the query for `devices.csv` or `sales.csv` by changing the filename in the `FROM` clause.

## Outputs

Check the deployment Outputs tab for:

* Instructions for uploading sample data.
* A ready-to-run SQL query for the sample `customers.csv` data.
* The CRN (Cloud Resource Name) of the provisioned COS instance.
* The CRN of the provisioned SQL Query instance.
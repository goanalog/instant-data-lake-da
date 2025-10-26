# Instant Data Lake

This deployable architecture provides a streamlined way to provision infrastructure on IBM Cloud, offering several variations to suit common enterprise needs for a serverless data lake.

## Overview

Deploy core data lake components (Cloud Object Storage, SQL Query) instantly and optionally integrate powerful analytics (Cognos Analytics) or integration services (App Connect). This architecture is designed for ease of use with a zero-input deployment experience by using sensible defaults.

## Variations and Pricing 🪙

This deployable architecture offers three variations to suit different needs:

1.  **Foundation (Free Tier):** Deploys foundational services including IBM Cloud Object Storage (COS) and SQL Query. **This variation primarily utilizes services with "Always Free" Lite plans or generous free tiers, making it generally free to run within usage limits.** ✅
2.  **Foundation + Analytics (Paid after Trial):** Builds upon the Foundation by adding IBM Cognos Analytics on Cloud. While COS and SQL Query have free options, **Cognos Analytics offers only a 30-day free trial**. Continued use after the trial requires a paid subscription. ⚠️
3.  **Foundation + Integration (Free Tier):** Extends the Foundation with IBM App Connect. App Connect offers an "Always Free" Lite plan with usage limits (e.g., flow runs per month). **This variation can often run for free if usage stays within the Lite plan limits**, but paid plans are necessary for higher volumes. ✅ / ⚠️

**Always review the current IBM Cloud pricing documentation for the most up-to-date details on free tier limits and service costs.**

## Architecture

*(Placeholder: You should link or embed your `diagram.svg` here)*

[Image: Overall Instant Data Lake Architecture] Caption: Overall architecture showing the core components and optional integrations.


## Sample Data Included 📊

This package includes sample CSV files (`customers.csv`, `devices.csv`, `sales.csv`) located in the `sample-data/` directory of the repository or downloaded bundle.

After deployment, you will need to **manually upload** these files to the Cloud Object Storage (COS) bucket created by the architecture to run the sample queries provided in the deployment outputs.

## Prerequisites

* An IBM Cloud account with Pay-As-You-Go or Subscription plan.
* Appropriate IAM permissions (Editor/Manager on Schematics, Editor on Catalog Management, potentially roles for COS, SQL Query, Cognos, App Connect depending on variation).

## How to Deploy

1.  **Onboard to Private Catalog:** Add this deployable architecture to your private catalog in IBM Cloud using the release `.tgz` URL from your Git repository.
2.  **Navigate to Catalog:** Go to the IBM Cloud Catalog and select your private catalog.
3.  **Find the DA:** Locate the "Instant Data Lake" tile.
4.  **Select Variation:** Click the tile and choose the desired variation (Foundation, Analytics, or Integration) based on your needs and pricing considerations.
5.  **Add to Project:** Click "Add to project" and either create a new project or select an existing one.
6.  **Validate:** On the project configuration screen (no inputs needed!), click "Validate". Review the plan.
7.  **Deploy:** Click "Apply" to provision the resources.
8.  **Use:** Follow the instructions in the "Getting Started with Sample Data" section within the chosen variation's README (and the deployment Outputs) to begin using your Instant Data Lake.

## Deployed Resources

Depending on the variation chosen, the following IBM Cloud resources will be provisioned:

* IBM Cloud Object Storage instance
* IBM Cloud Object Storage bucket
* IBM SQL Query instance
* (Analytics Variation) IBM Cognos Analytics instance
* (Integration Variation) IBM App Connect instance
* (Potentially) IAM policies or other supporting resources defined in the Terraform code.

## Outputs

After successful deployment, check the "Outputs" tab in your project configuration for useful information, such as:

* The name of the created COS bucket.
* Instructions and a sample query to run using SQL Query on the included sample data (once uploaded).
* CRNs or IDs of the provisioned service instances.
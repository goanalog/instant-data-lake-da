> **One-click • Zero input • Always-free tiers (us-south)**  
> Deploy any variation without changing a single setting. Everything needed for a great first run is enabled by default.


# Instant Data Lake — Deployable Architecture

This repository provides an IBM Cloud **Deployable Architecture (DA)** with multiple **variations** (e.g., `base`, `appconnect`, `cognos`) to provision a ready-to-use data lake foundation using Terraform.

## Structure
```
instant-data-lake-da/
  ├─ variations/
  │   ├─ base/
  │   ├─ appconnect/
  │   └─ cognos/
  ├─ offering.json
  ├─ README.md
  └─ diagram.svg
```

## How to use
- Onboard this DA to **IBM Cloud Catalog → Private catalog**.
- Each variation directory includes Terraform and a `catalog.json` with metadata.
- In **IBM Cloud Projects**, choose a variation and deploy with least input required.

## Credits
Based on internal data lake patterns. Prepared for Catalog onboarding.

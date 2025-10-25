# A random string for resource uniqueness.
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

# 1. Find the user's target resource group.
data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

# 2. Provision the Cloud Object Storage (COS) instance.
resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.cos_instance_name}-${var.prefix}-${random_string.suffix.result}"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = data.ibm_resource_group.group.id
  tags              = ["instant-data-lake", "base", "lite"]
}

# 3. Provision the COS Bucket.
resource "ibm_resource_bucket" "cos_bucket" {
  bucket_name          = "${var.cos_bucket_name}-${var.prefix}-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = "us-south" # Co-locating with SQL Query
  storage_class        = "smart"
}

# 4. Provision the SQL Query instance.
resource "ibm_resource_instance" "sql_instance" {
  name              = "${var.sql_query_instance_name}-${var.prefix}-${random_string.suffix.result}"
  service           = "sql-query"
  plan              = "lite"
  location          = "us-south" # Co-locating with COS Bucket
  resource_group_id = data.ibm_resource_group.group.id
  tags              = ["instant-data-lake", "base", "lite"]

  # --- THE MAGIC LINK ---
  parameters = {
    target_cos_crn = ibm_resource_bucket.cos_bucket.crn
  }
}

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.62.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
  required_version = ">= 1.1.0"
}

provider "ibm" {
  region = var.region
}

resource "random_string" "suffix" {
  length  = 3
  special = false
  upper   = false
  lower   = false
  numeric = true
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

# Cloud Object Storage Instance (Using Lite Plan)
resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.cos_instance_name}-${random_string.suffix.result}"
  service           = "cloud-object-storage"
  plan              = "lite" # <-- CHANGED to Lite Plan
  location          = "global"
  resource_group_id = data.ibm_resource_group.group.id
  tags              = ["service:cos", "variation:appconnect", "prefix:${var.prefix}"]
}

# Cloud Object Storage Bucket (Defaults to standard storage class with Lite plan)
resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name          = "${var.cos_bucket_name}-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.region
  # storage_class        = "smart" # <-- REMOVED (Not applicable/needed for Lite plan)
  force_delete         = true
}

# SQL Query Instance
resource "ibm_resource_instance" "sql_query_instance" {
  name              = "${var.sql_query_instance_name}-${random_string.suffix.result}"
  service           = "sql-query"
  plan              = "lite"
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id
  tags              = ["service:sql-query", "variation:appconnect", "prefix:${var.prefix}"]

  parameters = {
    default_cos_instance_crn = ibm_resource_instance.cos_instance.crn
  }

  depends_on = [
    ibm_resource_instance.cos_instance
  ]
}

# App Connect Specific Resource
resource "ibm_resource_instance" "app_connect" {
  name              = "${var.appconnect_instance_name}-${random_string.suffix.result}"
  service           = "appconnect" # Verify exact service name if needed
  plan              = var.appconnect_plan # Uses default "lite" from variables.tf
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id
  tags              = ["service:appconnect", "variation:appconnect", "prefix:${var.prefix}"]
}
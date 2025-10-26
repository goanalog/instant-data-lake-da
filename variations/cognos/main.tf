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

# Cloud Object Storage Instance
resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.cos_instance_name}-${random_string.suffix.result}"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global" # <-- FIXED: COS instance location must be global
  resource_group_id = data.ibm_resource_group.group.id
  tags              = ["service:cos", "variation:cognos", "prefix:${var.prefix}"]
}

# Cloud Object Storage Bucket
resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name          = "${var.cos_bucket_name}-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.region # <-- CORRECT: Bucket location is regional
  storage_class        = "smart"
  force_delete         = true
}

# SQL Query Instance
resource "ibm_resource_instance" "sql_query_instance" {
  name              = "${var.sql_query_instance_name}-${random_string.suffix.result}"
  service           = "sql-query"
  plan              = "lite"
  location          = var.region # <-- CORRECT: SQL Query location is regional
  resource_group_id = data.ibm_resource_group.group.id
  tags              = ["service:sql-query", "variation:cognos", "prefix:${var.prefix}"]

  parameters = {
    default_cos_instance_crn = ibm_resource_instance.cos_instance.crn
  }

  depends_on = [
    ibm_resource_instance.cos_instance
  ]
}

# Cognos Analytics Specific Resource
resource "ibm_resource_instance" "cognos_analytics" {
  name              = "${var.cognos_instance_name}-${random_string.suffix.result}"
  service           = "cognos-analytics"
  plan              = var.cognos_plan
  location          = var.region # <-- CORRECT: Cognos location is regional
  resource_group_id = data.ibm_resource_group.group.id
  tags              = ["service:cognos-analytics", "variation:cognos", "prefix:${var.prefix}"]
}
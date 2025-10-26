terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.62.0" # Sticking with the version that initialized successfully
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1" # Sticking with the version that initialized successfully
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

resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.cos_instance_name}-${random_string.suffix.result}"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = var.region # Adjust if COS instance location differs, often 'global'
  resource_group_id = data.ibm_resource_group.group.id
  tags              = ["service:cos", "variation:base", "prefix:${var.prefix}"] # Tags OK here
}

resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name          = "${var.cos_bucket_name}-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.region
  storage_class        = "smart"
  force_delete         = true
  # tags                 = ["service:cos-bucket", "variation:base", "prefix:${var.prefix}"] # <-- REMOVED THIS LINE
}

resource "ibm_resource_instance" "sql_query_instance" {
  name              = "${var.sql_query_instance_name}-${random_string.suffix.result}"
  service           = "sql-query"
  plan              = "lite"
  location          = var.region
  resource_group_id = data.ibm_resource_group.group.id
  tags              = ["service:sql-query", "variation:base", "prefix:${var.prefix}"] # Tags OK here

  parameters = {
    default_cos_instance_crn = ibm_resource_instance.cos_instance.crn
  }

  depends_on = [
    ibm_resource_instance.cos_instance
  ]
}
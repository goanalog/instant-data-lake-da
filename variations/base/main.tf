terraform {
  required_version = ">= 1.0.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.84.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "ibm" {
  region = var.region
}

data "ibm_resource_group" "current" {
  count      = var.resource_group_id == "" ? 1 : 0
  is_default = true
}

locals {
  rg_id = var.resource_group_id != "" ? var.resource_group_id : data.ibm_resource_group.current[0].id
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

# COS Instance
resource "ibm_resource_instance" "cos" {
  name              = "${var.bucket_prefix}-cos-${random_string.suffix.result}"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = var.region
  resource_group_id = local.rg_id
}

# COS HMAC credentials
resource "ibm_resource_key" "cos_hmac" {
  name                 = "${var.bucket_prefix}-hmac-${random_string.suffix.result}"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.cos.id

  parameters = {
    HMAC = true
  }
}

# COS Bucket
resource "ibm_cos_bucket" "bucket" {
  bucket_name          = "${var.bucket_prefix}-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.region
  storage_class        = "standard"
  force_delete         = true
}

# Enable website hosting
resource "ibm_cos_bucket_configuration" "website" {
  bucket_crn = ibm_cos_bucket.bucket.crn

  website {
    enable         = true
    index_document = "index.html"
    error_document = "index.html"
  }
}

# Code Engine Project
resource "ibm_code_engine_project" "proj" {
  name              = "idl-proj-${random_string.suffix.result}"
  resource_group_id = local.rg_id
}

# Secret for COS access keys
resource "ibm_code_engine_secret" "cos_secret" {
  project_id = ibm_code_engine_project.proj.id
  name       = "idl-cos-secret-${random_string.suffix.result}"

  data = {
    COS_ACCESS_KEY_ID     = ibm_resource_key.cos_hmac.credentials["cos_hmac_keys.access_key_id"]
    COS_SECRET_ACCESS_KEY = ibm_resource_key.cos_hmac.credentials["cos_hmac_keys.secret_access_key"]
    COS_ENDPOINT          = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud"
    COS_BUCKET            = ibm_cos_bucket.bucket.bucket_name
  }
}

# Code Engine Application (Helper)
resource "ibm_code_engine_app" "idl_helper" {
  name       = "idl-helper-${random_string.suffix.result}"
  project_id = ibm_code_engine_project.proj.id

  image_reference = var.app_image

  scale_min_instances = 0
  scale_max_instances = 5

  env_variable {
    name = "COS_ACCESS_KEY_ID"
    value_from_secret {
      secret_name = ibm_code_engine_secret.cos_secret.name
      secret_key  = "COS_ACCESS_KEY_ID"
    }
  }

  env_variable {
    name = "COS_SECRET_ACCESS_KEY"
    value_from_secret {
      secret_name = ibm_code_engine_secret.cos_secret.name
      secret_key  = "COS_SECRET_ACCESS_KEY"
    }
  }

  env_variable {
    name = "COS_ENDPOINT"
    value_from_secret {
      secret_name = ibm_code_engine_secret.cos_secret.name
      secret_key  = "COS_ENDPOINT"
    }
  }

  env_variable {
    name = "COS_BUCKET"
    value_from_secret {
      secret_name = ibm_code_engine_secret.cos_secret.name
      secret_key  = "COS_BUCKET"
    }
  }
}

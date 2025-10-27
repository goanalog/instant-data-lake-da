terraform {
  required_version = ">= 1.0.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.84.0"
    }
    random = {
      source = "hashicorp/random"
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

resource "ibm_resource_instance" "cos" {
  name              = "${var.bucket_prefix}-cos-${random_string.suffix.result}"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = var.region
  resource_group_id = local.rg_id
}

resource "ibm_resource_key" "cos_hmac" {
  name                 = "${var.bucket_prefix}-hmac-${random_string.suffix.result}"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.cos.id

  parameters_json = jsonencode({
    HMAC = true
  })
}

resource "ibm_cos_bucket" "bucket" {
  bucket_name          = "${var.bucket_prefix}-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.region
  storage_class        = "standard"
  force_delete         = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "ibm_code_engine_project" "proj" {
  name              = "idl-proj-${random_string.suffix.result}"
  resource_group_id = local.rg_id
}

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

resource "ibm_code_engine_app" "idl_helper" {
  name       = "idl-helper-${random_string.suffix.result}"
  project_id = ibm_code_engine_project.proj.id

  image_reference {
    image          = var.app_image
    resolved_image = var.app_image
  }

  scaling_min = 0
  scaling_max = 5

  run_env_variables {
    type = "secret"
    name = "COS_ACCESS_KEY_ID"
    key  = "COS_ACCESS_KEY_ID"
    ref  = ibm_code_engine_secret.cos_secret.name
  }

  run_env_variables {
    type = "secret"
    name = "COS_SECRET_ACCESS_KEY"
    key  = "COS_SECRET_ACCESS_KEY"
    ref  = ibm_code_engine_secret.cos_secret.name
  }

  run_env_variables {
    type  = "secret"
    name  = "COS_ENDPOINT"
    key   = "COS_ENDPOINT"
    ref   = ibm_code_engine_secret.cos_secret.name
  }

  run_env_variables {
    type  = "secret"
    name  = "COS_BUCKET"
    key   = "COS_BUCKET"
    ref   = ibm_code_engine_secret.cos_secret.name
  }
}

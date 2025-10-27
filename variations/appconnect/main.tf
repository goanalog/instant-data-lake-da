for d in variations/*; do
  cat > "$d/main.tf" <<'EOF'
terraform {
  required_version = ">= 1.3.0"

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

# Auto-detect resource group if not set by user
data "ibm_resource_group" "current" {
  count = var.resource_group_id == "" ? 1 : 0
  name  = null
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

# COS Instance + Bucket + Website
resource "ibm_resource_instance" "cos" {
  name              = "${var.bucket_prefix}-cos-${random_string.suffix.result}"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = var.region
  resource_group_id = local.rg_id
}

resource "ibm_cos_bucket" "bucket" {
  bucket_name          = "${var.bucket_prefix}-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.region
  storage_class        = "standard"
  force_delete         = true
}

resource "ibm_cos_bucket_website" "website" {
  bucket     = ibm_cos_bucket.bucket.bucket_name
  index_page = "index.html"
  error_page = "index.html"
}

# COS HMAC Key (needed for CE writes)
resource "ibm_resource_key" "cos_hmac" {
  name                 = "${var.bucket_prefix}-hmac-${random_string.suffix.result}"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.cos.id

  parameters_json = jsonencode({
    HMAC = true
  })
}

# Code Engine Project + Secret + App
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
  project_id   = ibm_code_engine_project.proj.id
  name         = "idl-helper-${random_string.suffix.result}"
  image        = var.app_image

  cpu          = "1"
  memory       = "1G"
  port         = 8080

  scale_min_instances = 0
  scale_max_instances = 5

  run_env_variables = [
    {
      type = "secret"
      name = "COS_ACCESS_KEY_ID"
      key  = "COS_ACCESS_KEY_ID"
      ref  = ibm_code_engine_secret.cos_secret.name
    },
    {
      type = "secret"
      name = "COS_SECRET_ACCESS_KEY"
      key  = "COS_SECRET_ACCESS_KEY"
      ref  = ibm_code_engine_secret.cos_secret.name
    },
    {
      type = "secret"
      name = "COS_ENDPOINT"
      key  = "COS_ENDPOINT"
      ref  = ibm_code_engine_secret.cos_secret.name
    },
    {
      type  = "secret"
      name  = "COS_BUCKET"
      key   = "COS_BUCKET"
      ref   = ibm_code_engine_secret.cos_secret.name
    }
  ]
}
EOF
done

terraform {
  required_version = ">= 1.5.0"
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

data "ibm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "ibm_resource_instance" "cos" {
  name              = "${var.prefix}-cos"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = data.ibm_resource_group.rg.id
  tags              = ["idlake", "da", "base"]
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name          = "${var.prefix}-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos.id
  single_site_location = var.region
  storage_class        = "standard"
  force_delete         = true
}

resource "ibm_resource_key" "cos_key" {
  name                 = "${var.prefix}-cos-writer"
  role                 = "Writer"
  resource_instance_id = ibm_resource_instance.cos.id
  parameters           = { HMAC = true }
  tags                 = ["idlake", "da", "creds"]
}

locals {
  sample_dir   = "${path.root}/../../sample-data"
  sample_files = fileset(local.sample_dir, "*.csv")
}

resource "ibm_cos_bucket_object" "samples" {
  for_each        = { for f in local.sample_files : f => f }
  bucket_crn      = ibm_cos_bucket.cos_bucket.crn
  bucket_location = var.region

  key     = basename(each.value)
  content = file("${local.sample_dir}/${each.value}")
  # content_type = "text/csv"  <-- THIS LINE WAS REMOVED
}

resource "ibm_code_engine_project" "ce" {
  name              = var.code_engine_project_name
  resource_group_id = data.
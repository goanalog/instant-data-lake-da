# All variables are defined in the root offering.json
# This file declares them so the module can use them.

variable "prefix" {
  type        = string
  description = "A unique prefix for all resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "cos_instance_name" {
  type        = string
  description = "Name for the Cloud Object Storage instance."
}

variable "cos_bucket_name" {
  type        = string
  description = "Name for the Cloud Object Storage bucket."
}

variable "sql_query_instance_name" {
  type        = string
  description = "Name for the SQL Query instance."
}

variable "appconnect_instance_name" {
  type        = string
  description = "Name for the App Connect instance."
}

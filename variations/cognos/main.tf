variable "prefix" {
  type        = string
  description = "A unique prefix for all created resources (used internally, hidden from user)."
  default     = "enterprise-cognos" 
}

variable "resource_group_name" {
  type        = string
  description = "The resource group to deploy resources into (used internally, hidden from user)."
  default     = "Default"
}

variable "cos_instance_name" {
  type        = string
  description = "Name for the Cloud Object Storage instance (used internally, hidden from user)."
  default     = "enterprise-cognos-cos"
}

variable "cos_bucket_name" {
  type        = string
  description = "Name for the Cloud Object Storage bucket (used internally, hidden from user)."
  default     = "enterprise-cognos-bucket"
}

variable "sql_query_instance_name" {
  type        = string
  description = "Name for the SQL Query instance (used internally, hidden from user)."
  default     = "enterprise-cognos-sql"
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where resources will be deployed (used internally, hidden from user)."
  default     = "us-south"
}

# --- Cognos Specific Variables ---

variable "cognos_instance_name" {
  type        = string
  description = "Name for the Cognos Analytics instance (used internally, hidden from user)."
  default     = "enterprise-cognos-analytics"
}

variable "cognos_plan" {
  type        = string
  description = "The plan for the Cognos Analytics service (used internally, hidden from user)."
  default     = "standard" # Note: Check if this is the correct plan ID for the paid plan after trial.
}

# Add any other variables specifically needed ONLY for the 'cognos' variation here,
# ensuring they also have a default value.
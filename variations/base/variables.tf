variable "prefix" {
  type        = string
  description = "Internal prefix for resources."
  default     = "instant-dl-found"
}
variable "cos_instance_name" {
  type        = string
  description = "Internal name for COS instance."
  default     = "instant-dl-cos"
}
variable "cos_bucket_name" {
  type        = string
  description = "Internal name for COS bucket."
  default     = "instant-dl-bucket"
}
variable "sql_query_instance_name" {
  type        = string
  description = "Internal name for SQL Query instance."
  default     = "instant-dl-sql"
}
variable "resource_group_name" {
  type        = string
  description = "Internal resource group name."
  default     = "Default"
}
variable "region" {
  type        = string
  description = "Internal deployment region."
  default     = "us-east" # <-- CHANGED default region
}

# Add any other variables specifically needed ONLY for the 'base' variation here,
# ensuring they also have a default value.
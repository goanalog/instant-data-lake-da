variable "prefix" {
  type        = string
  description = "Internal prefix for resources."
  default     = "instant-dl-found" // New default
}
variable "cos_instance_name" {
  type        = string
  description = "Internal name for COS instance."
  default     = "instant-dl-cos" // New default
}
variable "cos_bucket_name" {
  type        = string
  description = "Internal name for COS bucket."
  default     = "instant-dl-bucket" // New default
}
variable "sql_query_instance_name" {
  type        = string
  description = "Internal name for SQL Query instance."
  default     = "instant-dl-sql" // New default
}
variable "resource_group_name" {
  type        = string
  description = "Internal resource group name."
  default     = "Default"
}
variable "region" {
  type        = string
  description = "Internal deployment region."
  default     = "us-south"
}
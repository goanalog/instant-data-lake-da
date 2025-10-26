variable "prefix" {
  type        = string
  description = "Internal prefix for resources."
  default     = "instant-dl-integ" // New default
}
variable "cos_instance_name" {
  type        = string
  description = "Internal name for COS instance."
  default     = "instant-dl-cos" // Shared base name
}
variable "cos_bucket_name" {
  type        = string
  description = "Internal name for COS bucket."
  default     = "instant-dl-bucket" // Shared base name
}
variable "sql_query_instance_name" {
  type        = string
  description = "Internal name for SQL Query instance."
  default     = "instant-dl-sql" // Shared base name
}
variable "appconnect_instance_name" {
  type        = string
  description = "Internal name for App Connect instance."
  default     = "instant-dl-appc" // New default
}
variable "appconnect_plan" {
  type        = string
  description = "Internal plan for App Connect."
  default     = "lite"
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
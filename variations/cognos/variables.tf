variable "prefix" {
  type        = string
  description = "Internal prefix for resources."
  default     = "instant-dl-analyt" // New default
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
variable "cognos_instance_name" {
  type        = string
  description = "Internal name for Cognos Analytics instance."
  default     = "instant-dl-cognos" // New default
}
variable "cognos_plan" {
  type        = string
  description = "Internal plan for Cognos."
  default     = "standard"
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
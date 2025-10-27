variable "region" {
  type        = string
  description = "Deployment region"
  default     = "us-south"
}

variable "app_image" {
  type        = string
  description = "Container image reference for the IDL Helper app"
  default     = "us.icr.io/goanalog/idl-helper:latest"
}

variable "resource_group_id" {
  type        = string
  default     = ""
  description = "Resource Group override"
}

variable "bucket_prefix" {
  type        = string
  default     = "idl"
  description = "Base name for COS instance and bucket"
}

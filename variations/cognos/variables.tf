variable "region" {
  description = "IBM Cloud region (must match where resources are deployed)"
  type        = string
  default     = "us-south"
}

variable "resource_group_id" {
  description = "Resource Group ID for Code Engine project"
  type        = string
  default     = ""
  sensitive   = false
}

variable "bucket_prefix" {
  description = "Prefix for globally-unique COS bucket names"
  type        = string
  default     = "idl-bucket"
}

variable "app_image" {
  description = "Container image for the IDL helper API"
  type        = string
  default     = "us.icr.io/goanalog/idl-helper:latest"
}

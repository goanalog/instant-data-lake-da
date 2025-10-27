variable "region" {
  type        = string
  description = "Deployment region"
  default     = "us-south"
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

variable "app_image" {
  type        = string
  description = "Container image reference"
}

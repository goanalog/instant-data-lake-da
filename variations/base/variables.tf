variable "region" {
  type    = string
  default = "us-south"
}

variable "resource_group_id" {
  type    = string
  default = ""
}

variable "bucket_prefix" {
  type    = string
  default = "idl-bucket"
}

variable "app_image" {
  type    = string
  default = "us.icr.io/goanalog/idl-helper:latest"
}

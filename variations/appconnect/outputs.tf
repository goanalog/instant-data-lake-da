output "helper_app_url" {
  value       = ibm_code_engine_app.idl_helper.endpoint
  description = "Public endpoint of helper service"
}

output "cos_bucket_name" {
  value       = ibm_cos_bucket.bucket.bucket_name
  description = "COS Bucket Name"
}

output "cos_bucket_console_url" {
  value       = "https://cloud.ibm.com/objectstorage/buckets?bucket=${ibm_cos_bucket.bucket.bucket_name}"
  description = "Bucket in IBM Cloud Console"
}

output "primaryoutput" {
  value = {
    "Open Helper App"   = ibm_code_engine_app.idl_helper.endpoint
    "Open COS Bucket"   = "https://cloud.ibm.com/objectstorage/buckets?bucket=${ibm_cos_bucket.bucket.bucket_name}"
    "Code Engine (App)" = "https://cloud.ibm.com/codeengine/project/${ibm_code_engine_project.proj.guid}/applications/${ibm_code_engine_app.idl_helper.id}"
  }
}

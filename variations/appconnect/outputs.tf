output "bucket_name" {
  value = ibm_cos_bucket.bucket.bucket_name
}

output "bucket_website_url" {
  value = "https://${ibm_cos_bucket.bucket.bucket_name}.s3.${var.region}.cloud-object-storage.appdomain.cloud"
}

output "helper_app_url" {
  value = ibm_code_engine_app.idl_helper.endpoint
}

output "bucket_name" {
  value       = ibm_cos_bucket.bucket.bucket_name
  description = "COS bucket name (static website)"
}

output "bucket_website_url" {
  value       = "https://${ibm_cos_bucket.bucket.bucket_name}.s3.${var.region}.cloud-object-storage.appdomain.cloud"
  description = "Public website endpoint (serves index.html)"
}

output "helper_app_url" {
  value       = ibm_code_engine_app.idl_helper.endpoint
  description = "Public endpoint of the Remix/Manifest helper service"
}

output "STEP_1_UPLOAD_YOUR_DATA" {
  description = "Your data lake is ready! Go to this URL to upload your first file (like 'customers.csv' from the sample data)."
  value       = "https://s3.cloud-object-storage.appdomain.cloud/replace-with-your-endpoint/${ibm_cos_bucket.cos_bucket.bucket_name}/action?prefix="
}

output "STEP_2_ANALYZE_OR_VISUALIZE" {
  description = "Great! Now you can run SQL queries OR build an interactive dashboard:"
  value       = "RUN SQL: https://sql-query.cloud.ibm.com/sqlquery/?instance_crn=${ibm_resource_instance.sql_query.guid}&target_cos_url=cos://${ibm_cos_bucket.cos_bucket.endpoint_public}/${ibm_cos_bucket.cos_bucket.bucket_name}/ | VISUALIZE: ${ibm_resource_instance.cognos.dashboard_url}"
}

output "STEP_3_GET_SAMPLE_DATA_AND_DASHBOARD" {
  description = "(Optional) Don't have data? Get sample CSVs and a pre-built dashboard JSON from this link."
  value       = "https://github.com/IBM-Cloud/da-instant-data-lake/tree/main/assets"
}

output "bucket_name" {
  description = "The name of your new COS bucket."
  value       = ibm_cos_bucket.cos_bucket.bucket_name
}
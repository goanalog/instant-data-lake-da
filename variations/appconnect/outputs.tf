output "STEP_1_UPLOAD_YOUR_DATA" {
  description = "Your data lake is ready! Go to this URL to upload your first file (like 'customers.csv' from the sample data)."
  value       = "https://s3.cloud-object-storage.appdomain.cloud/replace-with-your-endpoint/${ibm_cos_bucket.cos_bucket.bucket_name}/action?prefix="
}

output "STEP_2_ANALYZE_OR_AUTOMATE" {
  description = "Great! Now you can run SQL queries OR connect your SaaS apps:"
  value       = "RUN SQL: https://sql-query.cloud.ibm.com/sqlquery/?instance_crn=${ibm_resource_instance.sql_query.guid}&target_cos_url=cos://${ibm_cos_bucket.cos_bucket.endpoint_public}/${ibm_cos_bucket.cos_bucket.bucket_name}/ | AUTOMATE: ${ibm_resource_instance.appconnect.dashboard_url}"
}

output "STEP_3_GET_SAMPLE_DATA_AND_QUERY" {
  description = "(Optional) Don't have data? Get sample CSVs from this link. After uploading 'customers.csv', you can run this query: 'SELECT * FROM cos://${ibm_cos_bucket.cos_bucket.endpoint_public}/${var.cos_bucket_name}/customers.csv WHERE Country = ''USA'' LIMIT 10'"
  value       = "Sample Data: https://github.com/IBM-Cloud/da-instant-data-lake/tree/main/assets/sample-data | Sample Query: SELECT * FROM cos://${ibm_cos_bucket.cos_bucket.endpoint_public}/${var.cos_bucket_name}/customers.csv WHERE Country = 'USA' LIMIT 10"
}

output "bucket_name" {
  description = "The name of your new COS bucket."
  value       = ibm_cos_bucket.cos_bucket.bucket_name
}
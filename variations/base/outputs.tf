output "STEP_1_UPLOAD_YOUR_DATA" {
  description = "Your data lake is ready! Go to this URL to upload your first file (like 'customers.csv' from the sample data)."
  value       = "https://s3.cloud-object-storage.appdomain.cloud/replace-with-your-endpoint/${ibm_cos_bucket.cos_bucket.bucket_name}/action?prefix="
}

output "STEP_2_RUN_SQL_QUERIES" {
  description = "Great! Now, click this link to open the SQL Query UI."
  value       = "https://sql-query.cloud.ibm.com/sqlquery/?instance_crn=${ibm_resource_instance.sql_query.guid}&target_cos_url=cos://${ibm_cos_bucket.cos_bucket.endpoint_public}/${ibm_cos_bucket.cos_bucket.bucket_name}/"
}

output "STEP_3_GET_SAMPLE_DATA_AND_QUERY" {
  # 1. The description is now a static, helpful string.
  description = "A sample SQL query to run on your new data lake after uploading the sample 'customers.csv' file."
  
  # 2. The dynamic string is moved to the 'value' field, where it is allowed.
  value = "SELECT * FROM cos://${ibm_cos_bucket.cos_bucket.endpoint_public}/${var.cos_bucket_name}/customers.csv WHERE Country = 'USA' LIMIT 10"
}

output "bucket_name" {
  description = "The name of your new COS bucket."
  value       = ibm_cos_bucket.cos_bucket.bucket_name
}
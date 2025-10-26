output "STEP_1_UPLOAD_SAMPLE_DATA" {
  description = "Action: Find the 'sample-data' folder (in your repo/bundle) and upload customers.csv, devices.csv, and sales.csv to your COS bucket using the UI."
  value       = "Target Bucket Name: ${ibm_cos_bucket.cos_bucket.bucket_name}"
}

output "STEP_2_VERIFY_WITH_SQL_QUERY" {
  description = "Optional Action: Go to your SQL Query instance UI and run this sample query to verify data before using Cognos."
  value = "SELECT * FROM cos://${var.region}/${ibm_cos_bucket.cos_bucket.bucket_name}/customers.csv STORED AS CSV WHERE Country = 'USA' LIMIT 10"
}

output "STEP_3_ACCESS_COGNOS" {
  description = "Action: Access your Cognos Analytics instance via the IBM Cloud Resource List to connect to data and build dashboards/reports."
  value       = "Cognos Instance Name: ${ibm_resource_instance.cognos_analytics.name}"
}

output "cos_instance_crn" {
  description = "CRN of the provisioned Cloud Object Storage instance."
  value       = ibm_resource_instance.cos_instance.crn
}

output "cos_bucket_name_actual" {
  description = "The actual name of the created COS bucket (including random suffix)."
  value       = ibm_cos_bucket.cos_bucket.bucket_name
}

output "sql_query_instance_crn" {
  description = "CRN of the provisioned SQL Query instance."
  value       = ibm_resource_instance.sql_query_instance.crn
}

output "cognos_analytics_instance_crn" {
  description = "CRN of the provisioned Cognos Analytics instance."
  value       = ibm_resource_instance.cognos_analytics.crn
}

output "region_deployed" {
  description = "The IBM Cloud region where resources were deployed."
  value       = var.region
}
output "1_COS_Bucket_Name" {
  description = "The name of your new COS bucket. Use this in your SQL queries."
  value       = ibm_resource_bucket.cos_bucket.bucket_name
}

output "2_Upload_Files_URL" {
  description = "Click this link to go to your new COS bucket and upload files."
  value       = "https://cloud.ibm.com/objectstorage/${ibm_resource_instance.cos_instance.guid}/buckets/${ibm_resource_bucket.cos_bucket.bucket_name}/onboarding"
}

output "3_Run_SQL_Queries_URL" {
  description = "Click this link to open the SQL Query UI, which is pre-configured to use your bucket."
  value       = "https://cloud.ibm.com/sql/launch?instance_crn=${ibm_resource_instance.sql_instance.crn}"
}

output "4_Sample_Query" {
  description = "A sample query to run after you upload 'your-file.csv'."
  value       = "SELECT * FROM cos://${ibm_resource_bucket.cos_bucket.region_location}/${ibm_resource_bucket.cos_bucket.bucket_name}/your-file.csv LIMIT 10"
}

output "5_Automate_Data_Ingestion_URL" {
  description = "Click this link to open App Connect and build flows to auto-upload data to your bucket."
  value       = "https://cloud.ibm.com/services/appconnect/${ibm_resource_instance.appconnect_instance.guid}"
}


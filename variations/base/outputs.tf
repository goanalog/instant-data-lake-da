# ... (Keep existing STEP_1, STEP_2, STEP_3, YOUR_PRIVATE_BUCKET_INFO outputs) ...

# --- Resource Details & Links ---

output "cos_instance_crn" {
  description = "CRN of the provisioned Cloud Object Storage instance."
  value       = ibm_resource_instance.cos_instance.crn
}

output "cos_bucket_name_actual" {
  description = "The actual name of the created COS bucket (including random suffix)."
  value       = ibm_cos_bucket.cos_bucket.bucket_name
}

# Construct the COS Bucket Console URL (URL encoding might be needed depending on console structure)
output "cos_bucket_console_url" {
  description = "Direct link to the created COS Bucket in the IBM Cloud Console."
  # Example URL structure - VERIFY this pattern in the IBM Cloud Console
  value       = "https://cloud.ibm.com/objectstorage/crn:${urlencode(ibm_resource_instance.cos_instance.crn)}/buckets/${ibm_cos_bucket.cos_bucket.bucket_name}/manage?region=${var.region}"
}


output "db2_warehouse_instance_crn" {
  description = "CRN of the provisioned Db2 Warehouse on Cloud instance."
  value       = ibm_resource_instance.db2_warehouse_instance.crn
}

output "db2_warehouse_instance_name" {
  description = "Name of the provisioned Db2 Warehouse on Cloud instance."
  value       = ibm_resource_instance.db2_warehouse_instance.name
}

# Construct the Db2 Warehouse Console URL
output "db2_warehouse_console_url" {
  description = "Direct link to the created Db2 Warehouse instance in the IBM Cloud Console."
  # Example URL structure - VERIFY this pattern
  value       = "https://cloud.ibm.com/resources/instance/${urlencode(ibm_resource_instance.db2_warehouse_instance.id)}" # Using ID, CRN might also work
}


output "helper_app_url" {
  description = "ACTION REQUIRED: Deployment Complete! Click this URL to access the Helper App and finish setup."
  value       = ibm_code_engine_app.helper_app.url # Get the public URL of the app
}

# Construct the Code Engine App Console URL
output "helper_app_console_url" {
  description = "Direct link to the Helper App within Code Engine in the IBM Cloud Console."
  # Example URL structure - VERIFY this pattern
  value       = "https://cloud.ibm.com/codeengine/project/${ibm_code_engine_project.ce_project.id}/application/${ibm_code_engine_app.helper_app.name}/configuration?region=${var.region}"
}

output "secrets_manager_instance_crn" {
  description = "CRN of the provisioned Secrets Manager instance."
  value       = ibm_resource_instance.secrets_manager_instance.crn
}

# Construct the Secrets Manager Console URL
output "secrets_manager_console_url" {
  description = "Direct link to the Secrets Manager instance in the IBM Cloud Console."
  value       = "https://cloud.ibm.com/resources/instance/${urlencode(ibm_resource_instance.secrets_manager_instance.id)}"
}


output "region_deployed" {
  description = "The IBM Cloud region where resources were deployed."
  value       = var.region
}

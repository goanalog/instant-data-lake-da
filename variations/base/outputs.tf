output "helper_app_url" {
  value       = ibm_code_engine_app.idl_helper.endpoint
  description = "Public endpoint of helper app"
}

output "primaryoutput" {
  value = {
    "Open Helper App" = ibm_code_engine_app.idl_helper.endpoint
  }
}

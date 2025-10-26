# ... (Existing resources up to Code Engine App) ...

# Data source for Db2 details (keep this)
data "ibm_resource_instance" "db2_warehouse_instance_details" {
  # ... (as before) ...
}
locals {
  # ... (as before) ...
}

# Code Engine Application
resource "ibm_code_engine_app" "helper_app" {
  project_id = ibm_code_engine_project.ce_project.id
  name       = var.helper_app_name
  image_reference = "docker.io/library/python:3.9-slim"
  min_scale = 0
  max_scale = 1

  # Pass existing and NEW environment variables
  run_env_variables { name = "DB2_HOSTNAME"; value = local.db2_hostname_cleaned }
  run_env_variables { name = "DB2_PORT"; value = local.db2_port }
  run_env_variables { name = "DB2_DATABASE"; value = "BLUDB" }
  run_env_variables { name = "DB2_PWD_SECRET_CRN"; value = ibm_sm_secret.db2_api_key_secret.crn }
  run_env_variables { name = "SECRETS_MANAGER_URL"; value = ibm_resource_instance.secrets_manager_instance.service_endpoints["public"] }
  run_env_variables { name = "PUBLIC_SAMPLE_DATA_URL_BASE"; value = var.public_cos_url_base }
  # --- NEW ENV VARS ---
  run_env_variables {
     name = "USER_COS_BUCKET_NAME"
     value = ibm_cos_bucket.cos_bucket.bucket_name
   }
   run_env_variables {
      name = "USER_COS_BUCKET_URL"
      # Construct the COS Bucket Console URL directly here
      value = "https://cloud.ibm.com/objectstorage/crn:${urlencode(ibm_resource_instance.cos_instance.crn)}/buckets/${ibm_cos_bucket.cos_bucket.bucket_name}/manage?region=${var.region}"
    }
    run_env_variables {
       name = "USER_DB2_CONSOLE_URL"
       # Construct the Db2 Warehouse Console URL directly here
       value = "https://cloud.ibm.com/resources/instance/${urlencode(ibm_resource_instance.db2_warehouse_instance.id)}"
     }
     run_env_variables {
        name = "USER_HELPER_APP_CONSOLE_URL"
        # Construct the Code Engine App Console URL directly here
        value = "https://cloud.ibm.com/codeengine/project/${ibm_code_engine_project.ce_project.id}/application/${local.helper_app_ce_name}/configuration?region=${var.region}"
        # Using local.helper_app_ce_name which includes CE's suffix
      }
      run_env_variables {
         name = "USER_SECRETS_MANAGER_URL"
         # Construct the Secrets Manager Console URL directly here
         value = "https://cloud.ibm.com/resources/instance/${urlencode(ibm_resource_instance.secrets_manager_instance.id)}"
       }
       run_env_variables {
          name = "DEPLOYED_REGION"
          value = var.region
        }

  # Service Bindings (keep this)
  service_bindings {
    service_instance_id = ibm_resource_instance.secrets_manager_instance.id
    role                = "SecretsReader" # Changed to minimal required role
  }

  # Build config (keep this)
  build {
    # ... (as before) ...
  }

  depends_on = [
    # ... (keep existing depends_on) ...
  ]
}

# --- Need a way to get the final Code Engine App Name ---
# Code Engine often adds a random suffix to the app name.
# We need to read it back to construct the correct console URL.
data "ibm_code_engine_app" "helper_app_data" {
    project_id = ibm_code_engine_project.ce_project.id
    name       = var.helper_app_name # Use the base name provided
    # Ensure the app resource exists before reading its data
    depends_on = [ibm_code_engine_app.helper_app]
}

locals {
  # Extract the actual deployed name from the data source
  helper_app_ce_name = data.ibm_code_engine_app.helper_app_data.name
}

# ... (rest of main.tf) ...

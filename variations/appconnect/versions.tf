terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # Using the latest known stable version as of late Oct 2025.
      # Replace with the absolute latest if needed.
      version = "~> 1.84.0" 
    }
    random = {
      source = "hashicorp/random"
      # Using the latest known stable version as of late Oct 2025.
      # Replace with the absolute latest if needed.
      version = "~> 3.6.2" 
    }
  }
  # You can adjust the minimum Terraform version if your code requires newer features
  required_version = ">= 1.3.0" 
}
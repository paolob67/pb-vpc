##############################################################################
# Terraform Providers
##############################################################################

Uncomment this block when using with Terraform v 0.13 or higher
terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.31.0"
    }
  }
}

##############################################################################


##############################################################################
# Provider
##############################################################################

provider ibm {
  # Uncomment ibmcloud_api_key when using standalone
  # ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibm_region
  ibmcloud_timeout = 60
}

##############################################################################

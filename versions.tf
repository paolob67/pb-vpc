##############################################################################
# Terrafrom and proder versions
##############################################################################

terraform {
  required_version = ">= 0.14"
  # Uncomment this block when using with Terraform v 0.13 or higher
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.31.0"
    }
  }
}
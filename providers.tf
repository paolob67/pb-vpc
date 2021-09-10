##############################################################################
# Providers for this project
##############################################################################

# Load IBMCloud Provider
provider ibm {
  # Uncomment ibmcloud_api_key when using standalone
  # ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibm_region
  ibmcloud_timeout = 60
}

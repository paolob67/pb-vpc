##############################################################################
# Variables that will show up in the schematics UI
##############################################################################

# target region
variable "ibm_region" {
  description = "IBM Cloud region where all resources will be deployed"
  default = "eu-de"
}

# Resource Group to hold resources 
variable "resource_group_name" {
  description = "Name of IBM Cloud Resource Group used for all VPC resources"
  default     = "Default"
}

# unique name for the VPC in the account 
variable "vpc_name" {
  description = "Name of vpc"
  default     = "pb-vpc"
}

# public key name for bastion host access 
variable "ssh_key_name" {
  description = "Public key name for VPC - VSI access to be used to coinnect to bastion"
}

##############################################################################
# Variables to set when running standalone
##############################################################################

# IBMCLoud API Key to use when running standalone
# variable "ibmcloud_api_key" {
#   description = "IBM Cloud API key when run standalone"
# }
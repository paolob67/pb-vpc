##############################################################################
# This module defines the VPC network
# VPC, Subnets
##############################################################################

##############################################################################
# Create VPC 
##############################################################################
data "ibm_resource_group" "all_rg" {
  name = var.resource_group_name
}

resource "ibm_is_vpc" "vpc" {
  name                      = var.vpc_name
  resource_group            = data.ibm_resource_group.all_rg.id
  # address_prefix_management = "manual"
}

##############################################################################
# Create Subnets
##############################################################################

resource "ibm_is_subnet" "management_subnet" {
  vpc             = ibm_is_vpc.vpc.id
}

resource "ibm_is_subnet" "frontend_subnet" {
  vpc             = ibm_is_vpc.vpc.id
  public_gateway = ibm_is_public_gateway.repo_gateway[count.index].id
}

resource "ibm_is_subnet" "backend_subnet" {
  vpc             = ibm_is_vpc.vpc.id
}

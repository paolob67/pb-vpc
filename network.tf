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
# Create Public gateway for front-end subnet
##############################################################################
resource "ibm_is_public_gateway" "public_gateway" {
  name  = "front-end-gateway"
  vpc   = ibm_is_vpc.vpc.id
  zone  = "${var.ibm_region}-1"
  timeouts {
    create = "90m"
  }
}

##############################################################################
# Create Subnets
##############################################################################
resource "ibm_is_subnet" "management_subnet" {
  vpc             = ibm_is_vpc.vpc.id
  name            = "management-subnet"
  zone            = "${var.ibm_region}-1"
}

resource "ibm_is_subnet" "frontend_subnet" {
  vpc             = ibm_is_vpc.vpc.id
  name            = "frontend-subnet"
  zone            = "${var.ibm_region}-1"
  public_gateway  = ibm_is_public_gateway.public_gateway.id
}

resource "ibm_is_subnet" "backend_subnet" {
  vpc             = ibm_is_vpc.vpc.id
  name            = "backend-subnet"
  zone            = "${var.ibm_region}-1"
}

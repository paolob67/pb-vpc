##############################################################################
# This module defines the VPC network
# VPC, Internet gateway, Subnets, Load Balancer
##############################################################################

##############################################################################
# Create VPC 
##############################################################################
data "ibm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "ibm_is_vpc" "vpc" {
  name                      = var.vpc_name
  resource_group            = data.ibm_resource_group.rg.id
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
  vpc                       = ibm_is_vpc.vpc.id
  name                      = "management-subnet"
  zone                      = "${var.ibm_region}-1"
  total_ipv4_address_count  = 32
}

resource "ibm_is_subnet" "frontend_subnet" {
  vpc                       = ibm_is_vpc.vpc.id
  name                      = "frontend-subnet"
  zone                      = "${var.ibm_region}-1"
  total_ipv4_address_count  = 16
  public_gateway            = ibm_is_public_gateway.public_gateway.id
}

resource "ibm_is_subnet" "backend_subnet" {
  vpc                       = ibm_is_vpc.vpc.id
  name                      = "backend-subnet" 
  zone                      = "${var.ibm_region}-1"
  total_ipv4_address_count  = 16
}

##############################################################################
# Create Load Balancer
##############################################################################
resource "ibm_is_lb" "load_balancer" {
  name           = "load-balancer"
  type           = "public"
  subnets        = ibm_is_subnet.frontend_subnet.id
  resource_group = data.ibm_resource_group.rg.id
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

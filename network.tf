##############################################################################
# This module defines the VPC network
# VPC, Internet gateway, Subnets, Load Balancer
##############################################################################

##############################################################################
# Create VPC 
##############################################################################
# get the resource group id from the passed resource group name
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
# Create Load Balancer for the front-end subnet
##############################################################################
resource "ibm_is_lb" "load_balancer" {
  name           = "load-balancer"
  type           = "public"
  subnets        = [ ibm_is_subnet.frontend_subnet.id ]
  resource_group = data.ibm_resource_group.rg.id
  timeouts {
    create       = "15m"
    delete       = "15m"
  }
  depends_on     = [ ibm_is_subnet.frontend_subnet ]
}

resource "ibm_is_lb_pool" "back_end_pool" {
  lb                 = ibm_is_lb.load_balancer.id
  name               = "back-end-pool"
  protocol           = "http"
  algorithm          = "round_robin"
  health_delay       = "5"
  health_retries     = "2"
  health_timeout     = "2"
  health_type        = "http"
  health_monitor_url = "/"
  depends_on         = [ ibm_is_lb.load_balancer ]
}

/* TODO: redirect listener http->https*/
/* TODO: HTTPS listener instead of HTTP*/
resource "ibm_is_lb_listener" "front_end_listener" {
  lb           = ibm_is_lb.load_balancer.id
  port         = "80"
  protocol     = "http"
  default_pool = ibm_is_lb_pool.back_end_pool.id
  depends_on   = [ ibm_is_lb_pool.back_end_pool ]
}


/* TODO: will need to attach servers to the backend pool compute module... */
/*
resource "ibm_is_lb_pool_member" "webapptier-lb-pool-member-zone1" {
  count          = var.frontend_count
  lb             = ibm_is_lb.webapptier-lb.id
  pool           = element(split("/", ibm_is_lb_pool.webapptier-lb-pool.id), 1)
  port           = "8080"
  target_address = ibm_is_instance.frontend-server[count.index].primary_network_interface[0].primary_ipv4_address
  depends_on     = [ibm_is_lb_pool.webapptier-lb-pool]
}
*/

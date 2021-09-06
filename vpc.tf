##############################################################################
# VPC definition
##############################################################################

resource "ibm_is_vpc" "vpc" {
  name                      = var.vpc_name
  resource_group            = var.resource_group_name
}
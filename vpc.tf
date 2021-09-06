##############################################################################
# VPC definition
##############################################################################
data "ibm_resource_group" "all_rg" {
  name = var.resource_group_name
}

resource "ibm_is_vpc" "vpc" {
  name                      = var.unique_id
  resource_group            = data.ibm_resource_group.all_rg.id
  # address_prefix_management = "manual"
}

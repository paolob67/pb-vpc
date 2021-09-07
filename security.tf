##############################################################################
# This module defines the three security groups 
# Bastion, FrontEnd, BackEnd
##############################################################################

##############################################################################
# Bastion
# Allow SSH connections from outside (might want to restrict that) 
##############################################################################
# TODO: use to restrict from subnetipv4_cidr_block
resource "ibm_is_security_group" "bastion_security_group" {
  name = "bastion-security-group"
  vpc   = ibm_is_vpc.vpc.id
}

# open SSH port for all incoming connections (could be restricetd to whitelist)
resource "ibm_is_security_group_rule" "bastion_allow_ssh" {
  group     = ibm_is_security_group.bastion_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

##############################################################################
# FrontEnd
# Allow TCP/8080 from outside (could be restriced to LB ip addresses)
##############################################################################
# TODO: use to restrict from subnetipv4_cidr_block
resource "ibm_is_security_group" "frontend_security_group" {
  name = "frontend-security-group"
  vpc   = ibm_is_vpc.vpc.id
}

# open SSH port for all incoming connections (could be restricetd to whitelist)
resource "ibm_is_security_group_rule" "frontend_allow_http" {
  group     = ibm_is_security_group.bastion_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 8080
    port_max = 8080
  }
}

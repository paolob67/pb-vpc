##############################################################################
# This module defines the three security groups 
# Bastion, FrontEnd, BackEnd
##############################################################################

##############################################################################
# Bastion
# Allow SSH connections from outside (might want to restrict that) 
##############################################################################
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
# Allow 8080/TCP from outside (could be restriced to LB ip addresses)
# Allow 22/TCP from bastion
##############################################################################
resource "ibm_is_security_group" "frontend_security_group" {
  name = "frontend-security-group"
  vpc   = ibm_is_vpc.vpc.id
}

# open HTTP 8080 port for all incoming connections (could be restricetd to LB)
resource "ibm_is_security_group_rule" "frontend_allow_http" {
  group     = ibm_is_security_group.frontend_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 8080
    port_max = 8080
  }
}
# open SSH port for incoming connections from bastion subnet
resource "ibm_is_security_group_rule" "frontend_allow_ssh" {
  group     = ibm_is_security_group.frontend_security_group.id
  direction = "inbound"
  remote    = ibm_is_subnet.bastion_subnet.ipv4_cidr_block
  tcp {
    port_min = 22
    port_max = 22
  }
}

##############################################################################
# BackEnd
# Allow 3306/TCP from frontend subnet
# Allow 22/TCP from bastion
##############################################################################
resource "ibm_is_security_group" "backend_security_group" {
  name = "backend-security-group"
  vpc   = ibm_is_vpc.vpc.id
}

# open MySql port for incoming connections from front end
resource "ibm_is_security_group_rule" "backend_allow_mysql" {
  group     = ibm_is_security_group.backend_security_group.id
  direction = "inbound"
  remote    = ibm_is_subnet.frontend_subnet.ipv4_cidr_block
  tcp {
    port_min = 3306
    port_max = 3306
  }
}
# open SSH port for incoming connections from bastion subnet
resource "ibm_is_security_group_rule" "backend_allow_ssh" {
  group     = ibm_is_security_group.backend_security_group.id
  direction = "inbound"
  remote    = ibm_is_subnet.bastion_subnet.ipv4_cidr_block
  tcp {
    port_min = 22
    port_max = 22
  }
}

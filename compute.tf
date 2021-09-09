##############################################################################
# This module defines the compute resorces
# Bastion, Frontend and Backend servers
##############################################################################

##############################################################################
# Create Bastion host attached to floating IP, single network IF
# Using this for EU-de
#  - r010-3bef996a-0dd4-48cc-b857-fd03e8dfa0db   
#    (ibm-centos-8-3-minimal-amd64-3 centos-8-amd64)
##############################################################################
# Retrieve puyblic key for SSH
data "ibm_is_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}
# Retrieve image id for centos-8-amd64
data "ibm_is_image" "bastion_host_image" {
  name = "ibm-centos-8-3-minimal-amd64-3"
}
# Create bastion instance
resource "ibm_is_instance" "bastion_host" {
  name              = "bastion-host"
  vpc               = ibm_is_vpc.vpc.id
  image             = data.ibm_is_image.bastion_host_image.id
  profile           = "cx2-2x4"
  primary_network_interface {
    subnet          = ibm_is_subnet.bastion_subnet.id
    security_groups = [ ibm_is_security_group.bastion_security_group.id ]
  }
  timeouts {
    create          = "10m"
    delete          = "10m"
  }
  zone              = "${var.ibm_region}-1"
  resource_group    = data.ibm_resource_group.rg.id
  keys              = [ data.ibm_is_ssh_key.ssh_key.id ]
}

# Add floating address to bastion
resource "ibm_is_floating_ip" "bastion_floating_ip" {
  name   = "bastion-floating-ip"
  target = ibm_is_instance.bastion_host.primary_network_interface[0].id
}

##############################################################################
# Create Front end server farm
# Using this for EU-de
#  - r010-3bef996a-0dd4-48cc-b857-fd03e8dfa0db   
#    (ibm-centos-8-3-minimal-amd64-3 centos-8-amd64)
##############################################################################
# Retrieve image id for centos-8-amd64
data "ibm_is_image" "frontend_host_image" {
  name = "ibm-centos-8-3-minimal-amd64-3"
}

# Define instance template
resource "ibm_is_instance_template" "frontend_template" {
  name              = "frontend-template"
  vpc               = ibm_is_vpc.vpc.id
  image             = data.ibm_is_image.frontend_host_image.id
  profile           = "bx2-2x8"
  primary_network_interface {
    subnet          = ibm_is_subnet.frontend_subnet.id
    security_groups = [ ibm_is_security_group.frontend_security_group.id ]
  }
  zone              = "${var.ibm_region}-1"
  resource_group    = data.ibm_resource_group.rg.id
  keys              = [ data.ibm_is_ssh_key.ssh_key.id ]
}

# Define instance group
resource "ibm_is_instance_group" "frontend_group" {
  name               = "frontend-group"
  instance_template  = ibm_is_instance_template.frontend_template.id
  instance_count     = 1
  subnets            = [ibm_is_subnet.frontend_subnet.id]
  application_port   = 8080
  load_balancer      = ibm_is_lb.load_balancer.id
  load_balancer_pool = element(split("/", ibm_is_lb_pool.back_end_pool.id), 1)
  timeouts {
    create           = "15m"
    delete           = "15m"
    update           = "10m"
  }
  depends_on         = [ ibm_is_lb.load_balancer, ibm_is_lb_pool.back_end_pool ]
}

# Define scaling strategy to max 2 servers
resource "ibm_is_instance_group_manager" "frontend_group_manager" {
  name                 = "frontend-group-manager"
  aggregation_window   = 90
  instance_group       = ibm_is_instance_group.frontend_group.id
  cooldown             = 120
  manager_type         = "autoscale"
  enable_manager       = true
  min_membership_count = 1
  max_membership_count = 2
}

# Define a scaling policy based on CPU usage
resource "ibm_is_instance_group_manager_policy" "frontend_cpu_policy" {
  name                   = "frontend-cpu-policy"
  instance_group         = ibm_is_instance_group.frontend_group.id
  instance_group_manager = ibm_is_instance_group_manager.frontend_group_manager.manager_id
  metric_type            = "cpu"
  metric_value           = 10
  policy_type            = "target"
}

# NOTE: FOX FIX
# https://github.com/IBM-Cloud/vpc-tutorials/blob/master/vpc-autoscale/main.tf
#  - load_balancer_pool = ibm_is_lb_pool.back_end_pool.id
#  + load_balancer_pool = element(split("/", ibm_is_lb_pool.back_end_pool.id), 1)
# the above statement produces
#   load_balancer_pool = "r010-58eacd58-64a9-4d27-8e7e-5216580c072f/r010-191a65c1-5904-45d8-9fee-6f630b496f8b"
# while element(split("/", ibm_is_lb_pool.back_end_pool.id), 1)
# will produce
#   load_balancer_pool = "r010-191a65c1-5904-45d8-9fee-6f630b496f8b"

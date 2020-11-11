# Support
dependency "resource_group" {
  config_path = "../resource_group"
}

dependency "subnet_fn3support" {
  config_path = "../functions_backoffice/subnet"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_route_table"
}

inputs = {
  name                          = "centro-stella"
  resource_group_name           = dependency.resource_group.outputs.resource_name
  disable_bgp_route_propagation = false

  subnet_id = dependency.subnet_fn3support.outputs.id

  routes = [{
    name                   = "to-centro-stella-subnet"
    address_prefix         = "10.70.132.0/24"
    next_hop_type          = "VirtualNetworkGateway"
    next_hop_in_ip_address = null
  }]
}

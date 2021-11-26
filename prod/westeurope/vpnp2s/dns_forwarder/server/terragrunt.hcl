dependency "virtual_network" {
  config_path = "../../virtual_network"
}

dependency "subnet" {
  config_path = "../subnet"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_dns_forwarder?ref=update-azurerm-v2.87.0"
}

inputs = {
  name                = "dns-forwarder-vpnp2s"
  resource_group_name = dependency.virtual_network.outputs.resource_group_name
  subnet_id           = dependency.subnet.outputs.id
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_subnet?ref=v4.0.0"
}

inputs = {
  name                 = "vml-instabug-snet"
  resource_group_name  = "io-p-rg-vpnp2s"
  virtual_network_name = "io-p-vnet-vpnp2s"
  address_prefix       = "10.1.2.0/24"
}

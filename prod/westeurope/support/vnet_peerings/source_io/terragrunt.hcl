# common
dependency "key_vault" {
  config_path = "../../../common/key_vault"
}


# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_virtual_network_peering_multitenant?ref=v2.1.7"
}

inputs = {
  name                               = "support-centro-stella"
  resource_group_name                = "io-p-rg-support"                #TODO: read the name from a dependency.
  virtual_network_name               = "io-p-vnet-support"              #TODO: read the name form a dependency.
  key_vault_id                       = dependency.key_vault.outputs.id
  remote_virtual_network_secret_name = "U87-DATABASE-PROD-VNET-ID"
}

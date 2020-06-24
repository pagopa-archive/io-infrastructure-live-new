# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Subnets
dependency "subnet_func_bonus" {
  config_path = "../../functions_bonus/subnet/"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_account?ref=v2.0.27"
}

inputs = {
  name                     = "bonus"
  resource_group_name      = dependency.resource_group.outputs.resource_name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  network_rules = {
    default_action             = "Deny"
    bypass                     = null
    ip_rules                   = [""]
    virtual_network_subnet_ids = [dependency.subnet_func_bonus.outputs.id]
  }
}

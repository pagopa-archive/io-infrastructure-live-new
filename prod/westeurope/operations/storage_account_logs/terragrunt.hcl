# Internal
dependency "resource_group" {
  config_path = "../resource_group"
}

# Subnets
dependency "subnet_io-p-fn3-app" {
  config_path = "../../internal/api/functions_app_r3/subnet/"
}

dependency "subnet_func_app" {
  config_path = "../../internal/api/functions_app/subnet/"
}

dependency "subnet_abbbackend" {
  config_path = "../../internal/appbackend/subnet/"
}

dependency "subnet_abbbackendbonus" {
  config_path = "../../internal/appbackend_bonus/subnet/"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_account?ref=v2.0.32"
}

inputs = {
  name                     = "logs"
  resource_group_name      = dependency.resource_group.outputs.resource_name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  network_rules = {
    default_action             = "Deny"
    bypass                     = null
    ip_rules                   = [""]
    virtual_network_subnet_ids = [
      dependency.subnet_io-p-fn3-app.outputs.id,
      dependency.subnet_func_app.outputs.id,
      dependency.subnet_abbbackend.outputs.id,
      dependency.subnet_abbbackendbonus.outputs.id
      ]
  }
}

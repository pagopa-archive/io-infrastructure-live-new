# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Subnets
dependency "subnet_io-p-fn3-app" {
  config_path = "../../functions_app_r3/subnet/"
}

dependency "subnet_func_admin" {
  config_path = "../../functions_admin/subnet/"
}

dependency "subnet_func_app" {
  config_path = "../../functions_app/subnet/"
}

dependency "subnet_func_public" {
  config_path = "../../functions_public/subnet/"
}

dependency "subnet_func_services" {
  config_path = "../../functions_services/subnet/"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_account?ref=v2.0.32"
}

inputs = {
  name                     = "api"
  resource_group_name      = dependency.resource_group.outputs.resource_name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  network_rules = {
    default_action = "Deny"
    bypass         = null
    ip_rules       = [""]
    virtual_network_subnet_ids = [dependency.subnet_io-p-fn3-app.outputs.id,
      dependency.subnet_func_admin.outputs.id,
      dependency.subnet_func_app.outputs.id,
      dependency.subnet_func_public.outputs.id,
      dependency.subnet_func_services.outputs.id
    ]
  }

}

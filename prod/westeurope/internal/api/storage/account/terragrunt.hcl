# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "subnet_fn_admin" {
  config_path = "../../functions_admin_r3/subnet"
}

dependency "subnet_fn_appasync" {
  config_path = "../../functions_app_async/subnet"
}

dependency "subnet_fn_app1" {
  config_path = "../../../../functions_app1/functions_app1_r3/subnet"
}

dependency "subnet_fn_app2" {
  config_path = "../../functions_app2_r3/subnet"
}

dependency "subnet_fn_assets" {
  config_path = "../../functions_assets_r3/subnet"
}

dependency "subnet_fn_public" {
  config_path = "../../functions_public_r3/subnet"
}

dependency "subnet_fn_services" {
  config_path = "../../functions_services_r3/subnet"
}

dependency "subnet_fn_servicescache" {
  config_path = "../../functions_servicescache_r3/subnet"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_account?ref=v3.0.3"
}

inputs = {
  name                     = "api"
  resource_group_name      = dependency.resource_group.outputs.resource_name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"
  enable_versioning        = true

  network_rules = {
    default_action = "Deny"
    ip_rules       = []
    bypass = [
      "Logging",
      "Metrics",
      "AzureServices",
    ]
    virtual_network_subnet_ids = [
      dependency.subnet_fn_admin.outputs.id,
      dependency.subnet_fn_appasync.outputs.id,
      dependency.subnet_fn_app1.outputs.id,
      dependency.subnet_fn_app2.outputs.id,
      dependency.subnet_fn_assets.outputs.id,
      dependency.subnet_fn_public.outputs.id,
      dependency.subnet_fn_services.outputs.id,
      dependency.subnet_fn_servicescache.outputs.id,
    ]
  }
}

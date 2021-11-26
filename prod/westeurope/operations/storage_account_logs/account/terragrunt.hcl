# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_account?ref=update-azurerm-v2.87.0"
}

inputs = {
  name                     = "logs"
  resource_group_name      = dependency.resource_group.outputs.resource_name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  enable_versioning = true

  lock = {
    name       = "storage-logs"
    lock_level = "CanNotDelete"
    notes      = null
  }
}

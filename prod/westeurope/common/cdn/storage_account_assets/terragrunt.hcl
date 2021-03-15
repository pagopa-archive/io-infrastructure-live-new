dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_account_static_website?ref=v3.0.0"
}

inputs = {
  name                     = "cdnassets"
  resource_group_name      = dependency.resource_group.outputs.resource_name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"
  index_document           = "index.html"
  enable_versioning        = true

  lock = {
    name       = "storage-assets"
    lock_level = "CanNotDelete"
    notes      = null
  }
}

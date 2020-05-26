dependency "storage_account" {
  config_path = "../storage_account_assets"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_container?ref=v2.0.25"
}

inputs = {
  name                  = "status"
  container_access_type = "blob"
  storage_account_name  = dependency.storage_account.outputs.resource_name
}

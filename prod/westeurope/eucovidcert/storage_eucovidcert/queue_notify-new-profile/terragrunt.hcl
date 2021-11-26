dependency "storage_account" {
  config_path = "../account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_queue?ref=update-azurerm-v2.87.0"
}

inputs = {
  name                 = "notify-new-profile"
  storage_account_name = dependency.storage_account.outputs.resource_name
}

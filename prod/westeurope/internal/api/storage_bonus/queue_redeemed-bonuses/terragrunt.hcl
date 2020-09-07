dependency "storage_account" {
  config_path = "../account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_queue?ref=v2.0.37"
}

inputs = {
  name                  = "redeemed-bonuses"
  storage_account_name  = dependency.storage_account.outputs.resource_name
}

#
# A table containing the current snapshot of Citizen which claims for download and delete of their data has failed
#

dependency "storage_account" {
  config_path = "../account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_table?ref=v3.0.3"
}

inputs = {
  name                 = "FailedUserDataProcessing"
  storage_account_name = dependency.storage_account.outputs.resource_name
}

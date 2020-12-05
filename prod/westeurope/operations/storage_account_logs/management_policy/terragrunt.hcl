# Internal
dependency "storage_account" {
  config_path = "../account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_management_policy?ref=v2.1.0"
}

inputs = {
  storage_account_id = dependency.storage_account.outputs.id

  rules = [
    {
      name    = "deleteafter2yrs"
      enabled = true
      filters = {
        prefix_match = ["spidassertions"]
        blob_types   = ["blockBlob"]
      }
      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than    = 0
          tier_to_archive_after_days_since_modification_greater_than = 0
          delete_after_days_since_modification_greater_than          = 730 # ~ 2 years
        }
        snapshot = null
      }
    }
  ]
}

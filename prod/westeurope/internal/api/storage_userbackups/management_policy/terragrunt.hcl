# Internal
dependency "storage_account" {
  config_path = "../account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_storage_management_policy?ref=v2.0.25"
}

inputs = {
  storage_account_id   = dependency.storage_account.outputs.id

  rules = [
    {
      name = "deleteafter3yrs"
      enabled = true
      filters = {
        prefix_match = ["user-data-backup"]
        blob_types   = ["blockBlob"]
      }
      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than    = 0
          tier_to_archive_after_days_since_modification_greater_than = 0
          delete_after_days_since_modification_greater_than          = 1095 # ~ 3 years
        }
        snapshot = null
      }
    }
  ]
}

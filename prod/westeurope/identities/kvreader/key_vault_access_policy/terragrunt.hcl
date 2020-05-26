dependency "user_assigned_identity" {
  config_path = "../user_assigned_identity"
}

# Common
dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_key_vault_access_policy?ref=v2.0.25"
}

inputs = {
  key_vault_id = dependency.key_vault.outputs.id
  object_id    = dependency.user_assigned_identity.outputs.principal_id

  key_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get",
    "List"
  ]

  certificate_permissions = [
    "Get",
    "List"
  ]
}

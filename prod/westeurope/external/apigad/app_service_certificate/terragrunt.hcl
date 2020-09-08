dependency "resource_group" {
  config_path = "../../resource_group"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service_certificate?ref=v2.0.37"
}

inputs = {
  name                = "apigad"
  resource_group_name = dependency.resource_group.outputs.resource_name
  key_vault_id        = dependency.key_vault.outputs.id
  certificate_name    = "api-gad-io-italia-it"
}

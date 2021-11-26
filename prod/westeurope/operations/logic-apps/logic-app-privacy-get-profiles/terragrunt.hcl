dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_logic_app?ref=update-azurerm-v2.87.0"
}

inputs = {
  name                = "privacy-get-profiles"
  resource_group_name = dependency.resource_group.outputs.resource_name
  parameters = {
    "$connections"              = ""
    "cosmos-container-profiles" = "profiles"
    "cosmos-db"                 = "db"
  }
  parameters_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      googlesheet-gid = "lapp-privacy-googlesheet-gid"
      googlesheet-id  = "lapp-privacy-googlesheet-id"
    }
  }
}

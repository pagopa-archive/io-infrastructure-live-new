dependency "resource_group" {
  config_path = "../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "key_vault" {
  config_path = "../key_vault"
}


terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_notification_hub?ref=v0.0.37"
}

inputs = {
  name                                  = "common"
  resource_group_name                   = dependency.resource_group.outputs.resource_name
  key_vault_id                          = dependency.key_vault.outputs.id
  ntfns_namespace_type                  = "NotificationHub"
  ntfns_sku_name                        = "Standard"
  ntf_apns_credential_application_mode  = "Production"
}

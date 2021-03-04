dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "notification_hubns" {
  config_path = "../namespace"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "key_vault" {
  config_path = "../../key_vault"
}


terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_notification_hub?ref=v2.1.36"
}

inputs = {
  name                = "common"
  resource_group_name = dependency.resource_group.outputs.resource_name
  namespace_name      = dependency.notification_hubns.outputs.name
  key_vault_id        = dependency.key_vault.outputs.id

  ntf_apns_credential_application_mode = "Production"

  # google api key
  gcm_credential_api_key = "notification-hub-01-gc-m-key"

  apns_credential_bundle_id = "notification-hub-01-bundle-id"
  apns_credential_key_id    = "notification-hub-01-key-id"
  apns_credential_team_id   = "notification-hub-01-team-id"
  apns_credential_token     = "notification-hub-01-token"
}

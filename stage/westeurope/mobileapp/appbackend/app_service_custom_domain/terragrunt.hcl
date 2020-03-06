dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "dns_zone" {
  config_path = "../../../common/dns_zone"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

dependency "app_service" {
  config_path = "../app_service"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service_custom_domain?ref=v0.0.25"
}

inputs = {
  resource_group_name = dependency.resource_group.outputs.resource_name
  custom_domain       = {
    name                     = "app-backend"
    zone_name                = dependency.dns_zone.outputs.name
    zone_resource_group_name = dependency.dns_zone.outputs.resource_group_name
    key_vault_id             = dependency.key_vault.outputs.id
    certificate_name         = "STAGE-IO-ITALIA-IT"
  }
  app_service_name      = dependency.app_service.outputs.resource_name
  default_site_hostname = dependency.app_service.outputs.default_site_hostname
}

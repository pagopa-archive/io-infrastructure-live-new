dependency "app_service" {
  config_path = "../app_service"
}

dependency "app_service_certificate" {
  config_path = "../app_service_certificate"
}

// External
dependency "resource_group" {
  config_path = "../../resource_group"
}

// Infra
dependency "dns_zone" {
  config_path = "../../../infra/public_dns_zone"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service_custom_domain?ref=v4.0.1"
}

inputs = {
  name                = "pagopaproxytest"
  resource_group_name = dependency.resource_group.outputs.resource_name

  custom_domain = {
    name                     = "pagopaproxytest"
    zone_name                = dependency.dns_zone.outputs.name
    zone_resource_group_name = dependency.dns_zone.outputs.resource_group_name
    certificate_thumbprint   = dependency.app_service_certificate.outputs.thumbprint
  }

  app_service_name      = dependency.app_service.outputs.name
  default_site_hostname = dependency.app_service.outputs.default_site_hostname
}

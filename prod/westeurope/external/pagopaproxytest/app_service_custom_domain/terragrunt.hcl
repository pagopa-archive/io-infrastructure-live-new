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

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service_custom_domain?ref=v2.1.0"
}

inputs = {
  name                = "pagopaproxytest"
  resource_group_name = dependency.resource_group.outputs.resource_name

  custom_domain = {
    name                     = "pagopaproxytest"
    zone_name                = "io.italia.it"
    zone_resource_group_name = "io-infra-rg"
    certificate_thumbprint   = dependency.app_service_certificate.outputs.thumbprint
  }

  app_service_name      = dependency.app_service.outputs.name
  default_site_hostname = dependency.app_service.outputs.default_site_hostname
}

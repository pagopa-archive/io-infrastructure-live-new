dependency "app_service" {
  config_path = "../app_service"
}

// External
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "app_service_certificate" {
  config_path = "../../app_service_certificate"
}

// Common
dependency "dns_zone" {
  config_path = "../../../common/dns_zone"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service_custom_domain?ref=v2.0.25"
}

inputs = {
  name                = "apigad"
  resource_group_name = dependency.resource_group.outputs.resource_name

  custom_domain = {
    name                     = "api-gad"
    zone_name                = "io.italia.it"
    zone_resource_group_name = "io-infra-rg"
    certificate_thumbprint   = dependency.app_service_certificate.outputs.thumbprint
  }

  ssl_state             = "IpBasedEnabled"
  app_service_name      = dependency.app_service.outputs.name
  default_site_hostname = dependency.app_service.outputs.default_site_hostname
}

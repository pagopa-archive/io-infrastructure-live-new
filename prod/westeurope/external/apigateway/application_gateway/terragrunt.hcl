dependency "public_ip" {
  config_path = "../public_ip"
}

# External
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Identities
dependency "user_assigned_identity_kvreader" {
  config_path = "../../../identities/kvreader/user_assigned_identity"
}

# Internal
dependency "api_management" {
  config_path = "../../../internal/api/apim/api_management"
}

dependency "app_service_developerportalbackend" {
  config_path = "../../../internal/developerportalbackend/app_service"
}

# Common
dependency "virtual_network" {
  config_path = "../../../common/virtual_network"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

dependency "dns_zone" {
  config_path = "../../../common/dns_zone"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_application_gateway?ref=v0.0.43"
}

inputs = {
  name                = "apigateway"
  resource_group_name = dependency.resource_group.outputs.resource_name

  sku = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  public_ip_info = {
    id = dependency.public_ip.outputs.id
    ip = dependency.public_ip.outputs.ip_address
  }

  virtual_network_info = {
    resource_group_name   = dependency.virtual_network.outputs.resource_group_name
    name                  = dependency.virtual_network.outputs.resource_name
    subnet_address_prefix = "10.0.0.128/25"
  }

  frontend_port = 443

  custom_domains = {
    zone_name                = "io.italia.it"
    zone_resource_group_name = "io-infra-rg"
    identity_id              = dependency.user_assigned_identity_kvreader.outputs.id
    keyvault_id              = dependency.key_vault.outputs.id
    certificate_name         = "io-italia-it"
  }

  services = [
    {
      name          = "apim"
      a_record_name = "api"

      http_listener = {
        protocol  = "Https"
        host_name = "api.io.italia.it"
      }

      backend_address_pool = {
        ip_addresses = null
        fqdns        = ["api-internal.io.italia.it"]
      }

      probe = {
        host                = "api-internal.io.italia.it"
        protocol            = "Http"
        path                = "/status-0123456789abcdef"
        interval            = 30
        timeout             = 120
        unhealthy_threshold = 8
      }

      backend_http_settings = {
        protocol              = "Http"
        port                  = 80
        path                  = "/"
        cookie_based_affinity = "Disabled"
        request_timeout       = 180
        host_name             = "api-internal.io.italia.it"
      }
    },
    {
      name          = "developerportalbackend"
      a_record_name = "developerportal-backend"

      http_listener = {
        protocol  = "Https"
        host_name = "developerportal-backend.io.italia.it"
      }

      backend_address_pool = {
        ip_addresses = null
        fqdns        = [dependency.app_service_developerportalbackend.outputs.default_site_hostname]
      }

      probe = {
        host                = dependency.app_service_developerportalbackend.outputs.default_site_hostname
        protocol            = "Http"
        path                = "/info"
        interval            = 30
        timeout             = 120
        unhealthy_threshold = 8
      }

      backend_http_settings = {
        protocol              = "Http"
        port                  = 80
        path                  = "/"
        cookie_based_affinity = "Disabled"
        request_timeout       = 180
        host_name             = dependency.app_service_developerportalbackend.outputs.default_site_hostname
      }
    }
  ]
}


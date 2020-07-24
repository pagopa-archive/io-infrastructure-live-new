dependency "public_ip" {
  config_path = "../public_ip"
}

dependency "subnet" {
  config_path = "../subnet"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_application_gateway?ref=v2.0.26"
}

inputs = {
  name                = "apigateway"
  resource_group_name = dependency.resource_group.outputs.resource_name

  sku = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 0
  }

  public_ip_info = {
    id = dependency.public_ip.outputs.id
    ip = dependency.public_ip.outputs.ip_address
  }

  subnet_id = dependency.subnet.outputs.id

  frontend_port = 443

  custom_domains = [{
    zone_name                = "io.italia.it"
    zone_resource_group_name = "io-infra-rg"
    identity_id              = dependency.user_assigned_identity_kvreader.outputs.id
    keyvault_id              = dependency.key_vault.outputs.id
    certificate_name         = "io-italia-it"  # api-io-italia-it
  },
  {
    zone_name                = "io.italia.it"
    zone_resource_group_name = "io-infra-rg"
    identity_id              = dependency.user_assigned_identity_kvreader.outputs.id
    keyvault_id              = dependency.key_vault.outputs.id
    certificate_name         = "prod-io-italia-it"
  },
  ]

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

  waf_configuration = {
    enabled                  = true
    firewall_mode            = "Detection"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.1"
    request_body_check       = true
    file_upload_limit_mb     = 100
    max_request_body_size_kb = 128

    disabled_rule_groups = []
  }

  autoscale_configuration = {
    min_capacity = 2
    max_capacity = 10
  }

}

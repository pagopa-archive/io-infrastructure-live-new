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

# Infra
dependency "dns_zone" {
  config_path = "../../../infra/public_dns_zone"
}

# Include all settings from the root terragrunt.hcl file

include {
  path = find_in_parent_folders()
}

locals {

  backend_name               = "appbackend"
  http_listener_name         = format("%s-%s", "httplistener", local.backend_name)
  backend_pool_name          = format("%s-%s", "backendaddresspool", local.backend_name)
  backend_http_settings_name = format("%s-%s", "backendhttpsettings", local.backend_name)
  probe_name                 = format("%s-%s", "probe", local.backend_name)
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_application_gateway?ref=v3.0.3"
}

inputs = {

  name = "apigateway"

  resource_group_name = dependency.resource_group.outputs.resource_name

  sku = {

    name = "WAF_v2"

    tier = "WAF_v2"

    capacity = 0

  }

  subnet_id = dependency.subnet.outputs.id

  backend_address_pools = [
    {
      name         = "backendaddresspool-apim"
      fqdns        = ["api-internal.io.italia.it"]
      ip_addresses = []
    },
    {
      name         = "backendaddresspool-developerportalbackend"
      fqdns        = ["io-p-app-developerportalbackend.azurewebsites.net"]
      ip_addresses = []
    }
  ]

  backend_http_settings = [{
    cookie_based_affinity               = "Disabled"
    affinity_cookie_name                = null
    name                                = "backendhttpsettings-apim"
    path                                = "/"
    port                                = 80
    probe_name                          = "probe-apim"
    protocol                            = "HTTP"
    request_timeout                     = 180
    host_name                           = "api-internal.io.italia.it"
    pick_host_name_from_backend_address = false
    trusted_root_certificate_names      = null
    connection_draining                 = null
    },

    {
      cookie_based_affinity               = "Disabled"
      affinity_cookie_name                = null
      name                                = "backendhttpsettings-developerportalbackend"
      path                                = "/"
      pick_host_name_from_backend_address = false
      port                                = 80
      probe_name                          = "probe-developerportalbackend"
      protocol                            = "Http"
      request_timeout                     = 180
      host_name                           = "io-p-app-developerportalbackend.azurewebsites.net"
      trusted_root_certificate_names      = null
      connection_draining                 = null
  }]

  probes = [{
    name                                      = format("%s-%s", "probe", "apim")
    host                                      = "api-internal.io.italia.it"
    protocol                                  = "Http"
    path                                      = "/status-0123456789abcdef"
    interval                                  = 30
    timeout                                   = 120
    unhealthy_threshold                       = 8
    pick_host_name_from_backend_http_settings = false
    },
    {
      name                                      = format("%s-%s", "probe", "developerportalbackend")
      host                                      = "io-p-app-developerportalbackend.azurewebsites.net"
      protocol                                  = "Http"
      path                                      = "/info"
      interval                                  = 30
      timeout                                   = 120
      unhealthy_threshold                       = 8
      pick_host_name_from_backend_http_settings = false
    },
  ]

  frontend_ip_configurations = [{
    name                          = "frontendipconfiguration"
    subnet_id                     = null
    private_ip_address            = null
    public_ip_address_id          = dependency.public_ip.outputs.id
    public_ip_address             = dependency.public_ip.outputs.ip_address
    private_ip_address_allocation = null
    a_record_name                 = "api"
    },
  ]

  optional_dns_a_records = [{
    name              = "developerportalbackend"
    public_ip_address = dependency.public_ip.outputs.ip_address
    a_record_name     = "developerportal-backend"
    },
  ]

  gateway_ip_configurations = [{
    name      = "gatewayipconfiguration"
    subnet_id = dependency.subnet.outputs.id
  }]

  http_listeners = [{
    name                           = "httplistener-apim"
    frontend_ip_configuration_name = "frontendipconfiguration"
    frontend_port_name             = "frontendport"
    protocol                       = "Https"
    host_name                      = "api.io.italia.it"
    ssl_certificate_name           = "api-io-italia-it"
    require_sni                    = true
    },
    {
      name                           = "httplistener-developerportalbackend"
      frontend_ip_configuration_name = "frontendipconfiguration"
      frontend_port_name             = "frontendport"
      protocol                       = "Https"
      host_name                      = "developerportal-backend.io.italia.it"
      ssl_certificate_name           = "developerportal-backend-io-italia-it"
      require_sni                    = true
  }]

  custom_domain = {
    zone_name                = dependency.dns_zone.outputs.name
    zone_resource_group_name = dependency.dns_zone.outputs.resource_group_name
    identity_id              = dependency.user_assigned_identity_kvreader.outputs.id
    keyvault_id              = dependency.key_vault.outputs.id
  }

  request_routing_rules = [{
    name                        = format("%s-%s", "requestroutingrule", "apim")
    rule_type                   = "Basic"
    http_listener_name          = "httplistener-apim"
    backend_address_pool_name   = "backendaddresspool-apim"
    backend_http_settings_name  = "backendhttpsettings-apim"
    redirect_configuration_name = null
    rewrite_rule_set_name       = "HttpHeader"
    url_path_map_name           = null
    },
    {
      name                        = format("%s-%s", "requestroutingrule", "developerportalbackend")
      rule_type                   = "Basic"
      http_listener_name          = "httplistener-developerportalbackend"
      backend_address_pool_name   = "backendaddresspool-developerportalbackend"
      backend_http_settings_name  = "backendhttpsettings-developerportalbackend"
      redirect_configuration_name = null
      rewrite_rule_set_name       = "HttpHeader"
      url_path_map_name           = null
  }]

  rewrite_rule_sets = [{
    name = "HttpHeader"
    rewrite_rules = [{
      name          = "CleanUpHeaders"
      rule_sequence = 100
      condition     = null
      request_header_configurations = [
        {
          header_name  = "X-Forwarded-For"
          header_value = "{var_client_ip}"
        },
        {
          header_name  = "X-Client-Ip"
          header_value = "{var_client_ip}"
        },
      ]
      response_header_configurations = []
    }]
  }]

  waf_configuration = {
    enabled                  = true
    firewall_mode            = "Detection"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.1"
    request_body_check       = true
    file_upload_limit_mb     = 100
    max_request_body_size_kb = 128
    disabled_rule_groups     = []
  }

  autoscale_configuration = {
    min_capacity = 2
    max_capacity = 10
  }
}

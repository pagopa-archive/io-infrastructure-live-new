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

dependency "firewall_custom_rules" {
  config_path = "../../firewall_custom_rules"
}

# Identities
dependency "user_assigned_identity_kvreader" {
  config_path = "../../../identities/kvreader/user_assigned_identity"
}

# Linux
dependency "app_service_appbackendl1" {
  config_path = "../../../linux/appbackendl1/app_service"
}

dependency "app_service_appbackendl2" {
  config_path = "../../../linux/appbackendl2/app_service"
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

  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_application_gateway?ref=v4.0.1"
}

inputs = {
  name                = "appgateway"
  resource_group_name = dependency.resource_group.outputs.resource_name

  sku = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = null
  }

  subnet_id = dependency.subnet.outputs.id

  backend_address_pools = [
    {
      name = local.backend_pool_name
      fqdns = [
        dependency.app_service_appbackendl1.outputs.default_site_hostname,
        dependency.app_service_appbackendl2.outputs.default_site_hostname
      ]
      ip_addresses = []
    },
  ]

  backend_http_settings = [{
    cookie_based_affinity               = "Disabled"
    affinity_cookie_name                = null
    name                                = local.backend_http_settings_name
    path                                = "/"
    port                                = 80
    probe_name                          = local.probe_name
    protocol                            = "HTTP"
    request_timeout                     = 10
    host_name                           = null
    pick_host_name_from_backend_address = true
    trusted_root_certificate_names      = null
    connection_draining                 = null

  }, ]

  probes = [{
    name                                      = format("%s-%s", "probe", local.backend_name)
    host                                      = null
    protocol                                  = "Http"
    path                                      = "/info"
    interval                                  = 30
    timeout                                   = 120
    unhealthy_threshold                       = 8
    pick_host_name_from_backend_http_settings = true
    }
  ]

  frontend_ip_configurations = [{
    name                          = "frontendipconfiguration"
    subnet_id                     = null
    private_ip_address            = null
    public_ip_address_id          = dependency.public_ip.outputs.id
    public_ip_address             = dependency.public_ip.outputs.ip_address
    private_ip_address_allocation = null
    a_record_name                 = "app-backend"
  }, ]

  gateway_ip_configurations = [{
    name      = "gatewayipconfiguration"
    subnet_id = dependency.subnet.outputs.id
  }]

  http_listeners = [{
    name                           = local.http_listener_name
    frontend_ip_configuration_name = "frontendipconfiguration"
    frontend_port_name             = "frontendport"
    protocol                       = "Https"
    host_name                      = "app-backend.io.italia.it"
    # Note the certificate name can not contain dot.
    ssl_certificate_name = "app-backend-io-italia-it"
    require_sni          = true
  }]

  custom_domain = {
    zone_name                = dependency.dns_zone.outputs.name
    zone_resource_group_name = dependency.dns_zone.outputs.resource_group_name
    identity_id              = dependency.user_assigned_identity_kvreader.outputs.id
    keyvault_id              = dependency.key_vault.outputs.id
  }

  request_routing_rules = [{
    name                        = format("%s-%s", "requestroutingrule", local.backend_name)
    rule_type                   = "Basic"
    http_listener_name          = local.http_listener_name
    backend_address_pool_name   = local.backend_pool_name
    backend_http_settings_name  = local.backend_http_settings_name
    redirect_configuration_name = null
    rewrite_rule_set_name       = "HttpHeader"
    url_path_map_name           = null
  }]

  firewall_policy_id = dependency.firewall_custom_rules.outputs.id

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

  autoscale_configuration = {
    min_capacity = 3
    max_capacity = 50
  }
}

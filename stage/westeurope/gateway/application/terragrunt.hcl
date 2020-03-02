# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_application_gateway"
}

dependency "resource_group" {
  config_path = "../resource_group"
}
dependency "log_analytics_workspace" {
  config_path = "../../common/log_analytics_workspace"
}
dependency "vnet" {
  config_path = "../../common/virtual_network"
}
dependency "key_vault" {
  config_path = "../../common/key_vault"
}

inputs = {
  name                  = "gateway"
  resource_group_name   = dependency.resource_group.outputs.resource_name

  # Subnet
  virtual_network_name       = dependency.vnet.outputs.resource_name
  subnet_address_prefix      = "10.0.1.0/24"
  subnet_resource_group_name = dependency.vnet.outputs.resource_group_name

  # IP
  ip_sku               = "Standard"
  ip_allocation_method = "Static"

  # Application Gateway 
  key_vault_id               = dependency.key_vault.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id
  certificate_name           = "certs-STAGE-IO-ITALIA-IT-DATA"
  certificate_password       = "certs-STAGE-IO-ITALIA-IT-PASSWORD"

  services = [
    {
      hl = {
        name                       = "listener-api-443"
        host_name                  = "api.stage.io.italia.it"
        protocol                   = "Https"
        require_sni                = true
        custom_error_configuration = {}
      }
      pb = {
        name                = "probe-api"
        interval            = 30
        protocol            = "Http"
        path                = "/status-0123456789abcdef"
        timeout             = 120
        unhealthy_threshold = 8
        host                = "api.stage.io.italia.it"
      }
      bhs = {
        name                  = "bhs-api"
        cookie_based_affinity = "Disabled"
        path                  = "/"
        port                  = 80
        probe_name            = "probe-api"
        protocol              = "Http"
        request_timeout       = 180
        host_name             = "api.stage.io.italia.it"
      }
      rrr = {
        name      = "rrr-api"
        rule_type = "Basic"
      }
      bap = {
        name         = "bap-api"
        ip_addresses = ["10.0.0.10","10.0.0.5"]
      }
    },
    {
      hl = {
        name                       = "listener-backstage-443"
        host_name                  = "app-backstage.stage.io.italia.it"
        protocol                   = "Https"
        require_sni                = true
        custom_error_configuration = {}
      }
      pb = {
        name                = "probe-backstage"
        interval            = 30
        protocol            = "Http"
        path                = "/status-0123456789abcdef"
        timeout             = 120
        unhealthy_threshold = 8
        host                = "app-backstage.stage.io.italia.it"
      }
      bhs = {
        name                  = "bhs-backstage"
        cookie_based_affinity = "Disabled"
        path                  = "/"
        port                  = 80
        probe_name            = "probe-backstage"
        protocol              = "Http"
        request_timeout       = 180
        host_name             = "app-backstage.stage.io.italia.it"
      }
      rrr = {
        name      = "rrr-backstage"
        rule_type = "Basic"
      }
      bap = {
        name         = "bap-backstage"
        ip_addresses = ["10.0.0.10","10.0.0.5"]
      }
    },

  ]
}


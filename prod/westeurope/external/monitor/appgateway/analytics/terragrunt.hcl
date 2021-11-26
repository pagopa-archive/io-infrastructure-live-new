dependency "appgateway" {
  config_path = "../../../appgateway/application_gateway"
}

dependency "log_analytics_workspace" {
  config_path = "../../../../common/log_analytics_workspace"
}


# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=update-azurerm-v2.87.0"
}

inputs = {
  name                         = "apigateway-analytics"
  target_resource_id           = dependency.appgateway.outputs.id
  log_analytics_workspace_id   = dependency.log_analytics_workspace.outputs.id

  logs = [{
    category = "ApplicationGatewayAccessLog"
    enabled  = true
    retention_policy = {
      days    = null
      enabled = false
    }
    },
    {
      category = "ApplicationGatewayPerformanceLog"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "ApplicationGatewayFirewallLog"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
  }]

  metrics = [{
    category = "AllMetrics"
    enabled  = false
    retention_policy = {
      days    = null
      enabled = false
    }
  }]
}

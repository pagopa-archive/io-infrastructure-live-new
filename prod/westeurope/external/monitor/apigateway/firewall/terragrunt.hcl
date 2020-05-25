dependency "apigateway" {
  config_path = "../../../apigateway/application_gateway"
}

dependency "log_analytics_workspace" {
  config_path = "../../../../common/log_analytics_workspace"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v2.0.23"
}

inputs = {
  name                       = "apigateway-firewall"
  target_resource_id         = dependency.apigateway.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id

  # Note: the retention policy is only applied to sorage accounts

  logs = [{
    category = "ApplicationGatewayAccessLog"
    enabled  = false
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
      enabled  = true
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

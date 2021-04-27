dependency "apigateway" {
  config_path = "../../../apigateway/application_gateway"
}

dependency "storage_account_logs" {
  config_path = "../../../../operations/storage_account_logs/account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v3.0.3"
}

inputs = {
  name                         = "apigateway-logs"
  target_resource_id           = dependency.apigateway.outputs.id
  storage_account_id           = dependency.storage_account_logs.outputs.id

  logs = [{
    category = "ApplicationGatewayAccessLog"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = true
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

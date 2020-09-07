dependency "appgateway" {
  config_path = "../../../appgateway/application_gateway"
}

dependency "resource_group_siem" {
  config_path = "../../../../siem/resource_group"
}

dependency "storage_account_logs" {
  config_path = "../../../../operations/storage_account_logs/account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v2.0.33"
}

inputs = {
  name                         = "appgateway-logs"
  target_resource_id           = dependency.appgateway.outputs.id
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

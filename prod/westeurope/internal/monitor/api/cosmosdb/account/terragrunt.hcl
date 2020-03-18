dependency "cosmosdb_account" {
  config_path = "../../../../api/cosmosdb/account"
}

dependency "log_analytics_workspace" {
  config_path = "../../../../../common/log_analytics_workspace"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  #source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v0.0.29"
  source = "../../../../../../../../io-infrastructure-modules-new/azurerm_monitor_diagnostic_setting"
}

inputs = {
  name                       = "cosmosdb-account"
  target_resource_id         = dependency.cosmosdb_account.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id

  logs = [{
    category = "GatewayLogs"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = true
    }
  }]

  metrics = [{
    category = "Gateway Requests"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = true
    }
    },
    {
      category = "Capacity"
      enabled  = true
      retention_policy = {
        days    = 365
        enabled = true
      }
    },
    {
      category = "EventHub Events"
      enabled  = true
      retention_policy = {
        days    = 365
        enabled = true
      }
    },
    {
      category = "Network Status"
      enabled  = true
      retention_policy = {
        days    = 365
        enabled = true
      }
    }
  ]
}

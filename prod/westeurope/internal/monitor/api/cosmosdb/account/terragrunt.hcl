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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v2.0.12"
}

inputs = {
  name                       = "cosmosdb-account"
  target_resource_id         = dependency.cosmosdb_account.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id

  logs = [{
    category = "QueryRuntimeStatistics"
    enabled  = false
    retention_policy = {
      days    = null
      enabled = false
    }
    },
    {
      category = "DataPlaneRequests"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "PartitionKeyStatistics"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "PartitionKeyRUConsumption"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "MongoRequests"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "ControlPlaneRequests"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
    },
    {
      category = "CassandraRequests"
      enabled  = false
      retention_policy = {
        days    = null
        enabled = false
      }
  }]

  metrics = [{
    category = "Requests"
    enabled  = true
    retention_policy = {
      days    = null
      enabled = false
    }
  }]
}

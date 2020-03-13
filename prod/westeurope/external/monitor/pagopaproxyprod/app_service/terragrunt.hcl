dependency "app_service" {
  config_path = "../../../pagopaproxyprod/app_service"
}

dependency "log_analytics_workspace" {
  config_path = "../../../../common/log_analytics_workspace"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  #source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v0.0.29"
  source = "../../../../../../../io-infrastructure-modules-new/azurerm_monitor_diagnostic_setting"
}

inputs = {
  name                       = "apigad"
  target_resource_id         = dependency.app_service.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id

  logs = [{
    category = "AppServiceHTTPLogs"
    enabled  = true
    retention_policy = {
      days    = 5
      enabled = true
    }
    },
    {
      category = "AppServiceConsoleLogs"
      enabled  = true
      retention_policy = {
        days    = 5
        enabled = true
      }
    },
    {
      category = "AppServiceAppLogs"
      enabled  = true
      retention_policy = {
        days    = 5
        enabled = true
      }
    },
    {
      category = "AppServiceFileAuditLogs"
      enabled  = true
      retention_policy = {
        days    = 5
        enabled = true
      }
    },
    {
      category = "AppServiceAuditLogs"
      enabled  = true
      retention_policy = {
        days    = 5
        enabled = true
      }
  }]

  metrics = [{
    category = "AllMetrics"
    enabled  = true
    retention_policy = {
      days    = 5
      enabled = true
    }
  }]
}

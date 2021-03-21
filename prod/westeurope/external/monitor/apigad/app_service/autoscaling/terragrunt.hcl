dependency "autoscaling" {
  config_path = "../../../../apigad/autoscaling"
}

dependency "log_analytics_workspace" {
  config_path = "../../../../../common/log_analytics_workspace"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v3.0.0"
}

inputs = {
  name                       = "apigad-scaling"
  target_resource_id         = dependency.autoscaling.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id

  logs = [{
    category = "AutoscaleEvaluations"
    enabled  = true
    retention_policy = {
      days    = null
      enabled = false
    }
    },
    {
      category = "AutoscaleScaleActions"
      enabled  = true
      retention_policy = {
        days    = null
        enabled = false
      }
    },
  ]

  metrics = [{
    category = "AllMetrics"
    enabled  = false
    retention_policy = {
      days    = null
      enabled = false
    }
  }]
}

dependency "log_analytics_workspace" {
  config_path = "../../log_analytics_workspace"
}

dependency "cdn_endpoint_developerportal" {
  config_path = "../../cdn/cdn_endpoint_developerportal"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v2.0.12"
}

inputs = {

  name                       = "cdnendpoint-developerportal"
  target_resource_id         = dependency.cdn_endpoint_developerportal.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id

  logs = [{
    category = "CoreAnalytics"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = false
    }
  }]
}

dependency "redis_cache" {
  config_path = "../../redis/redis_cache"
}

dependency "log_analytics_workspace" {
  config_path = "../../../common/log_analytics_workspace"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  #source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_diagnostic_setting?ref=v0.0.29"
  source = "../../../../../../io-infrastructure-modules-new/azurerm_monitor_diagnostic_setting"
}

inputs = {

  name                       = "redis"
  target_resource_id         = dependency.redis_cache.outputs.id
  log_analytics_workspace_id = dependency.log_analytics_workspace.outputs.id

  metrics = [{
    category = "AllMetrics"
    enabled  = true
    retention_policy = {
      days    = 365
      enabled = true
    }
  }]
}
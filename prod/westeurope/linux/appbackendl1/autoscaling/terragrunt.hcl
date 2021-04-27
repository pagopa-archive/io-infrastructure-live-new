# Autoscaling appbackend
dependency "app_service" {
  config_path = "../app_service"
}

# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

# common
dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_autoscale_setting?ref=v3.0.3"
}


inputs = {
  name = "autoscaling-appbackendl1"

  resource_group_name = dependency.resource_group.outputs.resource_name
  target_resource_id  = dependency.app_service.outputs.app_service_plan_id

  profiles = [{
    name = "DefaultProfile"

    capacity = {
      default = 5
      minimum = 5
      maximum = 20
    }

    rules = [
      {
        name = "ScaleOutCpu"
        metric_trigger = {
          metric_name        = "CpuPercentage"
          metric_resource_id = dependency.app_service.outputs.app_service_plan_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT1M"
          time_aggregation   = "Average"
          operator           = "GreaterThan"
          threshold          = 75
        }

        scale_action = {
          direction = "Increase"
          type      = "ChangeCount"
          value     = "2"
          cooldown  = "PT5M"
        }
      },
      {
        name = "ScaleInCpu"
        metric_trigger = {
          metric_name        = "CpuPercentage"
          metric_resource_id = dependency.app_service.outputs.app_service_plan_id
          time_grain         = "PT1M"
          statistic          = "Average"
          time_window        = "PT5M"
          time_aggregation   = "Average"
          operator           = "LessThan"
          threshold          = 25
        }

        scale_action = {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT5M"
        }
      }
    ]

    fixed_date = null
    recurrence = null
    }
  ]

  notification = {
    email = {
      send_to_subscription_administrator    = false
      send_to_subscription_co_administrator = false
      custom_emails                         = ["appbackend-AUTOSCALING-NOTIFICATION-EMAILS"]
    }
    key_vault_id = dependency.key_vault.outputs.id
  }
}

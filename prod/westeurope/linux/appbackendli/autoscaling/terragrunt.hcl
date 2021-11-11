dependency "app_service" {
  config_path = "../app_service"
}

# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_monitor_autoscale_setting?ref=v4.0.1"
}

inputs = {
  name = "autoscaling-appbackendli"

  resource_group_name = dependency.resource_group.outputs.resource_name
  target_resource_id  = dependency.app_service.outputs.app_service_plan_id

  profiles = [{
    name = "DefaultProfile"

    capacity = {
      # normal capacity
      default = 3
      minimum = 1
      maximum = 5
      # high priority event capacity
      # default = 5
      # minimum = 2
      # maximum = 10
    }

    rules = [
      {
        name = "ScaleOutRequests"
        metric_trigger = {
          metric_name              = "Requests"
          metric_resource_id       = dependency.app_service.outputs.id
          metric_namespace         = "microsoft.web/sites"
          time_grain               = "PT1M"
          statistic                = "Average"
          time_window              = "PT5M"
          time_aggregation         = "Average"
          operator                 = "GreaterThan"
          threshold                = 4000
          divide_by_instance_count = false
        }

        scale_action = {
          direction = "Increase"
          type      = "ChangeCount"
          value     = "2"
          cooldown  = "PT5M"
        }
      },
      {
        name = "ScaleInRequests"
        metric_trigger = {
          metric_name              = "Requests"
          metric_resource_id       = dependency.app_service.outputs.id
          metric_namespace         = "microsoft.web/sites"
          time_grain               = "PT1M"
          statistic                = "Average"
          time_window              = "PT5M"
          time_aggregation         = "Average"
          operator                 = "LessThan"
          threshold                = 3000
          divide_by_instance_count = false
        }

        scale_action = {
          direction = "Decrease"
          type      = "ChangeCount"
          value     = "1"
          cooldown  = "PT20M"
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
      custom_emails                         = ["disabed-email@pagopa.it"]
    }
    key_vault_id = null
  }
}

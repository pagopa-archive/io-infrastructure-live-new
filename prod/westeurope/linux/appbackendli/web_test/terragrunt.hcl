# Common
dependency "application_insights" {
  config_path = "../../../common/application_insights"
}

# linux
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "app_service" {
  config_path = "../app_service"
}


# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_application_insights_web_test?ref=v2.1.29"
}

inputs = {
  name = "appbackendli"

  resource_group_name     = dependency.resource_group.outputs.resource_name
  application_insights_id = dependency.application_insights.outputs.id
  enabled                 = true

  url = format("https://%s/info", dependency.app_service.outputs.default_site_hostname)
}

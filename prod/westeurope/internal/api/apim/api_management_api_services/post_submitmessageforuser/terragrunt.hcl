dependency "api_management" {
  config_path = "../../api_management"
}

# Internal
dependency "resource_group" {
  config_path = "../../../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management_api_operation_policy?ref=v3.0.5"
}

inputs = {
  api_name            = "io-services-api"
  resource_group_name = dependency.resource_group.outputs.resource_name
  api_management_name = dependency.api_management.outputs.name
  operation_id        = "submitMessageforUser"

  xml_content = file("policy.xml")
}

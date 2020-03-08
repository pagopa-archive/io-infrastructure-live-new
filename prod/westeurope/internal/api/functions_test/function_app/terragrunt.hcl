# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Common
dependency "virtual_network" {
  config_path = "../../../../common/virtual_network"
}

dependency "application_insights" {
  config_path = "../../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../../common/key_vault"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v0.0.30"
}

inputs = {
  name                = "test"
  resource_group_name = dependency.resource_group.outputs.resource_name

  virtual_network_info = {
    resource_group_name   = dependency.virtual_network.outputs.resource_group_name
    name                  = dependency.virtual_network.outputs.resource_name
    subnet_address_prefix = "10.0.201.0/24"
  }

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"

    TEST_SETTING1 = "VALUE1"
    TEST_SETTING2 = "VALUE2"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      TEST_SECRET = "common-TEST-SECRET"
    }
  }
}

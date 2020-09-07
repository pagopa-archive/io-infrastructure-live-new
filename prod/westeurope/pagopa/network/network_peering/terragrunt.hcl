dependency "resource_group_pagopa" {
  config_path = "../../resource_group"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

dependency "resource_group_common" {
  config_path = "../../../common/resource_group"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

dependency "virtual_network_pagopa" {
  config_path = "../virtual_network"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

dependency "virtual_network_common" {
  config_path = "../../../common/virtual_network"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_virtual_network_peering?ref=v2.0.37"
}

inputs = {
  source_name                      = "pagopa"
  target_name                      = "common"
  source_resource_group_name       = dependency.resource_group_pagopa.outputs.resource_name
  target_resource_group_name       = dependency.resource_group_common.outputs.resource_name
  source_virtual_network_name      = dependency.virtual_network_pagopa.outputs.resource_name
  target_virtual_network_name      = dependency.virtual_network_common.outputs.resource_name
  source_remote_virtual_network_id = dependency.virtual_network_pagopa.outputs.id
  target_remote_virtual_network_id = dependency.virtual_network_common.outputs.id
}

dependency "subnet_funcbonus" {
  config_path = "../../functions_bonus/subnet"
}

dependency "subnet_fn3bonusapi" {
  config_path = "../../functions_bonusapi_r3/subnet"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cosmosdb_account?ref=v2.1.24"
}

inputs = {
  name                = "bonus"
  resource_group_name = dependency.resource_group.outputs.resource_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy = {
    consistency_level       = "Strong"
    max_interval_in_seconds = null
    max_staleness_prefix    = null
  }

  main_geo_location_location = "westeurope"

  additional_geo_locations = [
    {
      location          = "northeurope"
      failover_priority = 1
    }
  ]

  is_virtual_network_filter_enabled = true

  ip_range = "23.97.147.242,13.69.61.42,137.117.159.137,104.47.161.199,104.47.157.240"

  allowed_virtual_network_subnet_ids = [
    dependency.subnet_funcbonus.outputs.id,
    dependency.subnet_fn3bonusapi.outputs.id
  ]

   lock = {
    name       = "cosmos-bonus"
    lock_level = "CanNotDelete"
    notes      = null
  }
}

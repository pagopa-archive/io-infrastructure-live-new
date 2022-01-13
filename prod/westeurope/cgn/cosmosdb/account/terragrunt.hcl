## WARNING: deprecated. ##
## moved into https://github.com/pagopa/io-infra/blob/main/src/core/cgn.tf

# cgn


dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "subnet_fn3cgn" {
  config_path = "../../functions_cgn/subnet"
}


# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cosmosdb_account?ref=v4.0.0"
}

inputs = {
  name                = "cgn"
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

  ip_range = ""

  allowed_virtual_network_subnet_ids = [
    dependency.subnet_fn3cgn.outputs.id,
  ]

  lock = {
    name       = "cosmos-cgn"
    lock_level = "CanNotDelete"
    notes      = null
  }
}

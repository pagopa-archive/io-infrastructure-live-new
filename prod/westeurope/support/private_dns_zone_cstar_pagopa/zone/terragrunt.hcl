# DNS Zone
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_private_dns_zone?ref=v3.0.3"
}

inputs = {
  name                = "cstar.pagopa.it"
  resource_group_name = dependency.resource_group.outputs.resource_name

  dns_a_records = [
    {
      name               = "prod"
      ttl                = 3600
      records            = ["10.70.133.6"]
      target_resource_id = null
    },
    {
      name               = "api"
      ttl                = 3600
      records            = ["10.230.6.6"]
      target_resource_id = null
    },
  ]
}

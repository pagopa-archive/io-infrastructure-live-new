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
  name                = "postgres.database.azure.com"
  resource_group_name = dependency.resource_group.outputs.resource_name

  dns_a_records = [
    {
    name               = "u87psqlp01"
    ttl                = 3600
    records            = ["10.70.132.5"]
    target_resource_id = null
    },
    {
      name               = "u87psqlp01-rep"
      ttl                = 3600
      records            = ["10.70.132.7"]
      target_resource_id = null
    },
    {
      name               = "u87psqlp01-rep2"
      ttl                = 3600
      records            = ["10.70.132.9"]
      target_resource_id = null
    },
    {
      name               = "cstar-p-postgresql-rep"
      ttl                = 3600
      records            = ["10.1.129.5"]
      target_resource_id = null
    },
    {
      name               = "cstar-p-postgresql"
      ttl                = 3600
      records            = ["10.1.129.4"]
      target_resource_id = null
    },
  ]
}

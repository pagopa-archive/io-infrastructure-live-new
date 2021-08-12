dependency "dns_zone" {
  config_path = "../zone"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_dns_caa_record?ref=v3.0.3"
}

inputs = {
  name                = "@"
  zone_name           = dependency.dns_zone.outputs.name
  resource_group_name = dependency.dns_zone.outputs.resource_group_name
  ttl                 = 300

  records = [
    {
      flags = 0
      tag   = "issue"
      value = "letsencrypt.org"
    },
    {
      flags = 0
      tag   = "issue"
      value = "digicert.com"
    },
    {
      flags = 0
      tag   = "iodef"
      value = "mailto:security+caa@pagopa.it"
    }
  ]
}

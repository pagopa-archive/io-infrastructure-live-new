dependency "resource_group" {
  config_path = "../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_dns_caa_record?ref=v2.1.0"
}

inputs = {
  name                = "@"
  zone_name           = "io.italia.it"
  resource_group_name = "io-infra-rg"
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

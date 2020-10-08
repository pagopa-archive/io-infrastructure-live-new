# External
dependency "resource_group" {
  config_path = "../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_web_application_firewall_policy?ref=v2.1.2"
}

inputs = {
  name                = "wafpolicy"
  resource_group_name = dependency.resource_group.outputs.resource_name

  custom_rules = [{
    name      = "block-ips"
    priority  = 1
    rule_type = "MatchRule"
    action    = "Block"

    match_conditions = [{
      operator = "IPMatch"
      # ip from canada
      match_values = ["192.175.96.0/19"]
      match_variables = [{
        variable_name = "RemoteAddr"
        selector      = null
      }]

    }]

  }]

  policy_settings = {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules = {

    exclusion = []

    managed_rule_set = [{
      type    = "OWASP"
      version = "3.1"

      rule_group_override = [{
        rule_group_name = "REQUEST-913-SCANNER-DETECTION"
        disabled_rules = [
          "913100",
          "913101",
          "913102",
          "913110",
          "913120",
        ]
        },
        {
          rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
          disabled_rules = [
            "920300",
            "920320"
          ]
        },
        {
          rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
          disabled_rules = [
            "930120"
          ]
        },
        {
          rule_group_name = "REQUEST-932-APPLICATION-ATTACK-RCE"
          disabled_rules = [
            "932150"
          ]
        },
        {
          rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
          disabled_rules = [
            "942100",
            "942190",
            "942200",
            "942210",
            "942250",
            "942260",
            "942330",
            "942340",
            "942370",
            "942380",
            "942430",
            "942440",
            "942450"
          ]
      }]
    }]
  }
}

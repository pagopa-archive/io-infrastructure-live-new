dependency "api_management" {
  config_path = "../api_management"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management_groups?ref=v2.1.0"
}

inputs = {
  resource_group_name = dependency.resource_group.outputs.resource_name
  api_management_name = dependency.api_management.outputs.name

  groups = [
    {
      display_name = "ApiAuthenticationClientCertificate"
      name         = "apiauthenticationclientcertificate"
    },
    {
      display_name = "ApiAdmin"
      name         = "apiadmin"
    },
    {
      display_name = "ApiDebugRead"
      name         = "apidebugread"
    },
    {
      display_name = "ApiDevelopmentProfileWrite"
      name         = "apidevelopmentprofilewrite"
    },
    {
      display_name = "ApiFullProfileRead"
      name         = "apifullprofileread"
    },
    {
      display_name = "ApiInfoRead"
      name         = "apiinforead"
    },
    {
      display_name = "ApiLimitedMessageWrite"
      name         = "apilimitedmessagewrite"
    },
    {
      display_name = "ApiLimitedProfileRead"
      name         = "apilimitedprofileread"
    },
    {
      display_name = "ApiMessageList"
      name         = "apimessagelist"
    },
    {
      display_name = "ApiMessageRead"
      name         = "apimessageread"
    },
    {
      display_name = "ApiMessageWrite"
      name         = "apimessagewrite"
    },
    {
      display_name = "ApiMessageWriteDefaultAddress"
      name         = "apimessagewritedefaultaddress"
    },
    {
      display_name = "ApiMessageWriteDryRun"
      name         = "apimessagewritedryrun"
    },
    {
      display_name = "ApiProfileWrite"
      name         = "apiprofilewrite"
    },
    {
      display_name = "ApiPublicServiceList"
      name         = "apipublicservicelist"
    },
    {
      display_name = "ApiPublicServiceRead"
      name         = "apipublicserviceread"
    },
    {
      display_name = "ApiServiceByRecipientQuery"
      name         = "apiservicebyrecipientquery"
    },
    {
      display_name = "ApiServiceKeyRead"
      name         = "apiservicekeyread"
    },
    {
      display_name = "ApiServiceKeyWrite"
      name         = "apiservicekeywrite"
    },
    {
      display_name = "ApiServiceList"
      name         = "apiservicelist"
    },
    {
      display_name = "ApiServiceRead"
      name         = "apiserviceread"
    },
    {
      display_name = "ApiServiceWrite"
      name         = "apiservicewrite"
    },
    {
      display_name = "ApiSubscriptionsFeedRead"
      name         = "apisubscriptionsfeedread"
    },
    {
      display_name = "ApiUserAdmin"
      name         = "apiuseradmin"
    },
    {
      display_name = "ApiNoRateLimit"
      name         = "apinoratelimit"
    }
  ]
}

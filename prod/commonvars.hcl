locals {

  app_insights_ips_west_europe = [
    "51.144.56.96/28",
    "51.144.56.112/28",
    "51.144.56.128/28",
    "51.144.56.144/28",
    "51.144.56.160/28",
    "51.144.56.176/28",
  ]

  # windows standatd. It can be different in linux service plan.
  cet_time_zone_win = "Central Europe Standard Time"

  service_api_url = "http://api-internal.io.italia.it/"

  # Switch limit date for email opt out mode. This value should be used by functions that need to discriminate
  # how to check isInboxEnabled property on IO profiles, since we have to disable email notifications for default
  # for all profiles that have been updated before this date. This date should coincide with new IO App's release date
  # 1625781600 value refers to 2021-07-09T00:00:00 GMT+02:00
  opt_out_email_switch_date = 1625781600

  # Feature flag used to enable email opt-in with logic exposed by the previous variable usage
  ff_opt_in_email_enabled = "true"
}

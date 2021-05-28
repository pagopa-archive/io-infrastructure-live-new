locals {

  # A list of fiscal codes to be used by internal team for functional, e2e tests on IO
  test_users_internal = [],
  # A list of fiscal codes to be used by internal team for load tests on IO
  test_users_internal_load = [],
  # A list of fiscal codes to be used by app stores to review IO App
  test_users_store_review = ["AAAAAA00A00A000B"],
  # A list of fiscal codes to be used to test EU Covid Certificate initiative on IO  
  test_users_eu_covid_cert = [],
  
  # All previous sets, ensembled
  test_users = join(",", 
    concat([], 
      concat(locals.test_users_internal,
        concat(locals.test_users_internal_load,
          concat(locals.test_users_store_review,
            locals.test_users_eu_covid_cert
          )
        )
      )
    )
   ),

}

connection: "ota_phoenix"


include: "/views/**/*.view.lkml"


explore: content_integration_search {
  join: affiliate_mapping {
    type: left_outer
    sql_on: ${content_integration_search.affiliate_id} = ${affiliate_mapping.affiliate_id} ;;
    relationship: many_to_one
  }
}

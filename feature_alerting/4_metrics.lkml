include: "5_alerting.lkml"
include: "3_weighted_average.lkml"
include: "1_parameters.lkml"
include: "//ecommerce_sandbox/ecommerce_sandbox.model.lkml"
include: "/models/content_integration_search.model.lkml"


############   KPI VIEWS
###### Any metrics to be exposed in the Alerting explore needs to be defined as a Derived Table below
############

view: order_count {
  derived_table: {
    explore_source: order_items {
      timezone: "America/Toronto"
      column: time {field: orders.order_purchase_timestamp_hour}
      column: order_count { field: orders.count}
    }
  }
}

view: returned_requests_rate {
  derived_table: {
    explore_source: content_integration_search {
      timezone: "America/Toronto"
      column: time {field: content_integration_search.dayd_hour}
      column: returned_packages_count {field: content_integration_search.returned_packages_count}
      column: all_requests_count {field: content_integration_search.all_requests_count}
      column: content_source {field: content_integration_search.content_source}
      column: office_id {field: content_integration_search.office_id}
      column: search_source {field: content_integration_search.search_source}
      column: search_engine {field: content_integration_search.search_engine}
      column: site_currency {field: content_integration_search.site_currency}
    }
    sql_trigger_value: SELECT MAX(dayd) FROM search_api_stats.gds_raw ;;
  }
  
  dimension: time {
    type: date_hour
    sql: ${TABLE}.time ;;
    hidden: yes
  }
  
  dimension: content_source {
    type: string
    sql: ${TABLE}.content_source ;;
    group_label: "2. Content"
  }
  
  dimension: office_id {
    type: string
    sql: ${TABLE}.office_id ;;
    group_label: "2. Content"
  }
  
  dimension: search_source {
    type: string
    sql: ${TABLE}.search_source ;;
    group_label: "3. Search Source"
  }
  
  dimension: search_engine {
    type: string
    sql: ${TABLE}.search_engine ;;
    group_label: "3. Search Source"
  }
  
  dimension: site_currency {
    type: string
    sql: ${TABLE}.site_currency ;;
    group_label: "3. Search Source"
  }
  
  measure: returned_packages_count {
    type: sum
    sql: ${TABLE}.returned_packages_count ;;
    hidden: yes
  }
  
  measure: all_requests_count {
    type: sum
    sql: ${TABLE}.all_requests_count ;;
    hidden: yes
  }
  
  measure: returned_requests_rate {
    type: number
    value_format_name: percent_2
    sql: ${returned_packages_count} / NULLIF(${all_requests_count}, 0) ;;
  }
}


############
###### The alerting_metrics view gathers the KPI views together and filter on the time of the day (00:00 to 23:00)
############
###### Note { below is not efficient, but for demo this is easiest code to understand logic
###### Production code should use sql_table_name with liquid, and sql_always_where in explore, whilst aking into account DB dielcts for partitions/clustering/indices etc
#}
explore: alerting_metrics {
  hidden: no
  join: alerting_parameters {}
  # join: linear_reg_metrics {
  # if you create a linear regression model. you will need to join via Time of day.
  #   sql_on:${linear_reg_metrics.time}=${alerting_metrics.time_of_day};;
  #   relationship: one_to_one
  # }
}

view: alerting_metrics {
  extends: ["weighted_average"]
  derived_table: {
    sql:
      SELECT *
      FROM
      {% if alerting_parameters.metric_name._parameter_value == 'order_count' %}
       ${order_count.SQL_TABLE_NAME}
      {% elsif alerting_parameters.metric_name._parameter_value == 'returned_requests_rate' %}
       ${returned_requests_rate.SQL_TABLE_NAME}
      {% else %}
        SELECT NULL
      {% endif %} view
      WHERE extract(time FROM view.time) <= TIME_ADD(extract(time FROM CURRENT_TIMESTAMP()), INTERVAL 15 minute);;   #  filters the data for each day to match the time period
  }
}

# view: linear_reg_metrics {
#   if you create a linear regression model. you will need view object to point too.
#   derived_table: {
#     sql:
#       {% if alerting_parameters.metric_name._parameter_value == 'order_count' %}
#       SELECT * FROM ${model_name_prediction.SQL_TABLE_NAME}
#       {% else %}
#         SELECT NULL AS time, NULL as predicted_your_dependent_variable_name
#       {% endif %} ;;
#   }

#   dimension: time {
#     type:string}

#   measure: predicted_value {
#     type:sum sql:${TABLE}.predicted_your_dependent_variable_name;;}
# }

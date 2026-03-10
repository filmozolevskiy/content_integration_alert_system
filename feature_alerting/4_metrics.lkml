include: "5_alerting.lkml"
include: "3_weighted_average.lkml"
include: "1_parameters.lkml"
# Uses search_api_stats.gds_raw from ota_phoenix (ClickHouse)


############   KPI VIEWS
###### Uses search_api_stats.gds_raw (ClickHouse) with sql_table_name + liquid
############

view: search_count {
  sql_table_name: |
    (SELECT
      {% if alerting_parameters.time_range._parameter_value == 'hour' %}
      toStartOfHour(date_added) AS time
      {% elsif alerting_parameters.time_range._parameter_value == 'minute5' %}
      toStartOfFiveMinute(date_added) AS time
      {% elsif alerting_parameters.time_range._parameter_value == 'minute15' %}
      toStartOfInterval(date_added, INTERVAL 15 MINUTE) AS time
      {% elsif alerting_parameters.time_range._parameter_value == 'minute20' %}
      toStartOfInterval(date_added, INTERVAL 20 MINUTE) AS time
      {% elsif alerting_parameters.time_range._parameter_value == 'minute30' %}
      toStartOfInterval(date_added, INTERVAL 30 MINUTE) AS time
      {% else %}
      toStartOfFiveMinute(date_added) AS time
      {% endif %} AS time,
      count(*) AS search_count
    FROM search_api_stats.gds_raw
    WHERE date_added >= '2025-01-01'
      AND ((api_user IN ('kayak', 'kayakapp') AND site_id = 1) OR api_user NOT IN ('kayak', 'kayakapp'))
    GROUP BY 1)
  dimension: time {
    type: time
    sql: ${TABLE}.time ;;
    hidden: yes
  }
  measure: search_count {
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.search_count ;;
  }
}


############
###### The alerting_metrics view gathers KPI data and filters on the time of day
############
explore: alerting_metrics {
  hidden: no
  join: alerting_parameters {}
}

view: alerting_metrics {
  extends: ["weighted_average"]
  sql_table_name: |
    {% if alerting_parameters.metric_name._parameter_value == 'search_count' %}
    (SELECT * FROM ${search_count.SQL_TABLE_NAME} view
    WHERE toDateTime(view.time) <= now() +
      {% if alerting_parameters.time_range._parameter_value == 'hour' %}INTERVAL 1 HOUR
      {% elsif alerting_parameters.time_range._parameter_value == 'minute5' %}INTERVAL 5 MINUTE
      {% elsif alerting_parameters.time_range._parameter_value == 'minute15' %}INTERVAL 15 MINUTE
      {% elsif alerting_parameters.time_range._parameter_value == 'minute20' %}INTERVAL 20 MINUTE
      {% elsif alerting_parameters.time_range._parameter_value == 'minute30' %}INTERVAL 30 MINUTE
      {% else %}INTERVAL 15 MINUTE{% endif %})
    {% else %}
    (SELECT NULL AS time, NULL AS search_count)
    {% endif %}
}

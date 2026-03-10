include: "5_alerting.lkml"
include: "3_weighted_average.lkml"
include: "1_parameters.lkml"
include: "//ecommerce_sandbox/ecommerce_sandbox.model.lkml"


############   KPI VIEWS
###### Any metrics to be exposed in the Alerting explore needs to be defined as a Derived Table below
############

view: order_count {
  derived_table: {
    explore_source: order_items {
      timezone: "Europe/London"
      column: time {field: orders.order_purchase_timestamp_hour}
      column: order_count { field: orders.count}
    }
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
}

view: alerting_metrics {
  extends: ["weighted_average"]
  derived_table: {
    sql:
      SELECT *
      FROM
      {% if alerting_parameters.metric_name._parameter_value == 'order_count' %}
       ${order_count.SQL_TABLE_NAME}
      {% else %}
        SELECT NULL
      {% endif %} view
      WHERE extract(time FROM view.time) <= TIME_ADD(extract(time FROM CURRENT_TIMESTAMP()), INTERVAL 15 minute);;   #  filters the data for each day to match the time period
  }
}

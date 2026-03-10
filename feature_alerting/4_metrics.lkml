include: "5_alerting.lkml"
include: "3_weighted_average.lkml"
include: "1_parameters.lkml"


############   KPI VIEWS
###### Any metrics to be exposed in the Alerting explore needs to be defined as a Derived Table below
############

view: search_count {
  derived_table: {
    explore_source: content_integration_search {
      column: time {field: content_integration_search.dayd_hour}
      column: search_count { field: content_integration_search.all_requests_count}
    }
  }
}


############
###### The alerting_metrics view gathers the KPI views together and filter on the time of the day (00:00 to 23:00)
############
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
      {% if alerting_parameters.metric_name._parameter_value == 'search_count' %}
       ${search_count.SQL_TABLE_NAME}
      {% else %}
        (SELECT NULL AS time, NULL AS search_count)
      {% endif %} view
      WHERE formatDateTime(view.time, '%H:%M') <= formatDateTime(addMinutes(now(), 15), '%H:%M');;   #  filters the data for each day to match the time period
  }
}

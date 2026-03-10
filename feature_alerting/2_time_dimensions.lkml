view: time_dimensions {
  extension: required

  # ClickHouse: now() returns current timestamp
  dimension: minute5_now {
    type: date_minute5 sql: now() ;; hidden: yes }

  dimension: minute15_now {
    type: date_minute15 sql: now() ;; hidden: yes }

  dimension: minute20_now {
    type: date_minute20 sql: now() ;; hidden: yes }

  dimension: minute30_now {
    type: date_minute30 sql: now() ;; hidden: yes }

  dimension: hour_now {
    type: date_hour sql: now() ;; hidden: yes}


  dimension: now {
    type: string
    hidden: yes
    sql:
    {% if alerting_parameters.time_range._parameter_value == 'hour' %}        formatDateTime(${hour_now}, '%H:00')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute5' %}  formatDateTime(${minute5_now}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute15' %} formatDateTime(${minute15_now}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute20' %} formatDateTime(${minute20_now}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute30' %} formatDateTime(${minute30_now}, '%H:%M')
    {% endif %};;
  }



  dimension: minute5_before {
    type: date_minute5 sql: subtractMinutes(${minute5_now}, 5) ;; hidden: yes }

  dimension: minute15_before {
    type: date_minute15 sql: subtractMinutes(${minute15_now}, 15) ;; hidden: yes }

  dimension: minute20_before {
    type: date_minute20 sql: subtractMinutes(${minute20_now}, 20) ;; hidden: yes }

  dimension: minute30_before {
    type: date_minute30 sql: subtractMinutes(${minute30_now}, 30) ;; hidden: yes }

  dimension: hour_before {
    type: date_hour sql: subtractHours(${hour_now}, 1) ;; hidden: yes}



  dimension: before {
    type: string
    hidden: yes
    sql:
    {% if alerting_parameters.time_range._parameter_value == 'hour' %}        formatDateTime(${hour_before}, '%H:00')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute5' %}  formatDateTime(${minute5_before}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute15' %} formatDateTime(${minute15_before}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute20' %} formatDateTime(${minute20_before}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute30' %} formatDateTime(${minute30_before}, '%H:%M')
    {% endif %};;
  }


  dimension: minute5 {
    type: date_minute5 sql: ${TABLE}.time ;; hidden: yes }

  dimension: minute15 {
    type: date_minute15 sql: ${TABLE}.time ;; hidden: yes }

  dimension: minute20 {
    type: date_minute20 sql: ${TABLE}.time ;; hidden: yes }

  dimension: minute30 {
    type: date_minute30 sql: ${TABLE}.time ;; hidden: yes }

  dimension: hour {
    type: date_hour sql: ${TABLE}.time ;; hidden: yes}



  dimension: time_of_day {
    type: string
    sql:
    {% if alerting_parameters.time_range._parameter_value == 'hour' %}        formatDateTime(toDateTime(${hour}), '%H:00')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute5' %}  formatDateTime(toDateTime(${minute5}), '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute15' %} formatDateTime(toDateTime(${minute15}), '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute20' %} formatDateTime(toDateTime(${minute20}), '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute30' %} formatDateTime(toDateTime(${minute30}), '%H:%M')
    {% endif %};;
  }

  dimension: day {
    type: date
    hidden: yes
    sql: toDate(${TABLE}.time) ;;
  }
  dimension: today {
    type: date
    hidden: yes
    sql: today() ;;
  }
  dimension: is_yesterday {
    type: yesno
    hidden: yes
    sql: ${day} = subtractDays(${today}, 1) ;;
  }
  dimension: is_last_week {
    type: yesno
    hidden: yes
    sql: ${day} = subtractDays(${today}, 7) ;;
  }
  dimension: is_last_year {
    type: yesno
    hidden: yes
    sql: ${day} = subtractDays(${today}, 364) ;;
  }
  dimension: is_today {
    type: yesno
    hidden: yes
    sql: ${day} = ${today} ;;
  }
}

view: time_dimensions {
  extension: required

  dimension: minute5_now {
    type: date_minute5 sql:now() ;; hidden: yes }

  dimension: minute15_now {
    type: date_minute15 sql:toStartOfInterval(now(), INTERVAL 15 MINUTE) ;; hidden: yes }

  dimension: minute20_now {
    type: date_minute20 sql:toStartOfInterval(now(), INTERVAL 20 MINUTE) ;; hidden: yes }

  dimension: minute30_now {
    type: date_minute30 sql:toStartOfInterval(now(), INTERVAL 30 MINUTE) ;; hidden: yes }

  dimension: hour_now {
    type: date_hour sql:toStartOfHour(now());; hidden: yes}



  dimension: now {
    type: string
    hidden: yes
    sql:
    {% if alerting_parameters.time_range._parameter_value == 'hour' %}        formatDateTime(${hour_now}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute5' %}  formatDateTime(${minute5_now}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute15' %} formatDateTime(${minute15_now}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute20' %} formatDateTime(${minute20_now}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute30' %} formatDateTime(${minute30_now}, '%H:%M')
    {% endif %};;
  }



  dimension: minute5_before {
    type: date_minute5 sql:subtractMinutes(now(), 5);; hidden: yes }

  dimension: minute15_before {
    type: date_minute15 sql:subtractMinutes(now(), 15);; hidden: yes }

  dimension: minute20_before {
    type: date_minute20 sql:subtractMinutes(now(), 20);; hidden: yes }

  dimension: minute30_before {
    type: date_minute30 sql:subtractMinutes(now(), 30);; hidden: yes }

  dimension: hour_before {
    type: date_hour sql:subtractHours(now(), 1);; hidden: yes}



  dimension: before {
    type: string
    hidden: yes
    sql:
    {% if alerting_parameters.time_range._parameter_value == 'hour' %}        formatDateTime(${hour_before}, '%H:%M')
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
    type: date_hour sql:${TABLE}.time;; hidden: yes}



  dimension: time_of_day {
    type: string
    sql:
    {% if alerting_parameters.time_range._parameter_value == 'hour' %}        formatDateTime(${hour}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute5' %}  formatDateTime(${minute5}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute15' %} formatDateTime(${minute15}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute20' %} formatDateTime(${minute20}, '%H:%M')
    {% elsif alerting_parameters.time_range._parameter_value == 'minute30' %} formatDateTime(${minute30}, '%H:%M')
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
    sql: ${day} = subtractDays(${today}, 1);;
  }
  dimension: is_last_week {
    type: yesno
    hidden: yes
    sql: ${day} = subtractDays(${today}, 7);;
  }
  dimension: is_last_year {
    type: yesno
    hidden: yes
    sql: ${day} = subtractDays(${today}, 364);;
  }
  dimension: is_today {
    type: yesno
    hidden: yes
    sql: ${day} = ${today};;
  }
}

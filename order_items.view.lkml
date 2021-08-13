view: order_items {
  sql_table_name: PUBLIC.ORDER_ITEMS ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }
  dimension: cost {

    sql: ${products.cost} ;;
  }
  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }
  dimension_group: since_event {
    type: duration
    intervals: [hour, day, week, month, quarter, year]
    sql_start: ${created_date} ;;
    sql_end: ${delivered_date};;
  }
  dimension: status1 {
    sql: ${status} ;;
    html: {% if value == 'Shipped' or value == 'Complete' %}
         <p> <img src="C:/Users/BAPATLA/Downloads/age-limit.png" height=20 width=20>{{ rendered_value }}</p>
      {% elsif value == 'Processing' %}
        <p><img src="http://findicons.com/files/icons/1681/siena/128/clock_blue.png" height=20 width=20>{{ rendered_value }}</p>
      {% else %}
        <p><img src="http://findicons.com/files/icons/719/crystal_clear_actions/64/cancel.png" height=20 width=20>{{ rendered_value }}</p>
      {% endif %}
;;
  }
  measure: average_days_since_event {
    type: average
    sql: ${weeks_since_event} ;;
  }

  measure: average_days {
    type: average
    precision: 2
    sql: ${days_since_event} ;;

  }
  dimension: linked_name {
    sql: ${status};;

    required_fields: [average_days]
  }
  parameter: date_granularity {
    type: string
    allowed_value: { value: "Day" }
    allowed_value: { value: "Month" }
    allowed_value: { value: "Quarter" }
    allowed_value: { value: "Year" }
    default_value: "Month"
  }
  dimension: dates{
    label_from_parameter: date_granularity
    sql:
    CASE
    WHEN {% parameter date_granularity %} = 'Day' THEN ${created_date}::VARCHAR
    WHEN {% parameter date_granularity %} = 'Month' THEN ${created_month}::VARCHAR
    WHEN {% parameter date_granularity %} = 'Quarter' THEN ${created_quarter}::VARCHAR
    WHEN {% parameter date_granularity %} = 'Year' THEN ${created_year}::VARCHAR

  END ;;
  }


parameter: SelectMeasure {
  type: string
  allowed_value: {value:"price"}
  allowed_value: {value:"cost"}
  allowed_value: {value:"usercount"}

}

measure: data {
  label_from_parameter: SelectMeasure
  sql:
  CASE
  when {% parameter SelectMeasure %} = 'price' then SUM(${sale_price})
   when {% parameter SelectMeasure %} = 'cost' then SUM(${cost})
   when {% parameter SelectMeasure %} = 'usercount' then ${User_count}
  end
  ;;
}

  parameter: item_to_add_up {
    type: unquoted
    allowed_value: {
      label: "Total Sale Price"
      value: "sale_price"
    }
    allowed_value: {
      label: "Total Cost"
      value: "cost"
    }

  }

  measure: dynamic_sum {

    label_from_parameter: item_to_add_up
    sql:
    CASE
    WHEN {% parameter item_to_add_up %} = 'sale_price' THEN              sum(${sale_price})
    WHEN {% parameter item_to_add_up %} = 'cost' THEN  sum(${products.cost})

  END ;;

  value_format_name: "usd"
  }




  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DELIVERED_AT" ;;
  }
  parameter: measure_type {
    #suggestions: ["sum","average","count","min","max"]
    allowed_value: {value:"sum"}
    allowed_value: {value:"average"}
  }

  parameter: dimension_to_aggregate {
    type: unquoted
    allowed_value: {
      label: "Total Sale Price"
      value: "sale_price"
    }
    allowed_value: {
      label: "Count"
      value:"User_count"    }
  }

  measure: dynamic_agg {
    type: number
    label_from_parameter: dimension_to_aggregate
    sql: case when {% condition measure_type %} 'sum' {% endcondition %} then sum( ${TABLE}.{% parameter dimension_to_aggregate %})
          when {% condition measure_type %} 'average' {% endcondition %} then avg( ${TABLE}.{% parameter dimension_to_aggregate %})
          when {% condition measure_type %} 'count' {% endcondition %} then count( ${TABLE}.{% parameter dimension_to_aggregate %})
          when {% condition measure_type %} 'min' {% endcondition %} then min( ${TABLE}.{% parameter dimension_to_aggregate %})
          when {% condition measure_type %} 'max' {% endcondition %} then max( ${TABLE}.{% parameter dimension_to_aggregate %})
          else null end;;


  }
  measure: dynamic_aggr {
    type: number
    label_from_parameter: dimension_to_aggregate
    sql: case
    when  {% parameter measure_type %}='sum' then sum( ${TABLE}.{% parameter dimension_to_aggregate %})
    when  {% parameter measure_type %}='average' then avg( ${TABLE}.{% parameter dimension_to_aggregate %})
    else null end

    ;;
  }




  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: User_count {
    type: count_distinct
    sql: ${user_id} ;;

  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [

      inventory_items.product_name,sale_price


    ]
  }
}

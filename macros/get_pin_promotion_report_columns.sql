{% macro get_pin_promotion_report_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "ad_group_id", "datatype": dbt.type_string()},
    {"name": "advertiser_id", "datatype": dbt.type_string()},
    {"name": "campaign_id", "datatype": dbt.type_string()},
    {"name": "clickthrough_1", "datatype": dbt.type_numeric()},
    {"name": "clickthrough_2", "datatype": dbt.type_numeric()},
    {"name": "date", "datatype": dbt.type_timestamp()},
    {"name": "impression_1", "datatype": dbt.type_numeric()},
    {"name": "impression_2", "datatype": dbt.type_numeric()},
    {"name": "pin_promotion_id", "datatype": dbt.type_string()},
    {"name": "spend_in_micro_dollar", "datatype": dbt.type_numeric()},
    {"name": "total_lead", "datatype": dbt.type_numeric()},
    {"name": "total_click_add_to_cart", "datatype": dbt.type_numeric()},
    {"name": "total_checkout", "datatype": dbt.type_int()},
    {"name": "total_click_signup", "datatype": dbt.type_int()},
    {"name": "total_click_view_category", "datatype": dbt.type_int()},
    {"name": "total_watch_video", "datatype": dbt.type_int()},
    {"name": "cpc_in_micro_dollar", "datatype": dbt.type_numeric()},
    {"name": "cpm_in_micro_dollar", "datatype": dbt.type_numeric()},
    {"name": "ctr", "datatype": dbt.type_numeric()},
    {"name": "ctr_2", "datatype": dbt.type_numeric()},
    {"name": "ectr", "datatype": dbt.type_numeric()},
    {"name": "total_impression_frequency", "datatype": dbt.type_numeric()},
    {"name": "total_impression_user", "datatype": dbt.type_int()},
    {"name": "video_p_100_complete_1", "datatype": dbt.type_int()},
    {"name": "video_p_100_complete_2", "datatype": dbt.type_int()}
   
    
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('pinterest__pin_promotion_report_passthrough_metrics')) }}

{{ return(columns) }}

{% endmacro %}

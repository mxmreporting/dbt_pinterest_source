{{ config(enabled=var('ad_reporting__pinterest_ads_enabled', True),
    unique_key = ['source_relation','advertiser_id','date_day','campaign_id'],
    partition_by={
      "field": "date_day", 
      "data_type": "TIMESTAMP",
      "granularity": "day"
    }
    ) }}

with base as (

    select * 
    from {{ ref('stg_pinterest_ads__campaign_report_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pinterest_ads__campaign_report_tmp')),
                staging_columns=get_campaign_report_columns()
            )
        }}
    
        {{ fivetran_utils.source_relation(
            union_schema_variable='pinterest_ads_union_schemas', 
            union_database_variable='pinterest_ads_union_databases') 
        }}

    from base
),

final as (

    select
        source_relation, 
        CAST(FORMAT_TIMESTAMP("%F %T", {{ dbt.date_trunc('day', 'date') }}, "America/New_York") AS TIMESTAMP) as date_day,        --EST timezone conversion
        campaign_id,
        campaign_name,
        campaign_status,
        advertiser_id,
        coalesce(impression_1,0) + coalesce(impression_2,0) as impressions,
        coalesce(clickthrough_1,0) + coalesce(clickthrough_2,0) as clicks,
        spend_in_micro_dollar / 1000000.0 as spend

        {{ fivetran_utils.fill_pass_through_columns('pinterest__campaign_report_passthrough_metrics') }}

    from fields
)

select *
from final
where DATE(date_day) >= DATE_ADD(CURRENT_DATE(), INTERVAL -2 YEAR)

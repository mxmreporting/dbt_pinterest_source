{{ config(enabled=var('ad_reporting__pinterest_ads_enabled', True),
    unique_key = ['source_relation','ad_group_id','_fivetran_synced'],
    partition_by={
      "field": "_fivetran_synced", 
      "data_type": "TIMESTAMP",
      "granularity": "day"
    }
    ) }}

with base as (

    select *
    from {{ ref('stg_pinterest_ads__ad_group_history_tmp') }}
), 

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pinterest_ads__ad_group_history_tmp')),
                staging_columns=get_ad_group_history_columns()
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
        id as ad_group_id,
        name as ad_group_name,
        status as ad_group_status,
        ad_account_id as advertiser_id,
        CAST(FORMAT_TIMESTAMP("%F %T", _fivetran_synced, "America/New_York") AS TIMESTAMP) as _fivetran_synced,        --EST Converison
        campaign_id,
        CAST(FORMAT_TIMESTAMP("%F %T", created_time, "America/New_York") AS TIMESTAMP) as created_at,    --EST Conversion
        CAST(FORMAT_TIMESTAMP("%F %T", end_time, "America/New_York") AS TIMESTAMP) as end_time,    --EST Conversion    
        pacing_delivery_type,
        placement_group,
        start_time,
        summary_status,
        row_number() over (partition by source_relation, id order by _fivetran_synced desc) = 1 as is_most_recent_record
    from fields
)

select *
from final

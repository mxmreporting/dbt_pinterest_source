{{ config(enabled=var('ad_reporting__pinterest_ads_enabled', True),
    unique_key = ['source_relation','advertiser_id','updated_at'],
    partition_by={
      "field": "updated_at", 
      "data_type": "TIMESTAMP",
      "granularity": "day"
    }
    ) }}

with base as (

    select * 
    from {{ ref('stg_pinterest_ads__advertiser_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pinterest_ads__advertiser_history_tmp')),
                staging_columns=get_advertiser_history_columns()
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
        id as advertiser_id,
        name as advertiser_name,
        country,
        CAST(FORMAT_TIMESTAMP("%F %T", created_time, "America/New_York") AS TIMESTAMP) as created_at,    --EST Conversion
        currency as currency_code,
        owner_user_id,
        owner_username,
        advertiser_permissions, -- permissions was renamed in macro
        CAST(FORMAT_TIMESTAMP("%F %T", updated_time, "America/New_York") AS TIMESTAMP) as updated_at,    --EST Conversion
        row_number() over (partition by source_relation, id order by updated_time desc) = 1 as is_most_recent_record
    from fields
)

select *
from final

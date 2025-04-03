{{ config(
    schema='dds',
    materialized='incremental',
    unique_key='h_user_pk',
    post_hook=[
        "insert into {{ source('meta', 'data_checkpoints') }} (table_name, max_value, updated_at) \
         select 'h__user', max(registered_at), now() from {{ this }} \
         where registered_at is not null \
         on conflict (table_name) do update \
         set max_value = excluded.max_value, updated_at = excluded.updated_at"
    ]
) }}

with source as (
    select
        data ->> 'user_id' as user_id,
        (data ->> 'event_time')::timestamp as event_time,
        record_source
    from {{ source('stg', 'web__registrations') }}
    {% if is_incremental() %}
      where (data ->> 'event_time')::timestamp > {{ get_checkpoint('s__user__registration_channel') }}
    {% endif %}
),

hub as (
    select distinct
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} as h_user_pk,
        user_id,
        event_time as registered_at,
        record_source
    from source
    where user_id is not null
)

select * from hub

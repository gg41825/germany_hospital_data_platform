with source as (
    select * from {{ source('bka_raw', 'erkrankungen') }}
),

renamed as (
    select
        cast(stoid as varchar) as site_id,
        cast(name as varchar) as disease_name,
        cast(gruppe as varchar) as disease_group_code,
        case
            when cast(anzahl as varchar) = '-1' then null
            else cast(anzahl as integer)
        end as case_count
    from source
    where stoid is not null
)

select * from renamed

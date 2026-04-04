with source as (
    select * from {{ source('bka_raw', 'fachabteilungen') }}
),

renamed as (
    select
        cast(stoid as varchar) as site_id,
        cast(fabid as varchar) as department_id,
        cast(bezeichnung as varchar) as source_department_name,
        case
            when cast(anzahlfaelle as varchar) = '-1' then null
            else cast(anzahlfaelle as double precision)
        end as case_count
    from source
    where stoid is not null
)

select * from renamed

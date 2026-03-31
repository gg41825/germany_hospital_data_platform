with source as (
    select * from {{ source('bka_raw', 'erkrankungen') }}
),

renamed as (
    select
        cast(stoid as varchar) as standort_id,
        cast(name as varchar) as erkrankung_name,
        cast(gruppe as varchar) as erkrankung_gruppe_code,
        case
            when cast(anzahl as varchar) = '-1' then null
            else cast(anzahl as integer)
        end as anzahl
    from source
    where stoid is not null
)

select * from renamed

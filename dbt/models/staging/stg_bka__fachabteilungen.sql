with source as (
    select * from {{ source('bka_raw', 'fachabteilungen') }}
),

renamed as (
    select
        cast(stoid as varchar) as standort_id,
        cast(fabid as varchar) as fachabteilung_id,
        cast(bezeichnung as varchar) as fachabteilung_bezeichnung,
        case
            when cast(anzahlfaelle as varchar) = '-1' then null
            else cast(anzahlfaelle as double precision)
        end as anzahl_faelle
    from source
    where stoid is not null
)

select * from renamed

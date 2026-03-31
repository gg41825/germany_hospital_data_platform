with source as (
    select * from {{ source('bka_raw', 'standort_kontakt') }}
),

renamed as (
    select
        cast(stoid as varchar) as standort_id,
        cast(land as varchar) as bundesland_code,
        cast(name as varchar) as standort_name,
        cast(strasse as varchar) as strasse,
        cast(plz as varchar) as plz,
        cast(ort as varchar) as ort,
        cast(url as varchar) as website_url,
        cast(telefon as varchar) as telefon,
        cast(email as varchar) as email,
        cast(traegerart as varchar) as traegerart,
        cast(kinderklinik as integer) as hat_kinderklinik,
        cast(sicherstellungsauftrag as integer) as hat_sicherstellungsauftrag,
        cast(georeferenzzone as varchar) as georeferenz_zone,
        cast(georeferenzost as double precision) as georeferenz_ost,
        cast(georeferenznord as double precision) as georeferenz_nord,
        cast(laengengrad as double precision) as laengengrad,
        cast(breitengrad as double precision) as breitengrad
    from source
    where stoid is not null
)

select * from renamed

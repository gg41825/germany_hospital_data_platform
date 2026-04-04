with source as (
    select * from {{ source('bka_raw', 'standort_kontakt') }}
),

renamed as (
    select
        cast(stoid as varchar) as site_id,
        cast(land as varchar) as state_code,
        cast(name as varchar) as site_name,
        cast(strasse as varchar) as street,
        cast(plz as varchar) as postal_code,
        cast(ort as varchar) as city,
        cast(url as varchar) as website_url,
        cast(telefon as varchar) as phone,
        cast(email as varchar) as email,
        cast(traegerart as varchar) as owner_type,
        cast(kinderklinik as integer) as has_pediatric_clinic,
        cast(sicherstellungsauftrag as integer) as has_service_mandate,
        cast(georeferenzzone as varchar) as georeference_zone,
        cast(georeferenzost as double precision) as georeference_easting,
        cast(georeferenznord as double precision) as georeference_northing,
        cast(laengengrad as double precision) as longitude,
        cast(breitengrad as double precision) as latitude
    from source
    where stoid is not null
)

select * from renamed

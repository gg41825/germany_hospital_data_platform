with source as (
    select * from {{ source('bka_raw', 'standort_struktur') }}
),

renamed as (
    select
        cast(stoid as varchar) as standort_id,
        cast(nullif(trim(cast(anzahlfab as varchar)), '') as integer) as anzahl_fachabteilungen,
        cast(nullif(trim(cast(anzahlbetten as varchar)), '') as integer) as anzahl_betten,
        cast(
            nullif(trim(cast(anzahlteilstationaerbehandlungsplaetze as varchar)), '')
            as integer
        ) as anzahl_teilstationaere_behandlungsplaetze,
        cast(nullif(trim(cast(anzahlfaelle as varchar)), '') as double precision) as anzahl_faelle,
        cast(nullif(trim(cast(anzahlpfleger as varchar)), '') as double precision) as anzahl_pfleger,
        cast(
            nullif(trim(cast(pflegepersonalquotient as varchar)), '')
            as double precision
        ) as pflegepersonalquotient
    from source
    where stoid is not null
)

select * from renamed

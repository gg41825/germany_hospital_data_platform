with source as (
    select * from {{ source('bka_raw', 'standort_struktur') }}
),

renamed as (
    select
        cast(stoid as varchar) as site_id,
        cast(nullif(trim(cast(anzahlfab as varchar)), '') as integer) as department_count,
        cast(nullif(trim(cast(anzahlbetten as varchar)), '') as integer) as bed_count,
        cast(
            nullif(trim(cast(anzahlteilstationaerbehandlungsplaetze as varchar)), '')
            as integer
        ) as day_treatment_capacity,
        cast(nullif(trim(cast(anzahlfaelle as varchar)), '') as double precision) as case_count,
        cast(nullif(trim(cast(anzahlpfleger as varchar)), '') as double precision) as nurse_count,
        cast(
            nullif(trim(cast(pflegepersonalquotient as varchar)), '')
            as double precision
        ) as nursing_staff_ratio
    from source
    where stoid is not null
)

select * from renamed

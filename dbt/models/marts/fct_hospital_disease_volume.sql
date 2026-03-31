with disease_volume as (
    select * from {{ ref('stg_bka__erkrankungen') }}
),

hospitals as (
    select * from {{ ref('dim_hospitals') }}
)

select
    disease_volume.standort_id,
    hospitals.standort_name,
    hospitals.bundesland_code,
    hospitals.traegerart,
    hospitals.notfallstufe,
    hospitals.notfallstufe_beschreibung,
    disease_volume.erkrankung_gruppe_code,
    disease_volume.erkrankung_name,
    disease_volume.anzahl as case_count
from disease_volume
left join hospitals
    on disease_volume.standort_id = hospitals.standort_id

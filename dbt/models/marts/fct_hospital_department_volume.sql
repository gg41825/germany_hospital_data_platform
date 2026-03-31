with department_volume as (
    select * from {{ ref('stg_bka__fachabteilungen') }}
),

hospitals as (
    select * from {{ ref('dim_hospitals') }}
)

select
    department_volume.standort_id,
    hospitals.standort_name,
    hospitals.bundesland_code,
    hospitals.traegerart,
    hospitals.notfallstufe,
    hospitals.notfallstufe_beschreibung,
    department_volume.fachabteilung_id,
    department_volume.fachabteilung_bezeichnung,
    department_volume.anzahl_faelle as case_count
from department_volume
left join hospitals
    on department_volume.standort_id = hospitals.standort_id

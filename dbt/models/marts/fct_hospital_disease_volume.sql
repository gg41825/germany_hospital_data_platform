with disease_volume as (
    select * from {{ ref('stg_bka__erkrankungen') }}
),

hospitals as (
    select * from {{ ref('dim_hospitals') }}
)

select
    disease_volume.site_id,
    hospitals.site_name,
    hospitals.state_code,
    hospitals.owner_type,
    hospitals.emergency_level,
    hospitals.emergency_level_description,
    disease_volume.disease_group_code,
    disease_volume.disease_name,
    disease_volume.case_count
from disease_volume
left join hospitals
    on disease_volume.site_id = hospitals.site_id

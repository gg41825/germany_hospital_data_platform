with department_volume as (
    select * from {{ ref('stg_bka__fachabteilungen') }}
),

hospitals as (
    select * from {{ ref('dim_hospitals') }}
),

departments as (
    select * from {{ ref('dim_department') }}
)

select
    department_volume.site_id,
    hospitals.site_name,
    hospitals.state_code,
    hospitals.owner_type,
    hospitals.emergency_level,
    hospitals.emergency_level_description,
    department_volume.department_id,
    department_volume.source_department_name,
    departments.department_name_de,
    departments.department_name_en,
    departments.department_name_zh,
    department_volume.case_count
from department_volume
left join hospitals
    on department_volume.site_id = hospitals.site_id
left join departments
    on department_volume.source_department_name = departments.source_department_name

with disease_volume as (
    select * from {{ ref('fct_hospital_disease_volume') }}
),

benchmarked as (
    select
        site_id,
        site_name,
        state_code,
        owner_type,
        emergency_level,
        emergency_level_description,
        disease_group_code,
        disease_name,
        case_count,
        avg(case_count) over (
            partition by state_code, disease_group_code
        ) as state_avg_case_count,
        dense_rank() over (
            partition by state_code, disease_group_code
            order by case_count desc nulls last, site_id
        ) as state_rank_for_disease,
        count(*) over (
            partition by state_code, disease_group_code
        ) as hospitals_in_state_disease_group
    from disease_volume
)

select
    site_id,
    site_name,
    state_code,
    owner_type,
    emergency_level,
    emergency_level_description,
    disease_group_code,
    disease_name,
    case_count,
    state_avg_case_count,
    case_count - state_avg_case_count as case_count_vs_state_avg,
    state_rank_for_disease,
    hospitals_in_state_disease_group
from benchmarked

with disease_volume as (
    select * from {{ ref('fct_hospital_disease_volume') }}
),

benchmarked as (
    select
        standort_id,
        standort_name,
        bundesland_code,
        traegerart,
        notfallstufe,
        notfallstufe_beschreibung,
        erkrankung_gruppe_code,
        erkrankung_name,
        case_count,
        avg(case_count) over (
            partition by bundesland_code, erkrankung_gruppe_code
        ) as state_avg_case_count,
        dense_rank() over (
            partition by bundesland_code, erkrankung_gruppe_code
            order by case_count desc nulls last, standort_id
        ) as state_rank_for_disease,
        count(*) over (
            partition by bundesland_code, erkrankung_gruppe_code
        ) as hospitals_in_state_disease_group
    from disease_volume
)

select
    standort_id,
    standort_name,
    bundesland_code,
    traegerart,
    notfallstufe,
    notfallstufe_beschreibung,
    erkrankung_gruppe_code,
    erkrankung_name,
    case_count,
    state_avg_case_count,
    case_count - state_avg_case_count as case_count_vs_state_avg,
    state_rank_for_disease,
    hospitals_in_state_disease_group
from benchmarked

with raw as (
    select distinct source_department_name
    from {{ ref('stg_bka__fachabteilungen') }}
),

normalized as (
    select
        r.source_department_name,
        m.normalized_department_name as department_name_de
    from raw r
    left join {{ ref('department_normalization_mapping') }} m
        on r.source_department_name = m.source_department_name
),

enriched as (
    select
        n.source_department_name,
        n.department_name_de,
        h.department_name_en,
        h.department_name_zh
    from normalized n
    left join {{ ref('hospital_department_mapping') }} h
        on n.department_name_de = h.department_name_de
)

select * from enriched

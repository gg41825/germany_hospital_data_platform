select
    site_id,
    disease_group_code,
    count(*) as row_count
from {{ ref('fct_hospital_disease_benchmarks') }}
group by 1, 2
having count(*) > 1

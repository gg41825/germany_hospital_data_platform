select
    standort_id,
    erkrankung_gruppe_code,
    count(*) as row_count
from {{ ref('fct_hospital_disease_benchmarks') }}
group by 1, 2
having count(*) > 1

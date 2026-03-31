select
    standort_id,
    fachabteilung_id,
    count(*) as row_count
from {{ ref('fct_hospital_department_volume') }}
group by 1, 2
having count(*) > 1

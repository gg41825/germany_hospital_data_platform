select *
from {{ ref('fct_hospital_department_volume') }}
where case_count < 0

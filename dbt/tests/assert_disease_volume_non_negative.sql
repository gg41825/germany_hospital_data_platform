select *
from {{ ref('fct_hospital_disease_volume') }}
where case_count < 0

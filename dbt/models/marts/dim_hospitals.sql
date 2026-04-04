with standort_kontakt as (
    select * from {{ ref('stg_bka__standort_kontakt') }}
),

standort_struktur as (
    select * from {{ ref('stg_bka__standort_struktur') }}
),

standort_notfallversorgung as (
    select * from {{ ref('stg_bka__standort_notfallversorgung') }}
)

select
    kontakt.site_id,
    kontakt.site_name,
    kontakt.state_code,
    kontakt.street,
    kontakt.postal_code,
    kontakt.city,
    kontakt.website_url,
    kontakt.phone,
    kontakt.email,
    kontakt.owner_type,
    kontakt.has_pediatric_clinic,
    kontakt.has_service_mandate,
    kontakt.georeference_zone,
    kontakt.georeference_easting,
    kontakt.georeference_northing,
    kontakt.longitude,
    kontakt.latitude,
    struktur.department_count,
    struktur.bed_count,
    struktur.day_treatment_capacity,
    struktur.case_count,
    struktur.nurse_count,
    struktur.nursing_staff_ratio,
    notfall.emergency_level,
    notfall.emergency_level_description,
    notfall.has_trauma_care_module,
    notfall.trauma_care_description,
    notfall.pediatric_emergency_level,
    notfall.pediatric_emergency_description,
    notfall.has_special_emergency_care,
    notfall.special_emergency_description,
    notfall.has_stroke_unit,
    notfall.stroke_unit_description,
    notfall.has_chest_pain_unit,
    notfall.chest_pain_unit_description,
    notfall.is_not_classified_in_emergency_system,
    notfall.emergency_system_participation_description
from standort_kontakt as kontakt
left join standort_struktur as struktur
    on kontakt.site_id = struktur.site_id
left join standort_notfallversorgung as notfall
    on kontakt.site_id = notfall.site_id

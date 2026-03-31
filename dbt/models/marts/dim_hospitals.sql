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
    kontakt.standort_id,
    kontakt.standort_name,
    kontakt.bundesland_code,
    kontakt.strasse,
    kontakt.plz,
    kontakt.ort,
    kontakt.website_url,
    kontakt.telefon,
    kontakt.email,
    kontakt.traegerart,
    kontakt.hat_kinderklinik,
    kontakt.hat_sicherstellungsauftrag,
    kontakt.georeferenz_zone,
    kontakt.georeferenz_ost,
    kontakt.georeferenz_nord,
    kontakt.laengengrad,
    kontakt.breitengrad,
    struktur.anzahl_fachabteilungen,
    struktur.anzahl_betten,
    struktur.anzahl_teilstationaere_behandlungsplaetze,
    struktur.anzahl_faelle,
    struktur.anzahl_pfleger,
    struktur.pflegepersonalquotient,
    notfall.emergency_level as notfallstufe,
    notfall.emergency_level_description as notfallstufe_beschreibung,
    notfall.has_trauma_care_module as hat_schwerverletztenversorgung,
    notfall.trauma_care_description as schwerverletztenversorgung_beschreibung,
    notfall.pediatric_emergency_level as hat_kindernotfallversorgung,
    notfall.pediatric_emergency_description as kindernotfallversorgung_beschreibung,
    notfall.has_special_emergency_care as hat_spezialversorgung,
    notfall.special_emergency_description as spezialversorgung_beschreibung,
    notfall.has_stroke_unit as hat_stroke_unit,
    notfall.stroke_unit_description as stroke_unit_beschreibung,
    notfall.has_chest_pain_unit as hat_chest_pain_unit,
    notfall.chest_pain_unit_description as chest_pain_unit_beschreibung,
    notfall.is_not_classified_in_emergency_system as stufe_nicht_vereinbart,
    notfall.emergency_system_participation_description as stufe_nicht_vereinbart_beschreibung
from standort_kontakt as kontakt
left join standort_struktur as struktur
    on kontakt.standort_id = struktur.standort_id
left join standort_notfallversorgung as notfall
    on kontakt.standort_id = notfall.standort_id

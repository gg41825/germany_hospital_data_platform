with source as (
    select * 
    from {{ source('bka_raw', 'standort_notfallversorgung') }}
),

typed as (
    select
        cast(stoid as varchar) as site_id,
        cast(stufe as integer) as stufe,
        cast(schwerverletztenversorgung as integer) as schwerverletztenversorgung,
        cast(kinder as integer) as kinder,
        cast(spezialversorgung as integer) as spezialversorgung,
        cast(strokeunit as integer) as strokeunit,
        cast(chestpainunit as integer) as chestpainunit,
        cast(stufenichtvereinbart as integer) as stufenichtvereinbart
    from source
    where stoid is not null
),

renamed as (
    select
        site_id,

        -- Emergency level
        stufe as emergency_level,
        case 
            when stufe is null then null
            when stufe = 0 then 'No emergency care (keine Notfallversorgung)'
            when stufe = 1 then 'Basic emergency care (Basisnotfallversorgung)'
            when stufe = 2 then 'Extended emergency care (Erweiterte Notfallversorgung)'
            when stufe = 3 then 'Comprehensive emergency care (Umfassende Notfallversorgung)'
            when stufe = 9 then 'Other / not classified (Sonstige / keine Zuordnung)'
            else 'Unknown code'
        end as emergency_level_description,

        -- Trauma care module
        schwerverletztenversorgung as has_trauma_care_module,
        case 
            when schwerverletztenversorgung is null then null
            when schwerverletztenversorgung = 0 then 'No trauma care module (kein Modul)'
            when schwerverletztenversorgung = 1 then 'Trauma center (Traumazentrum, equivalent to level 2)'
            else 'Unknown code'
        end as trauma_care_description,

        -- Pediatric emergency care
        kinder as pediatric_emergency_level,
        case 
            when kinder is null then null
            when kinder = 0 then 'No pediatric emergency care (keine Kindernotfallversorgung)'
            when kinder = 1 then 'Basic pediatric emergency care (Basisnotfallversorgung Kinder)'
            when kinder = 2 then 'Extended pediatric emergency care (Erweiterte Notfallversorgung Kinder)'
            when kinder = 3 then 'Comprehensive pediatric emergency care (Umfassende Notfallversorgung Kinder)'
            else 'Unknown code'
        end as pediatric_emergency_description,

        -- Special emergency care
        spezialversorgung as has_special_emergency_care,
        case 
            when spezialversorgung is null then null
            when spezialversorgung = 0 then 'No special emergency care (keine Spezialversorgung)'
            when spezialversorgung = 1 then 'Special emergency care (Spezialversorgung, separate system)'
            else 'Unknown code'
        end as special_emergency_description,

        -- Stroke unit module
        strokeunit as has_stroke_unit,
        case 
            when strokeunit is null then null
            when strokeunit = 0 then 'No stroke unit (kein Modul)'
            when strokeunit = 1 then 'Stroke unit (Stroke Unit, equivalent to level 1)'
            else 'Unknown code'
        end as stroke_unit_description,

        -- Chest pain unit module
        chestpainunit as has_chest_pain_unit,
        case 
            when chestpainunit is null then null
            when chestpainunit = 0 then 'No chest pain unit (kein Modul)'
            when chestpainunit = 1 then 'Chest pain unit (CPU, equivalent to level 1)'
            else 'Unknown code'
        end as chest_pain_unit_description,

        -- Participation in emergency classification system
        stufenichtvereinbart as is_not_classified_in_emergency_system,
        case 
            when stufenichtvereinbart is null then null
            when stufenichtvereinbart = 0 then 'Participates in emergency level system (nimmt am Notfallstufensystem teil)'
            when stufenichtvereinbart = 1 then 'Not part of emergency level system (nimmt nicht am Notfallstufensystem teil)'
            else 'Unknown code'
        end as emergency_system_participation_description

    from typed
)

select * 
from renamed

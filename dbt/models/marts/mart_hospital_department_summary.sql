with base as (
    select *
    from {{ ref('fct_hospital_department_volume') }}
),

hospitals as (
    select *
    from {{ ref('dim_hospitals') }}
)

select
    base.site_id,
    base.site_name,
    base.state_code,
    hospitals.street,
    hospitals.postal_code,
    hospitals.city,
    concat_ws(
        ', ',
        nullif(trim(hospitals.street), ''),
        nullif(trim(concat_ws(' ', hospitals.postal_code, hospitals.city)), '')
    ) as address,
    case
        when hospitals.latitude is not null and hospitals.longitude is not null then
            concat(
                'https://www.google.com/maps/search/?api=1&query=',
                hospitals.latitude,
                ',',
                hospitals.longitude
            )
    end as google_map_url,
    hospitals.phone,
    hospitals.website_url,
    hospitals.email,
    base.owner_type,
    base.emergency_level,
    base.emergency_level_description,

    string_agg(distinct base.department_name_de, ', ') as departments,

    count(distinct base.department_name_de) as department_count

from base
left join hospitals
    on base.site_id = hospitals.site_id
group by
    base.site_id,
    base.site_name,
    base.state_code,
    hospitals.street,
    hospitals.postal_code,
    hospitals.city,
    hospitals.latitude,
    hospitals.longitude,
    hospitals.phone,
    hospitals.website_url,
    hospitals.email,
    base.owner_type,
    base.emergency_level,
    base.emergency_level_description

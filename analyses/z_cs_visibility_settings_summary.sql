-- placeholder for future CS export
-- see: https://github.com/Frog-Street/bi-infra/tree/de9766be99e785b8f9e97458db1c3da2c9972536/scripts/visibilitySettingsSummary
with teachers_summary as (
    select u.id,
        u.district_id,
        e.school_id,
        e.class_id,
        r.tag AS user_role
    FROM users u
        JOIN enrollments e ON u.id = e.user_id
        JOIN roles r ON r.id = u.role_id
    where r.tag = 'teacher'
        and e.status = 'active'
),
students_summary as (
    select u.id,
        u.district_id,
        e.school_id,
        e.class_id,
        r.tag AS user_role
    FROM users u
        JOIN enrollments e ON u.id = e.user_id
        JOIN roles r ON r.id = u.role_id
    where r.tag = 'student'
        and e.status = 'active'
),
visibilities_summary_programs as (
    select pvs.id,
        d.id as district_id,
        d."name" as "district_name",
        pvs.program_id,
        null as "school_name",
        null::int as "school_id",
        null as "class_name",
        null::int as "class_id",
        ts.id as user_id
    from program_visibility_settings pvs
        join district d on d.id = pvs.district_id
        join teachers_summary ts on ts.district_id = d.id
    where pvs.deleted_at isnull
        and pvs."enabled" = true
    union all
    select pvs.id,
        d.id as district_id,
        d."name" as "district_name",
        pvs.program_id,
        s."name" as "school_name",
        s.id as "school_id",
        null as "class_name",
        null::int as "class_id",
        ts.id as user_id
    from program_visibility_settings pvs
        join schools s on s.id = pvs.school_id
        join district d on d.id = s.district_id
        join teachers_summary ts on ts.school_id = s.id
    where pvs.deleted_at isnull
        and pvs."enabled" = true
    union all
    select pvs.id,
        d.id as district_id,
        d."name" as "district_name",
        pvs.program_id,
        s."name" as "school_name",
        s.id as "school_id",
        c."name" as "class_name",
        c.id as "class_id",
        ts.id as user_id
    from program_visibility_settings pvs
        join classes c on c.id = pvs.class_id
        join schools s on s.id = c.school_id
        join district d on d.id = s.district_id
        join teachers_summary ts on ts.class_id = c.id
    where pvs.deleted_at isnull
        and pvs."enabled" = true
),
visibilities_summary_applications as (
    select avs.id,
        d.id as district_id,
        d."name" as "district_name",
        avs.application_id,
        null as "school_name",
        null::int as "school_id",
        null as "class_name",
        null::int as "class_id",
        ss.id as user_id
    from application_visibility_settings avs
        join district d on d.id = avs.district_id
        join students_summary ss on ss.district_id = d.id
    where avs.deleted_at isnull
        and avs."enabled" = true
    union all
    select avs.id,
        d.id as district_id,
        d."name" as "district_name",
        avs.application_id,
        s."name" as "school_name",
        s.id as "school_id",
        null as "class_name",
        null::int as "class_id",
        ss.id as user_id
    from application_visibility_settings avs
        join schools s on s.id = avs.school_id
        join district d on d.id = s.district_id
        join students_summary ss on ss.school_id = s.id
    where avs.deleted_at isnull
        and avs."enabled" = true
    union all
    select avs.id,
        d.id as district_id,
        d."name" as "district_name",
        avs.application_id,
        s."name" as "school_name",
        s.id as "school_id",
        c."name" as "class_name",
        c.id as "class_id",
        ss.id as user_id
    from application_visibility_settings avs
        join classes c on c.id = avs.class_id
        join schools s on s.id = c.school_id
        join district d on d.id = s.district_id
        join students_summary ss on ss.class_id = c.id
    where avs.deleted_at isnull
        and avs."enabled" = true
)
SELECT d.id || '-' || dp.program_id || '-' || dpl.id || '-' || 'program' as "row_id",
    d.id as "district_id",
    d."name" as "district_name",
    'program' as "program_or_application",
    dp.program_id as "program_or_application_id",
    'PROGRAM_NAME' as "program_or_application_name",
    to_timestamp(dpl.expiration_date) as "expiration_date",
    dpl.updated_at as "last_updated_at_utc",
    dpl.quantity_licenses as "n_licenses",
    array_agg(distinct vsp.school_id) FILTER (
        WHERE vsp.school_id IS NOT NULL
    ) as "school_ids",
    array_agg(distinct vsp.school_name) FILTER (
        WHERE vsp.school_name IS NOT NULL
    ) as "school_names",
    count(distinct vsp.school_id) FILTER (
        WHERE vsp.school_id IS NOT NULL
    ) as "n_schools",
    array_agg(distinct vsp.class_id) FILTER (
        WHERE vsp.class_id IS NOT NULL
    ) as "classroom_ids",
    array_agg(distinct vsp.class_name) FILTER (
        WHERE vsp.class_name IS NOT NULL
    ) as "classroom_names",
    count(distinct vsp.class_id) FILTER (
        WHERE vsp.class_id IS NOT NULL
    ) as "n_classrooms",
    count(distinct vsp.user_id) as n_teachers_or_students_alocated
from district d
    join districts_programs dp on dp.district_id = d.id
    join district_program_licenses dpl on d.id = dpl.district_id
    and dp.program_id = dpl.program_id
    left join visibilities_summary_programs vsp on vsp.district_id = d.id
    and vsp.program_id = dpl.program_id
where dpl.deleted_at isnull
    and d.id = 17
group by d.id,
    d."name",
    dp.program_id,
    dpl.id,
    dpl.expiration_date,
    dpl.updated_at,
    dpl.quantity_licenses
union all
SELECT d.id || '-' || da.application_id || '-' || dal.id || '-' || 'application' as "row_id",
    d.id as "district_id",
    d."name" as "district_name",
    'application' as "program_or_application",
    da.application_id as "program_or_application_id",
    a."name" as "program_or_application_name",
    to_timestamp(dal.expiration_date) as "expiration_date",
    dal.updated_at as "last_updated_at_utc",
    dal.quantity_licenses as "n_licenses",
    array_agg(distinct vsa.school_id) FILTER (
        WHERE vsa.school_id IS NOT NULL
    ) as "school_ids",
    array_agg(distinct vsa.school_name) FILTER (
        WHERE vsa.school_name IS NOT NULL
    ) as "school_names",
    count(distinct vsa.school_id) FILTER (
        WHERE vsa.school_id IS NOT NULL
    ) as "n_schools",
    array_agg(distinct vsa.class_id) FILTER (
        WHERE vsa.class_id IS NOT NULL
    ) as "classroom_ids",
    array_agg(distinct vsa.class_name) FILTER (
        WHERE vsa.class_name IS NOT NULL
    ) as "classroom_names",
    count(distinct vsa.class_id) FILTER (
        WHERE vsa.class_id IS NOT NULL
    ) as "n_classrooms",
    count(distinct vsa.user_id) as "n_teachers_or_students_alocated"
from district d
    join district_applications da on da.district_id = d.id
    join district_application_licenses dal on d.id = dal.district_id
    and da.application_id = dal.application_id
    join applications a on a.id = da.application_id
    left join visibilities_summary_applications vsa on vsa.district_id = d.id
    and vsa.application_id = dal.application_id
where dal.deleted_at isnull
    and d."type" != 'demo-test'
group by d.id,
    d."name",
    da.application_id,
    dal.id,
    a."name",
    to_timestamp(dal.expiration_date),
    dal.updated_at,
    dal.quantity_licenses
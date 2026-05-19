create table if not exists app_settings (
  id boolean primary key default true,
  allow_public_registration boolean not null default false,
  registration_message text not null default 'Los registros publicos estan cerrados. Contacta al administrador de FonoClinic.',
  updated_at timestamptz not null default now(),
  constraint app_settings_singleton check (id)
);

insert into app_settings (id, allow_public_registration)
values (true, false)
on conflict (id) do nothing;

create table if not exists app_admins (
  email text primary key,
  nombre text,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  constraint app_admins_email_lower check (email = lower(email))
);

insert into app_admins (email, nombre)
values ('luisocampo20022015@gmail.com', 'Luis Ocampo')
on conflict (email) do nothing;

alter table app_settings enable row level security;
alter table app_admins enable row level security;

create or replace function public.is_platform_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.app_admins
    where email = lower(coalesce(auth.jwt() ->> 'email', ''))
      and activo = true
  );
$$;

revoke execute on function public.is_platform_admin() from anon, public;
grant execute on function public.is_platform_admin() to authenticated;

create or replace function public.get_public_app_settings()
returns table (
  allow_public_registration boolean,
  registration_message text
)
language sql
security definer
stable
set search_path = public
as $$
  select s.allow_public_registration, s.registration_message
  from public.app_settings s
  where s.id = true;
$$;

grant execute on function public.get_public_app_settings() to anon, authenticated;

create or replace function public.admin_get_settings()
returns table (
  allow_public_registration boolean,
  registration_message text
)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not public.is_platform_admin() then
    raise exception 'Solo administradores de plataforma pueden ver esta configuracion'
      using errcode = '42501';
  end if;

  return query
  select s.allow_public_registration, s.registration_message
  from public.app_settings s
  where s.id = true;
end;
$$;

revoke execute on function public.admin_get_settings() from anon, public;
grant execute on function public.admin_get_settings() to authenticated;

create or replace function public.admin_update_settings(
  p_allow_public_registration boolean,
  p_registration_message text
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_platform_admin() then
    raise exception 'Solo administradores de plataforma pueden actualizar registros'
      using errcode = '42501';
  end if;

  update public.app_settings
  set allow_public_registration = p_allow_public_registration,
      registration_message = coalesce(nullif(trim(p_registration_message), ''), registration_message),
      updated_at = now()
  where id = true;
end;
$$;

revoke execute on function public.admin_update_settings(boolean, text) from anon, public;
grant execute on function public.admin_update_settings(boolean, text) to authenticated;

create or replace function public.tenant_subscription_active(p_tenant_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.tenants t
    where t.id = p_tenant_id
      and (
        t.estado = 'activo'
        or (t.estado = 'trial' and (t.trial_ends_at is null or t.trial_ends_at > now()))
      )
  );
$$;

revoke execute on function public.tenant_subscription_active(uuid) from anon, public;
grant execute on function public.tenant_subscription_active(uuid) to authenticated;

create or replace function public.current_tenant_has_access()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.tenant_subscription_active(public.current_tenant_id());
$$;

revoke execute on function public.current_tenant_has_access() from anon, public;
grant execute on function public.current_tenant_has_access() to authenticated;

create or replace function public.admin_list_tenants()
returns table (
  id uuid,
  nombre text,
  email_admin text,
  estado text,
  trial_ends_at timestamptz,
  created_at timestamptz,
  plan_nombre text,
  usuarios_count bigint,
  pacientes_count bigint
)
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if not public.is_platform_admin() then
    raise exception 'Solo administradores de plataforma pueden listar suscripciones'
      using errcode = '42501';
  end if;

  return query
  select
    t.id,
    t.nombre,
    t.email_admin,
    t.estado,
    t.trial_ends_at,
    t.created_at,
    p.nombre as plan_nombre,
    (select count(*) from public.usuarios u where u.tenant_id = t.id) as usuarios_count,
    (select count(*) from public.pacientes pa where pa.tenant_id = t.id) as pacientes_count
  from public.tenants t
  left join public.planes_suscripcion p on p.id = t.plan_id
  order by t.created_at desc;
end;
$$;

revoke execute on function public.admin_list_tenants() from anon, public;
grant execute on function public.admin_list_tenants() to authenticated;

create or replace function public.admin_update_tenant(
  p_tenant_id uuid,
  p_estado text,
  p_trial_ends_at timestamptz default null
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_platform_admin() then
    raise exception 'Solo administradores de plataforma pueden actualizar suscripciones'
      using errcode = '42501';
  end if;

  if p_estado not in ('trial', 'activo', 'suspendido', 'cancelado') then
    raise exception 'Estado de suscripcion no valido'
      using errcode = '22023';
  end if;

  update public.tenants
  set estado = p_estado,
      trial_ends_at = case
        when p_estado = 'trial' then coalesce(p_trial_ends_at, trial_ends_at, now() + interval '14 days')
        else p_trial_ends_at
      end
  where id = p_tenant_id;
end;
$$;

revoke execute on function public.admin_update_tenant(uuid, text, timestamptz) from anon, public;
grant execute on function public.admin_update_tenant(uuid, text, timestamptz) to authenticated;

create or replace function public.registrar_tenant(
  p_user_id uuid,
  p_nombre text,
  p_email text,
  p_consultorio text,
  p_tarjeta_profesional text
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_plan_id uuid;
  v_tenant_id uuid;
  v_allow_registration boolean;
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'registrar_tenant solo puede ejecutarse para el usuario autenticado'
      using errcode = '42501';
  end if;

  select allow_public_registration
  into v_allow_registration
  from public.app_settings
  where id = true;

  if coalesce(v_allow_registration, false) = false and not public.is_platform_admin() then
    raise exception 'Los registros publicos estan cerrados. Contacta al administrador de FonoClinic.'
      using errcode = '42501';
  end if;

  insert into planes_suscripcion (nombre, precio_cop, max_pacientes, max_usuarios, funcionalidades)
  values ('Trial', 0, 50, 1, '["pacientes","evoluciones","agenda","pdf"]'::jsonb)
  on conflict (nombre) do update set nombre = excluded.nombre
  returning id into v_plan_id;

  insert into tenants (nombre, email_admin, plan_id)
  values (p_consultorio, p_email, v_plan_id)
  returning id into v_tenant_id;

  insert into usuarios (id, tenant_id, email, nombre, rol, consultorio, tarjeta_profesional)
  values (p_user_id, v_tenant_id, p_email, p_nombre, 'admin', p_consultorio, p_tarjeta_profesional);

  update auth.users
  set raw_user_meta_data = coalesce(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('tenant_id', v_tenant_id)
  where id = p_user_id;

  return v_tenant_id;
end;
$$;

revoke execute on function public.registrar_tenant(uuid, text, text, text, text) from anon, public;
grant execute on function public.registrar_tenant(uuid, text, text, text, text) to authenticated;

drop policy if exists app_settings_admin_select on app_settings;
drop policy if exists app_admins_admin_select on app_admins;
drop policy if exists pacientes_select on pacientes;
drop policy if exists pacientes_insert on pacientes;
drop policy if exists pacientes_update on pacientes;
drop policy if exists datos_area_tenant on datos_clinicos_area;
drop policy if exists evoluciones_select_insert on evoluciones;
drop policy if exists evoluciones_insert on evoluciones;
drop policy if exists citas_tenant on citas;
drop policy if exists imagenes_tenant on imagenes_clinicas;

create policy app_settings_admin_select
on app_settings for select
using (public.is_platform_admin());

create policy app_admins_admin_select
on app_admins for select
using (public.is_platform_admin());

create policy pacientes_select
on pacientes for select
using (tenant_id = current_tenant_id() and public.current_tenant_has_access());

create policy pacientes_insert
on pacientes for insert
with check (tenant_id = current_tenant_id() and public.current_tenant_has_access());

create policy pacientes_update
on pacientes for update
using (tenant_id = current_tenant_id() and public.current_tenant_has_access())
with check (tenant_id = current_tenant_id() and public.current_tenant_has_access());

create policy datos_area_tenant
on datos_clinicos_area for all
using (tenant_id = current_tenant_id() and public.current_tenant_has_access())
with check (tenant_id = current_tenant_id() and public.current_tenant_has_access());

create policy evoluciones_select_insert
on evoluciones for select
using (tenant_id = current_tenant_id() and public.current_tenant_has_access());

create policy evoluciones_insert
on evoluciones for insert
with check (tenant_id = current_tenant_id() and public.current_tenant_has_access());

create policy citas_tenant
on citas for all
using (tenant_id = current_tenant_id() and public.current_tenant_has_access())
with check (tenant_id = current_tenant_id() and public.current_tenant_has_access());

create policy imagenes_tenant
on imagenes_clinicas for all
using (tenant_id = current_tenant_id() and public.current_tenant_has_access())
with check (tenant_id = current_tenant_id() and public.current_tenant_has_access());

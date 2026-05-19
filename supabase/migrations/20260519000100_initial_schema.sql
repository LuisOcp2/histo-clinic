create extension if not exists "pgcrypto";

create table if not exists planes_suscripcion (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  precio_cop integer not null default 0,
  max_pacientes integer not null default 50,
  max_usuarios smallint not null default 1,
  funcionalidades jsonb not null default '[]'::jsonb,
  activo boolean not null default true
);

create table if not exists tenants (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  email_admin text not null unique,
  plan_id uuid references planes_suscripcion(id),
  estado text not null default 'trial',
  trial_ends_at timestamptz default now() + interval '14 days',
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists usuarios (
  id uuid primary key references auth.users(id) on delete cascade,
  tenant_id uuid not null references tenants(id) on delete cascade,
  email text not null,
  nombre text not null,
  rol text not null default 'admin',
  consultorio text,
  tarjeta_profesional text,
  created_at timestamptz not null default now()
);

create table if not exists pacientes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references tenants(id) on delete cascade,
  codigo text not null,
  nombres text not null,
  apellidos text not null,
  tipo_doc text not null,
  num_doc text not null,
  fecha_nacimiento date not null,
  sexo text not null,
  telefono text,
  email text,
  direccion text,
  eps text,
  acudiente_nombre text,
  acudiente_tel text,
  area_atencion text not null,
  diagnostico_cie10 text not null,
  consentimiento_firmado boolean not null default false,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, codigo),
  unique (tenant_id, tipo_doc, num_doc)
);

create table if not exists datos_clinicos_area (
  id uuid primary key default gen_random_uuid(),
  paciente_id uuid not null references pacientes(id) on delete cascade,
  tenant_id uuid not null references tenants(id) on delete cascade,
  area text not null,
  datos jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (paciente_id)
);

create table if not exists evoluciones (
  id uuid primary key default gen_random_uuid(),
  paciente_id uuid not null references pacientes(id) on delete restrict,
  tenant_id uuid not null references tenants(id) on delete cascade,
  profesional_id uuid not null references usuarios(id),
  fecha_atencion timestamptz not null,
  num_sesion integer not null,
  modalidad text not null,
  motivo_consulta text not null,
  hallazgos text not null,
  intervencion text not null,
  respuesta_paciente text not null,
  plan text not null,
  datos_area jsonb not null default '{}'::jsonb,
  proxima_cita date,
  created_at timestamptz not null default now(),
  unique (paciente_id, num_sesion)
);

create table if not exists citas (
  id uuid primary key default gen_random_uuid(),
  paciente_id uuid not null references pacientes(id) on delete restrict,
  tenant_id uuid not null references tenants(id) on delete cascade,
  profesional_id uuid not null references usuarios(id),
  fecha_hora timestamptz not null,
  duracion_min smallint not null default 45,
  tipo_cita text not null,
  modalidad text not null,
  estado text not null default 'Programada',
  notas text,
  link_virtual text,
  created_at timestamptz not null default now()
);

create table if not exists imagenes_clinicas (
  id uuid primary key default gen_random_uuid(),
  paciente_id uuid not null references pacientes(id) on delete restrict,
  tenant_id uuid not null references tenants(id) on delete cascade,
  url text not null,
  descripcion text,
  created_at timestamptz not null default now()
);

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
begin
  if auth.uid() is null or auth.uid() <> p_user_id then
    raise exception 'registrar_tenant solo puede ejecutarse para el usuario autenticado'
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

create or replace function public.generar_codigo_paciente(p_tenant_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_year text := to_char(now(), 'YYYY');
  v_next integer;
begin
  if public.current_tenant_id() is distinct from p_tenant_id then
    raise exception 'tenant no autorizado para generar codigo de paciente'
      using errcode = '42501';
  end if;

  select coalesce(max(split_part(codigo, '-', 3)::integer), 0) + 1
  into v_next
  from pacientes
  where tenant_id = p_tenant_id and codigo like 'FC-' || v_year || '-%';

  return 'FC-' || v_year || '-' || lpad(v_next::text, 3, '0');
end;
$$;

create or replace function public.asignar_num_sesion()
returns trigger
language plpgsql
as $$
begin
  select coalesce(max(num_sesion), 0) + 1
  into new.num_sesion
  from evoluciones
  where paciente_id = new.paciente_id;
  return new;
end;
$$;

drop trigger if exists trg_num_sesion on evoluciones;
create trigger trg_num_sesion
before insert on evoluciones
for each row execute function asignar_num_sesion();

alter table tenants enable row level security;
alter table usuarios enable row level security;
alter table pacientes enable row level security;
alter table datos_clinicos_area enable row level security;
alter table evoluciones enable row level security;
alter table citas enable row level security;
alter table imagenes_clinicas enable row level security;

create or replace function public.current_tenant_id()
returns uuid
language sql
security definer
stable
set search_path = public
as $$
  select tenant_id from public.usuarios where id = auth.uid();
$$;

revoke execute on function public.current_tenant_id() from anon, public;
grant execute on function public.current_tenant_id() to authenticated;

drop policy if exists tenant_select on tenants;
drop policy if exists usuarios_tenant on usuarios;
drop policy if exists pacientes_tenant on pacientes;
drop policy if exists pacientes_select on pacientes;
drop policy if exists pacientes_insert on pacientes;
drop policy if exists pacientes_update on pacientes;
drop policy if exists datos_area_tenant on datos_clinicos_area;
drop policy if exists evoluciones_select_insert on evoluciones;
drop policy if exists evoluciones_insert on evoluciones;
drop policy if exists citas_tenant on citas;
drop policy if exists imagenes_tenant on imagenes_clinicas;

create policy tenant_select on tenants for select using (id = current_tenant_id());
create policy usuarios_tenant on usuarios for all using (tenant_id = current_tenant_id()) with check (tenant_id = current_tenant_id());
create policy pacientes_select on pacientes for select using (tenant_id = current_tenant_id());
create policy pacientes_insert on pacientes for insert with check (tenant_id = current_tenant_id());
create policy pacientes_update on pacientes for update using (tenant_id = current_tenant_id()) with check (tenant_id = current_tenant_id());
create policy datos_area_tenant on datos_clinicos_area for all using (tenant_id = current_tenant_id()) with check (tenant_id = current_tenant_id());
create policy evoluciones_select_insert on evoluciones for select using (tenant_id = current_tenant_id());
create policy evoluciones_insert on evoluciones for insert with check (tenant_id = current_tenant_id());
create policy citas_tenant on citas for all using (tenant_id = current_tenant_id()) with check (tenant_id = current_tenant_id());
create policy imagenes_tenant on imagenes_clinicas for all using (tenant_id = current_tenant_id()) with check (tenant_id = current_tenant_id());

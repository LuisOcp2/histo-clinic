create table if not exists evolucion_anexos (
  id uuid primary key default gen_random_uuid(),
  evolucion_id uuid not null references evoluciones(id) on delete restrict,
  tenant_id uuid not null references tenants(id) on delete cascade,
  profesional_id uuid not null references usuarios(id),
  tipo text not null,
  contenido text not null,
  created_at timestamptz not null default now(),
  constraint evolucion_anexos_tipo_check check (tipo in ('nota_aclaratoria', 'enmienda')),
  constraint evolucion_anexos_contenido_check check (length(trim(contenido)) > 0)
);

alter table evolucion_anexos enable row level security;

drop policy if exists evolucion_anexos_select on evolucion_anexos;
drop policy if exists evolucion_anexos_insert on evolucion_anexos;

create policy evolucion_anexos_select
on evolucion_anexos for select
using (tenant_id = current_tenant_id() and public.current_tenant_has_access());

create policy evolucion_anexos_insert
on evolucion_anexos for insert
with check (
  tenant_id = current_tenant_id()
  and public.current_tenant_has_access()
  and profesional_id = auth.uid()
);

create or replace function public.prevent_evolucion_mutation()
returns trigger
language plpgsql
as $$
begin
  raise exception 'Las notas de evolucion son inmutables. Use una nota aclaratoria o enmienda.'
    using errcode = '42501';
end;
$$;

drop trigger if exists trg_evoluciones_prevent_update on evoluciones;
create trigger trg_evoluciones_prevent_update
before update on evoluciones
for each row execute function public.prevent_evolucion_mutation();

drop trigger if exists trg_evoluciones_prevent_delete on evoluciones;
create trigger trg_evoluciones_prevent_delete
before delete on evoluciones
for each row execute function public.prevent_evolucion_mutation();

create or replace function public.prevent_evolucion_anexo_mutation()
returns trigger
language plpgsql
as $$
begin
  raise exception 'Los anexos de evolucion son inmutables.'
    using errcode = '42501';
end;
$$;

drop trigger if exists trg_evolucion_anexos_prevent_update on evolucion_anexos;
create trigger trg_evolucion_anexos_prevent_update
before update on evolucion_anexos
for each row execute function public.prevent_evolucion_anexo_mutation();

drop trigger if exists trg_evolucion_anexos_prevent_delete on evolucion_anexos;
create trigger trg_evolucion_anexos_prevent_delete
before delete on evolucion_anexos
for each row execute function public.prevent_evolucion_anexo_mutation();

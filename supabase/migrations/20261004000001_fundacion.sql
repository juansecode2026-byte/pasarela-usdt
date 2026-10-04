-- 001 Fundación: entidades legales, proyectos, llaves de API y bitácora encadenada por hash.
-- Seguridad: RLS activo en todas las tablas y SIN políticas para anon/authenticated.
-- Solo el servidor de la pasarela, con service_role, toca estas tablas. Nada se expone por la API de Supabase.

create extension if not exists pgcrypto with schema extensions;

-- Quién responde ante UIAF y DIAN. Una por SAS.
create table public.legal_entities (
  id uuid primary key default gen_random_uuid(),
  legal_name text not null,
  nit text not null unique,
  rut_resp_67_updated_at date,          -- actualización del RUT para el reporte de criptoactivos
  uiaf_sirel_user text,                 -- código o usuario de SIREL
  status text not null default 'active' check (status in ('active', 'suspended')),
  created_at timestamptz not null default now()
);

create table public.projects (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  legal_entity_id uuid not null references public.legal_entities(id),
  config jsonb not null default '{}'::jsonb,   -- ver "Configuración por proyecto" del estándar
  status text not null default 'active' check (status in ('active', 'suspended')),
  created_at timestamptz not null default now()
);

-- Llaves de API por proyecto. Solo se guarda el hash, nunca la llave.
create table public.api_keys (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id),
  key_prefix text not null,             -- primeros caracteres, para identificarla sin revelarla
  key_hash text not null unique,        -- sha256 de la llave
  status text not null default 'active' check (status in ('active', 'revoked')),
  created_at timestamptz not null default now(),
  revoked_at timestamptz
);
create index on public.api_keys (project_id);

-- Claves de idempotencia de la API (se limpian a las 24 horas).
create table public.idempotency_keys (
  project_id uuid not null references public.projects(id),
  key text not null,
  request_hash text not null,           -- hash del cuerpo: misma llave y cuerpo distinto = conflicto
  response_status int,
  response_body jsonb,
  created_at timestamptz not null default now(),
  primary key (project_id, key)
);

-- Bitácora inmutable encadenada por hash. Cada fila incluye el hash de la anterior.
create table public.audit_log (
  id bigserial primary key,
  project_id uuid references public.projects(id),
  actor text not null,
  action text not null,
  entity text not null,
  entity_id uuid,
  details jsonb,
  prev_hash text,
  hash text not null,
  at timestamptz not null default now()
);
create index on public.audit_log (entity, entity_id);

create function public.audit_log_chain() returns trigger
language plpgsql set search_path = '' as $$
declare last_hash text;
begin
  -- Serializa las inserciones para que la cadena no se bifurque.
  perform pg_advisory_xact_lock(hashtext('audit_log_chain'));
  select hash into last_hash from public.audit_log order by id desc limit 1;
  new.prev_hash := last_hash;
  new.at := now();
  new.hash := encode(extensions.digest(
    coalesce(last_hash, '') || '|' || coalesce(new.project_id::text, '') || '|' || new.actor || '|' ||
    new.action || '|' || new.entity || '|' || coalesce(new.entity_id::text, '') || '|' ||
    coalesce(new.details::text, '') || '|' || extract(epoch from new.at)::text, 'sha256'), 'hex');
  return new;
end $$;

create trigger audit_log_chain before insert on public.audit_log
  for each row execute function public.audit_log_chain();

-- Tablas que nunca se modifican ni se borran: bitácora e historial.
create function public.forbid_change() returns trigger
language plpgsql set search_path = '' as $$
begin
  raise exception '% es de solo inserción (%).', tg_table_name, tg_op;
end $$;

create trigger audit_log_immutable before update or delete on public.audit_log
  for each row execute function public.forbid_change();
create trigger audit_log_no_truncate before truncate on public.audit_log
  for each statement execute function public.forbid_change();

-- Verificación de la cadena: devuelve el id de la primera fila rota, o null si está íntegra.
create function public.audit_log_verify() returns bigint
language plpgsql stable set search_path = '' as $$
declare r record; prev text := null; expected text;
begin
  for r in select * from public.audit_log order by id loop
    if r.prev_hash is distinct from prev then return r.id; end if;
    expected := encode(extensions.digest(
      coalesce(prev, '') || '|' || coalesce(r.project_id::text, '') || '|' || r.actor || '|' ||
      r.action || '|' || r.entity || '|' || coalesce(r.entity_id::text, '') || '|' ||
      coalesce(r.details::text, '') || '|' || extract(epoch from r.at)::text, 'sha256'), 'hex');
    if expected <> r.hash then return r.id; end if;
    prev := r.hash;
  end loop;
  return null;
end $$;

alter table public.legal_entities enable row level security;
alter table public.projects enable row level security;
alter table public.api_keys enable row level security;
alter table public.idempotency_keys enable row level security;
alter table public.audit_log enable row level security;

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke execute on all functions in schema public from anon, authenticated, public;

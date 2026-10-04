-- 004 Libro contable de doble partida y cumplimiento.
-- El plan de cuentas es por proyecto (cada proyecto tiene su contador). Los códigos son ilustrativos:
-- hay que mapearlos al PUC con el contador.

create table public.ledger_accounts (
  project_id uuid not null references public.projects(id),
  code text not null,
  name text not null,
  type text not null check (type in ('asset', 'liability', 'equity', 'income', 'expense')),
  primary key (project_id, code)
);

create table public.ledger_entries (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id),
  order_id uuid,
  event text not null,
  created_at timestamptz not null default now(),
  unique (project_id, id),
  foreign key (project_id, order_id) references public.orders (project_id, id)
);

create table public.ledger_lines (
  id bigserial primary key,
  project_id uuid not null,
  entry_id uuid not null,
  account_code text not null,
  debit_cop_minor bigint not null default 0 check (debit_cop_minor >= 0),
  credit_cop_minor bigint not null default 0 check (credit_cop_minor >= 0),
  native_amount bigint,                 -- monto en la moneda original (USDT o COP)
  currency text check (currency in ('USDT', 'COP')),
  -- una línea es débito o crédito, nunca ambos ni ninguno
  check ((debit_cop_minor > 0) <> (credit_cop_minor > 0)),
  foreign key (project_id, entry_id) references public.ledger_entries (project_id, id),
  foreign key (project_id, account_code) references public.ledger_accounts (project_id, code)
);
create index on public.ledger_lines (entry_id);

-- Por asiento, débitos = créditos. Se evalúa al cerrar la transacción, para poder insertar las líneas una a una.
create function public.ledger_entry_balanced() returns trigger
language plpgsql set search_path = '' as $$
declare d bigint; c bigint;
begin
  select coalesce(sum(debit_cop_minor), 0), coalesce(sum(credit_cop_minor), 0)
    into d, c from public.ledger_lines where entry_id = new.entry_id;
  if d <> c then
    raise exception 'Asiento % descuadrado: débitos % <> créditos %.', new.entry_id, d, c;
  end if;
  return null;
end $$;
create constraint trigger ledger_entry_balanced after insert on public.ledger_lines
  deferrable initially deferred for each row execute function public.ledger_entry_balanced();

-- Un asiento sin líneas tampoco es válido.
create function public.ledger_entry_has_lines() returns trigger
language plpgsql set search_path = '' as $$
begin
  if not exists (select 1 from public.ledger_lines where entry_id = new.id) then
    raise exception 'Asiento % sin líneas.', new.id;
  end if;
  return null;
end $$;
create constraint trigger ledger_entry_has_lines after insert on public.ledger_entries
  deferrable initially deferred for each row execute function public.ledger_entry_has_lines();

-- El libro es de solo inserción: los errores se corrigen con asientos de reversa.
create trigger ledger_entries_immutable before update or delete on public.ledger_entries
  for each row execute function public.forbid_change();
create trigger ledger_lines_immutable before update or delete on public.ledger_lines
  for each row execute function public.forbid_change();

-- Cumplimiento
create table public.compliance_events (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id),
  order_id uuid,
  kind text not null check (kind in ('ROS', 'UIAF_TX', 'UIAF_CLIENT', 'CARF_USER', 'HOLD_DECISION')),
  payload jsonb not null,
  decided_by text,                      -- toda decisión manual queda con autor y motivo
  reason text,
  report_batch_id uuid,
  reported_at timestamptz,
  created_at timestamptz not null default now(),
  foreign key (project_id, order_id) references public.orders (project_id, id)
);
create index on public.compliance_events (project_id, kind, reported_at);

alter table public.ledger_accounts enable row level security;
alter table public.ledger_entries enable row level security;
alter table public.ledger_lines enable row level security;
alter table public.compliance_events enable row level security;

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke execute on all functions in schema public from anon, authenticated, public;

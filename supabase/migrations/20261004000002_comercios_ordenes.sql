-- 002 Comercios y órdenes.
-- Dinero siempre en enteros: centavos de COP (*_cop_minor) y unidades de 6 decimales de USDT (*_units).
-- Cada tabla operativa lleva project_id. Las llaves foráneas compuestas impiden mezclar proyectos.

create table public.merchants (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id),
  external_ref text,
  legal_name text not null,
  doc_type text not null check (doc_type in ('NIT', 'CC', 'CE', 'PAS')),
  doc_number text not null,
  fiscal_residence text not null default 'CO',
  kyc_status text not null default 'pending' check (kyc_status in ('pending', 'review', 'approved', 'rejected')),
  risk_level text check (risk_level in ('low', 'medium', 'high')),
  limit_per_order_cop_minor bigint check (limit_per_order_cop_minor > 0),
  limit_per_month_cop_minor bigint check (limit_per_month_cop_minor > 0),
  beneficial_owners_enc bytea,          -- cifrado a nivel de aplicación
  bank_account_enc bytea,               -- cifrado a nivel de aplicación; nunca en claro
  bank_account_last4 text,              -- único dato visible de la cuenta
  created_at timestamptz not null default now(),
  unique (project_id, id),              -- para llaves foráneas compuestas
  unique (project_id, doc_type, doc_number)
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id),
  merchant_id uuid not null,
  external_ref text not null,           -- referencia del proyecto, p. ej. HM-48213
  state text not null default 'CREATED' check (state in (
    'CREATED', 'AWAITING_PAYMENT', 'PAYMENT_DETECTED', 'CONFIRMING', 'CONFIRMED',
    'CONVERTING', 'CONVERTED', 'SETTLING', 'SETTLED', 'UNDERPAID', 'HELD_COMPLIANCE',
    'REJECTED', 'REFUND_PENDING', 'REFUNDED', 'FAILED_CONVERSION', 'FAILED_PAYOUT',
    'EXPIRED', 'CANCELLED')),
  amount_cop_minor bigint not null check (amount_cop_minor > 0),
  network text not null,
  token text not null default 'USDT',
  deposit_address text not null unique,
  usdt_expected_units bigint not null check (usdt_expected_units > 0),
  usdt_received_units bigint not null default 0 check (usdt_received_units >= 0),
  expires_at timestamptz not null,
  payment_valid_until timestamptz,      -- pago válido más allá del vencimiento (confirmaciones de red)
  metadata jsonb,
  version int not null default 0,       -- bloqueo optimista
  created_at timestamptz not null default now(),
  unique (project_id, id),
  unique (project_id, external_ref),
  foreign key (project_id, merchant_id) references public.merchants (project_id, id)
);
create index on public.orders (project_id, state);
create index on public.orders (expires_at) where state = 'AWAITING_PAYMENT';

-- Un comercio solo recibe órdenes si está aprobado.
create function public.orders_require_approved_merchant() returns trigger
language plpgsql set search_path = '' as $$
begin
  if not exists (select 1 from public.merchants
                 where id = new.merchant_id and project_id = new.project_id and kyc_status = 'approved') then
    raise exception 'El comercio % no está aprobado.', new.merchant_id;
  end if;
  return new;
end $$;
create trigger orders_require_approved_merchant before insert on public.orders
  for each row execute function public.orders_require_approved_merchant();

-- Historial de estados: solo inserción.
create table public.order_state_history (
  id bigserial primary key,
  project_id uuid not null,
  order_id uuid not null,
  from_state text not null,
  to_state text not null,
  event text not null,
  actor text not null,
  at timestamptz not null default now(),
  foreign key (project_id, order_id) references public.orders (project_id, id)
);
create index on public.order_state_history (order_id, id);
create trigger order_state_history_immutable before update or delete on public.order_state_history
  for each row execute function public.forbid_change();
create trigger order_state_history_no_truncate before truncate on public.order_state_history
  for each statement execute function public.forbid_change();

-- Las órdenes no se borran.
create trigger orders_no_delete before delete on public.orders
  for each row execute function public.forbid_change();

alter table public.merchants enable row level security;
alter table public.orders enable row level security;
alter table public.order_state_history enable row level security;

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke execute on all functions in schema public from anon, authenticated, public;

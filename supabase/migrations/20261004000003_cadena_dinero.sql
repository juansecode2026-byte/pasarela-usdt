-- 003 Cadena y dinero: transacciones on-chain, análisis AML, cotizaciones, conversiones, dispersiones y webhooks.
-- Las tablas de conversión por lote y tareas manuales de Binance se aplazan hasta cerrar el proveedor de liquidez
-- (DECISIONES.md, #5).

create table public.onchain_txs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id),
  order_id uuid,                        -- null = pago sin orden (cuarentena)
  network text not null,
  tx_hash text not null,
  log_index int not null default 0,
  from_address text not null,
  to_address text not null,
  amount_units bigint not null check (amount_units > 0),
  confirmations int not null default 0 check (confirmations >= 0),
  status text not null default 'seen' check (status in ('seen', 'confirmed', 'dropped')),
  seen_at timestamptz not null default now(),
  unique (project_id, id),
  unique (network, tx_hash, log_index),  -- idempotencia: la misma transacción nunca se procesa dos veces
  foreign key (project_id, order_id) references public.orders (project_id, id)
);
create index on public.onchain_txs (order_id);
create index on public.onchain_txs (to_address);

create table public.aml_screenings (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  onchain_tx_id uuid not null,
  provider text not null,
  risk_score numeric,
  result text not null check (result in ('pass', 'flag', 'block')),
  raw jsonb,                            -- resultado del proveedor; nunca se expone al proyecto cliente
  created_at timestamptz not null default now(),
  foreign key (project_id, onchain_tx_id) references public.onchain_txs (project_id, id)
);

create table public.quotes (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  order_id uuid not null,
  rate_cop_per_usdt_minor bigint not null check (rate_cop_per_usdt_minor > 0),
  spread_bps int not null check (spread_bps >= 0),
  source text not null,
  locked_until timestamptz not null,
  foreign key (project_id, order_id) references public.orders (project_id, id)
);

create table public.conversions (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  order_id uuid not null,
  provider text not null,
  provider_ref text,
  usdt_units bigint not null check (usdt_units > 0),
  cop_minor bigint not null check (cop_minor >= 0),
  fee_cop_minor bigint not null default 0 check (fee_cop_minor >= 0),
  effective_rate_minor bigint not null check (effective_rate_minor > 0),
  status text not null default 'pending' check (status in ('pending', 'done', 'failed')),
  executed_at timestamptz,
  foreign key (project_id, order_id) references public.orders (project_id, id),
  unique (provider, provider_ref)
);

create table public.payouts (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  order_id uuid not null,
  merchant_id uuid not null,
  amount_cop_minor bigint not null check (amount_cop_minor > 0),
  rail text not null,
  bank_ref text,
  status text not null default 'pending' check (status in ('pending', 'done', 'failed')),
  settled_at timestamptz,
  foreign key (project_id, order_id) references public.orders (project_id, id),
  foreign key (project_id, merchant_id) references public.merchants (project_id, id)
);

-- Cola de webhooks salientes. Se encola dentro de la misma transacción del cambio de estado.
create table public.webhook_events (
  id uuid primary key default gen_random_uuid(),   -- es el evt_ que ve el proyecto
  project_id uuid not null references public.projects(id),
  order_id uuid,
  type text not null,
  payload jsonb not null,
  status text not null default 'pending' check (status in ('pending', 'delivered', 'failed')),
  attempts int not null default 0,
  next_attempt_at timestamptz not null default now(),
  delivered_at timestamptz,
  created_at timestamptz not null default now()
);
create index on public.webhook_events (next_attempt_at) where status = 'pending';

alter table public.onchain_txs enable row level security;
alter table public.aml_screenings enable row level security;
alter table public.quotes enable row level security;
alter table public.conversions enable row level security;
alter table public.payouts enable row level security;
alter table public.webhook_events enable row level security;

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke execute on all functions in schema public from anon, authenticated, public;

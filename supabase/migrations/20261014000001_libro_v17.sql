-- 005 Libro contable v1.7 (ver "Libro de contabilidad blockchain/libro-contable-blockchain_v1.7").
-- Reemplaza el libro de la migración 004 (solo COP y USDT, por proyecto). Esas tablas estaban vacías.
--
-- Principios: partida doble cuadrada; solo inserción (los errores se corrigen con un asiento de reverso);
-- cada asiento lleva el hash del anterior (cadena por entidad legal); una raíz de Merkle diaria se ancla
-- fuera de la base (Bitcoin con OpenTimestamps y, opcionalmente, Ethereum); cantidades nativas en unidades
-- mínimas enteras; moneda funcional COP. El libro NO guarda llaves privadas ni mueve fondos.
--
-- El libro pertenece a una entidad legal (la SAS del proveedor). `project_id` (cliente) y `order_id` son etiquetas.

drop table public.ledger_lines;
drop table public.ledger_entries;
drop table public.ledger_accounts;
drop function public.ledger_entry_balanced();
drop function public.ledger_entry_has_lines();

-- ===== Activos =====
-- native_amount va en numeric(38,0): 1 ETH son 10^18 unidades (wei) y no caben en bigint.
create table public.assets (
  code text primary key,
  name text not null,
  kind text not null check (kind in ('crypto', 'fiat')),
  decimals int not null check (decimals between 0 and 36)
);
insert into public.assets (code, name, kind, decimals) values
  ('COP',  'Peso colombiano',       'fiat',   2),
  ('USD',  'Dólar estadounidense',  'fiat',   2),
  ('USDT', 'Tether',                'crypto', 6),
  ('BTC',  'Bitcoin',               'crypto', 8),
  ('ETH',  'Ether',                 'crypto', 18);

-- ===== Plan de cuentas (por entidad legal; códigos finales con el contador, mapeados al PUC) =====
create table public.ledger_accounts (
  legal_entity_id uuid not null references public.legal_entities(id),
  code text not null,
  name text not null,
  type text not null check (type in ('asset', 'liability', 'equity', 'income', 'expense')),
  asset_code text references public.assets(code),   -- null = la cuenta admite cualquier activo
  project_id uuid references public.projects(id),   -- detalle por cliente (fondos y obligaciones con clientes)
  primary key (legal_entity_id, code)
);

-- Wallets: solo direcciones públicas. Ninguna llave privada ni frase semilla, nunca.
create table public.wallets (
  id uuid primary key default gen_random_uuid(),
  legal_entity_id uuid not null references public.legal_entities(id),
  network text not null,
  address text not null,
  asset_code text references public.assets(code),
  owner_kind text not null check (owner_kind in ('own', 'client', 'external')),
  custody text check (custody in ('hot', 'cold', 'exchange', 'multisig')),
  project_id uuid references public.projects(id),
  account_code text,
  status text not null default 'active' check (status in ('active', 'retired')),
  created_at timestamptz not null default now(),
  unique (network, address),
  foreign key (legal_entity_id, account_code) references public.ledger_accounts (legal_entity_id, code)
);

-- ===== Tasas de cambio: TRM y precios de cripto, con fuente y hora =====
create table public.fx_rates (
  id uuid primary key default gen_random_uuid(),
  asset_code text not null references public.assets(code),
  rate_cop numeric(30, 8) not null check (rate_cop > 0),   -- COP por 1 unidad completa del activo
  source text not null,
  observed_at timestamptz not null,
  created_at timestamptz not null default now(),
  unique (asset_code, source, observed_at)
);

-- ===== Eventos crudos: evidencia tal como llegó (cadena, banco, exchange) =====
-- Un evento sin asiento es un caso en la bandeja de revisión manual; no se contabiliza solo.
create table public.raw_events (
  id uuid primary key default gen_random_uuid(),
  legal_entity_id uuid not null references public.legal_entities(id),
  source text not null check (source in ('onchain', 'bank', 'exchange')),
  network text not null default '',
  source_ref text not null,             -- hash de la transacción, referencia bancaria o id de la operación
  payload jsonb not null,
  payload_hash text not null,
  occurred_at timestamptz,
  received_at timestamptz not null default now(),
  unique (legal_entity_id, source, network, source_ref)    -- evita duplicados
);

create function public.raw_events_hash() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.payload_hash := encode(extensions.digest(new.payload::text, 'sha256'), 'hex');
  return new;
end $$;
create trigger raw_events_hash before insert on public.raw_events
  for each row execute function public.raw_events_hash();

-- ===== Asientos =====
create table public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  legal_entity_id uuid not null references public.legal_entities(id),
  seq bigint not null,                  -- posición en la cadena de esta entidad, sin saltos
  entry_date date not null,             -- fecha contable
  event text not null,
  description text,
  project_id uuid references public.projects(id),
  order_id uuid,
  raw_event_id uuid references public.raw_events(id),
  reverses_entry_id uuid unique references public.journal_entries(id),   -- un asiento solo se reversa una vez
  prev_hash text not null,              -- 'GENESIS' en el primero
  hash text not null,
  created_at timestamptz not null default now(),
  unique (legal_entity_id, seq),
  unique (legal_entity_id, id),
  foreign key (project_id, order_id) references public.orders (project_id, id)
);
create index on public.journal_entries (legal_entity_id, created_at);
create index on public.journal_entries (raw_event_id);

create table public.ledger_lines (
  id bigserial primary key,
  legal_entity_id uuid not null,
  entry_id uuid not null,
  line_no int not null,
  account_code text not null,
  asset_code text not null references public.assets(code),
  native_amount numeric(38, 0) not null check (native_amount >= 0),   -- unidades mínimas del activo
  debit_cop_minor bigint not null default 0 check (debit_cop_minor >= 0),
  credit_cop_minor bigint not null default 0 check (credit_cop_minor >= 0),
  fx_rate_id uuid references public.fx_rates(id),
  check ((debit_cop_minor > 0) <> (credit_cop_minor > 0)),   -- débito o crédito, nunca ambos ni ninguno
  unique (entry_id, line_no),
  foreign key (legal_entity_id, entry_id) references public.journal_entries (legal_entity_id, id),
  foreign key (legal_entity_id, account_code) references public.ledger_accounts (legal_entity_id, code)
);
create index on public.ledger_lines (entry_id);

-- Los asientos solo se registran con post_journal_entry(), que enciende esta marca durante la transacción.
create function public.ledger_require_posting() returns trigger
language plpgsql set search_path = '' as $$
begin
  if current_setting('ledger.posting', true) is distinct from 'on' then
    raise exception 'Los asientos solo se registran con post_journal_entry().';
  end if;
  return new;
end $$;
create trigger journal_entries_require_posting before insert on public.journal_entries
  for each row execute function public.ledger_require_posting();
create trigger ledger_lines_require_posting before insert on public.ledger_lines
  for each row execute function public.ledger_require_posting();

-- Una cuenta con activo fijo (p. ej. USDT) solo acepta ese activo.
create function public.ledger_line_asset_matches() returns trigger
language plpgsql set search_path = '' as $$
declare v_asset text;
begin
  select asset_code into v_asset from public.ledger_accounts
   where legal_entity_id = new.legal_entity_id and code = new.account_code;
  if v_asset is not null and v_asset <> new.asset_code then
    raise exception 'La cuenta % solo admite el activo %, no %.', new.account_code, v_asset, new.asset_code;
  end if;
  return new;
end $$;
create trigger ledger_line_asset_matches before insert on public.ledger_lines
  for each row execute function public.ledger_line_asset_matches();

-- Defensa en profundidad: por asiento, débitos = créditos al cerrar la transacción.
create function public.ledger_entry_balanced() returns trigger
language plpgsql set search_path = '' as $$
declare d numeric; c numeric;
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

-- Ningún asiento puede cerrar la transacción con el hash provisional.
create function public.ledger_entry_sealed() returns trigger
language plpgsql set search_path = '' as $$
begin
  if (select hash from public.journal_entries where id = new.id) = 'pending' then
    raise exception 'Asiento % sin sellar.', new.id;
  end if;
  return null;
end $$;
create constraint trigger ledger_entry_sealed after insert on public.journal_entries
  deferrable initially deferred for each row execute function public.ledger_entry_sealed();

-- Inmutabilidad. La única modificación posible es sellar el hash provisional, dentro de post_journal_entry().
create function public.journal_entries_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'UPDATE'
     and current_setting('ledger.posting', true) = 'on'
     and old.hash = 'pending' and new.hash <> 'pending'
     and (to_jsonb(new) - 'hash') = (to_jsonb(old) - 'hash') then
    return new;
  end if;
  raise exception '% es de solo inserción (%).', tg_table_name, tg_op;
end $$;
create trigger journal_entries_guard before update or delete on public.journal_entries
  for each row execute function public.journal_entries_guard();
create trigger journal_entries_no_truncate before truncate on public.journal_entries
  for each statement execute function public.forbid_change();
create trigger ledger_lines_immutable before update or delete on public.ledger_lines
  for each row execute function public.forbid_change();
create trigger ledger_lines_no_truncate before truncate on public.ledger_lines
  for each statement execute function public.forbid_change();
create trigger raw_events_immutable before update or delete on public.raw_events
  for each row execute function public.forbid_change();
create trigger fx_rates_immutable before update or delete on public.fx_rates
  for each row execute function public.forbid_change();

-- Serialización canónica de un asiento: la misma función arma el hash al registrar y al verificar.
create function public.ledger_entry_payload(p_id uuid) returns text
language sql stable set search_path = '' as $$
  select concat_ws('|',
    e.legal_entity_id, e.seq, to_char(e.entry_date, 'YYYY-MM-DD'), e.event, coalesce(e.description, ''),
    coalesce(e.project_id::text, ''), coalesce(e.order_id::text, ''),
    coalesce(e.raw_event_id::text, ''), coalesce(e.reverses_entry_id::text, ''),
    (select coalesce(string_agg(concat_ws(',', l.line_no, l.account_code, l.asset_code, l.native_amount,
                                          l.debit_cop_minor, l.credit_cop_minor, coalesce(l.fx_rate_id::text, '')),
                                ';' order by l.line_no), '')
       from public.ledger_lines l where l.entry_id = e.id))
  from public.journal_entries e where e.id = p_id;
$$;

-- Registra un asiento completo y lo encadena. p_lines: [{account, asset, native, debit, credit, fx_rate}, ...]
-- debit y credit en centavos de COP; native en unidades mínimas del activo.
create function public.post_journal_entry(
  p_entity uuid, p_event text, p_entry_date date, p_lines jsonb,
  p_description text default null, p_project uuid default null, p_order uuid default null,
  p_raw_event uuid default null, p_reverses uuid default null
) returns uuid
language plpgsql set search_path = '' as $$
declare
  v_id uuid := gen_random_uuid();
  v_seq bigint; v_prev text; v_hash text;
  v_line jsonb; v_n int := 0; v_d numeric := 0; v_c numeric := 0;
begin
  if jsonb_typeof(p_lines) is distinct from 'array' or jsonb_array_length(p_lines) < 2 then
    raise exception 'Un asiento necesita al menos dos líneas.';
  end if;
  perform pg_advisory_xact_lock(hashtext('ledger:' || p_entity::text));
  perform set_config('ledger.posting', 'on', true);

  select seq, hash into v_seq, v_prev from public.journal_entries
   where legal_entity_id = p_entity order by seq desc limit 1;
  v_seq := coalesce(v_seq, 0) + 1;
  v_prev := coalesce(v_prev, 'GENESIS');

  insert into public.journal_entries (id, legal_entity_id, seq, entry_date, event, description,
                                      project_id, order_id, raw_event_id, reverses_entry_id, prev_hash, hash)
  values (v_id, p_entity, v_seq, p_entry_date, p_event, p_description,
          p_project, p_order, p_raw_event, p_reverses, v_prev, 'pending');

  for v_line in select * from jsonb_array_elements(p_lines) loop
    v_n := v_n + 1;
    insert into public.ledger_lines (legal_entity_id, entry_id, line_no, account_code, asset_code,
                                     native_amount, debit_cop_minor, credit_cop_minor, fx_rate_id)
    values (p_entity, v_id, v_n, v_line->>'account', v_line->>'asset', (v_line->>'native')::numeric,
            coalesce((v_line->>'debit')::bigint, 0), coalesce((v_line->>'credit')::bigint, 0),
            nullif(v_line->>'fx_rate', '')::uuid);
    v_d := v_d + coalesce((v_line->>'debit')::bigint, 0);
    v_c := v_c + coalesce((v_line->>'credit')::bigint, 0);
  end loop;

  if v_d <> v_c then
    raise exception 'Asiento descuadrado: débitos % <> créditos %.', v_d, v_c;
  end if;

  v_hash := encode(extensions.digest(v_prev || '|' || public.ledger_entry_payload(v_id), 'sha256'), 'hex');
  update public.journal_entries set hash = v_hash where id = v_id;
  perform set_config('ledger.posting', 'off', true);
  return v_id;
end $$;

-- Corrección: un asiento de reverso que invierte débitos y créditos y referencia al original.
create function public.reverse_journal_entry(p_entry uuid, p_reason text, p_date date default current_date)
returns uuid
language plpgsql set search_path = '' as $$
declare e public.journal_entries; v_lines jsonb;
begin
  select * into e from public.journal_entries where id = p_entry;
  if not found then raise exception 'Asiento % no existe.', p_entry; end if;
  select jsonb_agg(jsonb_build_object('account', account_code, 'asset', asset_code, 'native', native_amount,
                                      'debit', credit_cop_minor, 'credit', debit_cop_minor, 'fx_rate', fx_rate_id)
                   order by line_no)
    into v_lines from public.ledger_lines where entry_id = p_entry;
  return public.post_journal_entry(e.legal_entity_id, 'reverso: ' || e.event, p_date, v_lines,
                                   p_reason, e.project_id, e.order_id, e.raw_event_id, p_entry);
end $$;

-- Recorre la cadena y recalcula todos los hashes. Devuelve el seq del primer asiento roto, o null si está íntegra.
create function public.ledger_verify(p_entity uuid) returns bigint
language plpgsql stable set search_path = '' as $$
declare r record; v_prev text := 'GENESIS'; v_seq bigint := 0; v_expected text;
begin
  for r in select id, seq, prev_hash, hash from public.journal_entries
            where legal_entity_id = p_entity order by seq loop
    v_seq := v_seq + 1;
    if r.seq <> v_seq or r.prev_hash <> v_prev then return r.seq; end if;
    v_expected := encode(extensions.digest(r.prev_hash || '|' || public.ledger_entry_payload(r.id), 'sha256'), 'hex');
    if v_expected <> r.hash then return r.seq; end if;
    v_prev := r.hash;
  end loop;
  return null;
end $$;

-- ===== Anclaje: raíz de Merkle de los hashes de un rango de asientos =====
create function public.ledger_merkle_root(p_entity uuid, p_from bigint, p_to bigint) returns text
language plpgsql stable set search_path = '' as $$
declare lvl bytea[]; nxt bytea[]; i int;
begin
  select array_agg(decode(hash, 'hex') order by seq) into lvl from public.journal_entries
   where legal_entity_id = p_entity and seq between p_from and p_to;
  if lvl is null then return null; end if;
  while array_length(lvl, 1) > 1 loop
    nxt := '{}'::bytea[];
    i := 1;
    while i <= array_length(lvl, 1) loop
      if i < array_length(lvl, 1) then
        nxt := nxt || extensions.digest(lvl[i] || lvl[i + 1], 'sha256');
      else
        nxt := nxt || extensions.digest(lvl[i] || lvl[i], 'sha256');   -- si sobra uno, se duplica
      end if;
      i := i + 2;
    end loop;
    lvl := nxt;
  end loop;
  return encode(lvl[1], 'hex');
end $$;

create table public.anchors (
  id uuid primary key default gen_random_uuid(),
  legal_entity_id uuid not null references public.legal_entities(id),
  anchor_date date not null,            -- día UTC de los asientos
  from_seq bigint not null,
  to_seq bigint not null,
  entries_count bigint not null,
  merkle_root text not null,
  network text not null check (network in ('opentimestamps_bitcoin', 'ethereum')),
  tx_ref text,                          -- id de la transacción o del sello, cuando se publica
  proof text,
  status text not null default 'pending' check (status in ('pending', 'confirmed')),
  created_at timestamptz not null default now(),
  confirmed_at timestamptz,
  unique (legal_entity_id, anchor_date, network)
);

-- De un ancla solo se completan los datos de publicación; la raíz y el rango no cambian nunca.
create function public.anchors_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'UPDATE'
     and (to_jsonb(new) - 'tx_ref' - 'proof' - 'status' - 'confirmed_at')
       = (to_jsonb(old) - 'tx_ref' - 'proof' - 'status' - 'confirmed_at') then
    return new;
  end if;
  raise exception 'anchors: solo se completan tx_ref, proof, status y confirmed_at (%).', tg_op;
end $$;
create trigger anchors_guard before update or delete on public.anchors
  for each row execute function public.anchors_guard();

-- Cierra el día: calcula la raíz de los asientos de ese día (UTC) y deja el ancla pendiente de publicar.
create function public.create_anchor(p_entity uuid, p_date date, p_network text) returns uuid
language plpgsql set search_path = '' as $$
declare v_from bigint; v_to bigint; v_count bigint; v_id uuid;
begin
  select min(seq), max(seq), count(*) into v_from, v_to, v_count from public.journal_entries
   where legal_entity_id = p_entity and (created_at at time zone 'UTC')::date = p_date;
  if v_count = 0 then raise exception 'No hay asientos el % para anclar.', p_date; end if;
  insert into public.anchors (legal_entity_id, anchor_date, from_seq, to_seq, entries_count, merkle_root, network)
  values (p_entity, p_date, v_from, v_to, v_count, public.ledger_merkle_root(p_entity, v_from, v_to), p_network)
  returning id into v_id;
  return v_id;
end $$;

-- ===== Conciliación diaria: libro contra la fuente real =====
create table public.reconciliations (
  id uuid primary key default gen_random_uuid(),
  legal_entity_id uuid not null,
  rec_date date not null,
  account_code text not null,
  source text not null check (source in ('onchain', 'exchange', 'bank', 'client_obligations')),
  ledger_balance numeric(38, 0) not null,
  external_balance numeric(38, 0) not null,
  difference numeric(38, 0) generated always as (external_balance - ledger_balance) stored,
  status text generated always as (case when external_balance = ledger_balance then 'ok' else 'difference' end) stored,
  created_at timestamptz not null default now(),
  unique (legal_entity_id, rec_date, account_code, source),
  foreign key (legal_entity_id, account_code) references public.ledger_accounts (legal_entity_id, code)
);
create trigger reconciliations_immutable before update or delete on public.reconciliations
  for each row execute function public.forbid_change();

alter table public.assets enable row level security;
alter table public.ledger_accounts enable row level security;
alter table public.wallets enable row level security;
alter table public.fx_rates enable row level security;
alter table public.raw_events enable row level security;
alter table public.journal_entries enable row level security;
alter table public.ledger_lines enable row level security;
alter table public.anchors enable row level security;
alter table public.reconciliations enable row level security;

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke execute on all functions in schema public from anon, authenticated, public;

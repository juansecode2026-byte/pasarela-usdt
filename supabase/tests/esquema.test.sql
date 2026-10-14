-- Pruebas de comportamiento del esquema. Se ejecutan en una transacción que termina en ROLLBACK:
-- la bitácora es inmutable, así que nada de esto debe confirmarse jamás.
-- Uso: scripts/probar-esquema.ps1 (base local, nunca contra Supabase).

begin;

create temp table res(test text primary key, ok boolean not null, detail text);

-- Datos base: una entidad, dos proyectos, un comercio de Hellominus.
insert into public.legal_entities(id, legal_name, nit)
  values ('00000000-0000-0000-0000-0000000000a1', 'SAS Prueba', '900000000-1');
insert into public.projects(id, slug, legal_entity_id) values
  ('00000000-0000-0000-0000-0000000000b1', 'hellominus', '00000000-0000-0000-0000-0000000000a1'),
  ('00000000-0000-0000-0000-0000000000b2', 'crm', '00000000-0000-0000-0000-0000000000a1');
insert into public.merchants(id, project_id, legal_name, doc_type, doc_number)
  values ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-0000000000b1', 'Hellominus', 'NIT', '1');
-- Libro v1.7: pertenece a una entidad legal. Una segunda entidad sirve para probar el aislamiento.
insert into public.legal_entities(id, legal_name, nit)
  values ('00000000-0000-0000-0000-0000000000a2', 'SAS Otra', '900000000-2');
insert into public.ledger_accounts(legal_entity_id, code, name, type, asset_code) values
  ('00000000-0000-0000-0000-0000000000a1', '1105', 'Criptoactivos USDT (wallet TRC-20)', 'asset', 'USDT'),
  ('00000000-0000-0000-0000-0000000000a1', '1110', 'Criptoactivos ETH', 'asset', 'ETH'),
  ('00000000-0000-0000-0000-0000000000a1', '1120', 'Bancos COP', 'asset', 'COP'),
  ('00000000-0000-0000-0000-0000000000a1', '2205', 'Obligaciones con clientes', 'liability', null),
  ('00000000-0000-0000-0000-0000000000a1', '4105', 'Ingreso por spread', 'income', 'COP'),
  ('00000000-0000-0000-0000-0000000000a1', '5105', 'Costo de conversión', 'expense', 'COP');

-- Ejecuta un bloque que DEBE fallar. Registra ok = true si falló (con el mensaje) y false si pasó.
create function pg_temp.debe_fallar(nombre text, sentencia text, fragmento text default null) returns void
language plpgsql as $$
begin
  begin
    execute sentencia;
    insert into res values (nombre, false, 'la sentencia se ejecutó y no debía');
  exception when others then
    if fragmento is null or sqlerrm ilike '%' || fragmento || '%' then
      insert into res values (nombre, true, sqlerrm);
    else
      insert into res values (nombre, false, 'falló por otra razón: ' || sqlerrm);
    end if;
  end;
end $$;

-- ===== Bitácora =====
insert into public.audit_log(actor, action, entity) values ('t', 'a', 'x'), ('t', 'b', 'x'), ('t', 'c', 'x');
insert into res select 'bitacora: cadena íntegra', public.audit_log_verify() is null, coalesce(public.audit_log_verify()::text, '');
insert into res select 'bitacora: cada fila enlaza con la anterior',
  (select count(*) = 2 from public.audit_log a join public.audit_log b on b.id = a.id + 1 and b.prev_hash = a.hash), '';
select pg_temp.debe_fallar('bitacora: no se edita', $q$update public.audit_log set actor = 'x'$q$, 'solo inserción');
select pg_temp.debe_fallar('bitacora: no se borra', $q$delete from public.audit_log$q$, 'solo inserción');
select pg_temp.debe_fallar('bitacora: no se vacía', $q$truncate public.audit_log$q$, 'solo inserción');
-- Una alteración hecha saltándose el bloqueo (superusuario) debe ser detectada por la verificación.
alter table public.audit_log disable trigger audit_log_immutable;
update public.audit_log set actor = 'alterado' where id = (select min(id) + 1 from public.audit_log);
insert into res select 'bitacora: detecta alteración', public.audit_log_verify() = (select min(id) + 1 from public.audit_log), 'primera fila rota';
alter table public.audit_log enable trigger audit_log_immutable;

-- ===== Comercios y órdenes =====
select pg_temp.debe_fallar('orden: rechaza comercio no aprobado',
  $q$insert into public.orders(project_id, merchant_id, external_ref, amount_cop_minor, network, deposit_address, usdt_expected_units, expires_at)
     values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000c1', 'HM-1', 1000, 'tron', 'T1', 1, now())$q$,
  'no está aprobado');
update public.merchants set kyc_status = 'approved';
insert into public.orders(id, project_id, merchant_id, external_ref, amount_cop_minor, network, deposit_address, usdt_expected_units, expires_at)
  values ('00000000-0000-0000-0000-0000000000e1', '00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000c1', 'HM-1', 1000, 'tron', 'T1', 1, now());
insert into res values ('orden: acepta comercio aprobado', true, '');
select pg_temp.debe_fallar('orden: no mezcla proyectos (comercio de otro proyecto)',
  $q$insert into public.orders(project_id, merchant_id, external_ref, amount_cop_minor, network, deposit_address, usdt_expected_units, expires_at)
     values ('00000000-0000-0000-0000-0000000000b2', '00000000-0000-0000-0000-0000000000c1', 'HM-2', 1000, 'tron', 'T2', 1, now())$q$);
select pg_temp.debe_fallar('orden: external_ref único por proyecto',
  $q$insert into public.orders(project_id, merchant_id, external_ref, amount_cop_minor, network, deposit_address, usdt_expected_units, expires_at)
     values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000c1', 'HM-1', 1000, 'tron', 'T3', 1, now())$q$,
  'duplicate');
select pg_temp.debe_fallar('orden: monto debe ser positivo',
  $q$insert into public.orders(project_id, merchant_id, external_ref, amount_cop_minor, network, deposit_address, usdt_expected_units, expires_at)
     values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000c1', 'HM-9', 0, 'tron', 'T9', 1, now())$q$,
  'check');
select pg_temp.debe_fallar('orden: estado inválido',
  $q$update public.orders set state = 'INVENTADO'$q$, 'check');
select pg_temp.debe_fallar('orden: no se borra', $q$delete from public.orders$q$, 'solo inserción');
insert into public.order_state_history(project_id, order_id, from_state, to_state, event, actor)
  values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000e1', 'CREATED', 'AWAITING_PAYMENT', 'activate', 'test');
select pg_temp.debe_fallar('historial: no se edita', $q$update public.order_state_history set actor = 'x'$q$, 'solo inserción');
select pg_temp.debe_fallar('historial: no se borra', $q$delete from public.order_state_history$q$, 'solo inserción');

-- ===== Cadena =====
insert into public.onchain_txs(project_id, order_id, network, tx_hash, from_address, to_address, amount_units)
  values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000e1', 'tron', 'h1', 'a', 'T1', 1);
select pg_temp.debe_fallar('cadena: la misma transacción no se procesa dos veces',
  $q$insert into public.onchain_txs(project_id, order_id, network, tx_hash, from_address, to_address, amount_units)
     values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000e1', 'tron', 'h1', 'a', 'T1', 1)$q$,
  'duplicate');
select pg_temp.debe_fallar('cadena: monto positivo',
  $q$insert into public.onchain_txs(project_id, network, tx_hash, from_address, to_address, amount_units)
     values ('00000000-0000-0000-0000-0000000000b1', 'tron', 'h2', 'a', 'T1', 0)$q$, 'check');

-- ===== Libro contable v1.7 =====
create temp table ids(name text primary key, id uuid);

insert into res select 'activos: 5 activos sembrados, ETH con 18 decimales',
  (select count(*) = 5 from public.assets) and (select decimals = 18 from public.assets where code = 'ETH'), '';

-- Los asientos no se insertan directo: solo con post_journal_entry().
select pg_temp.debe_fallar('libro: no se inserta un asiento directo',
  $q$insert into public.journal_entries(legal_entity_id, seq, entry_date, event, prev_hash, hash)
     values ('00000000-0000-0000-0000-0000000000a1', 1, current_date, 'x', 'GENESIS', 'abc')$q$,
  'post_journal_entry');

-- Asiento 1: un cliente paga 1.000 USDT (6 decimales) = 4.000.000 COP (400.000.000 centavos).
insert into ids select 'e1', public.post_journal_entry('00000000-0000-0000-0000-0000000000a1', 'cobro USDT', date '2026-10-14',
  '[{"account":"1105","asset":"USDT","native":"1000000000","debit":400000000,"credit":0},
    {"account":"2205","asset":"COP","native":"400000000","debit":0,"credit":400000000}]'::jsonb,
  'Cliente paga 1.000 USDT', '00000000-0000-0000-0000-0000000000b1');
insert into res select 'libro: acepta asiento cuadrado y arranca en GENESIS',
  (select seq = 1 and prev_hash = 'GENESIS' and length(hash) = 64
     from public.journal_entries where id = (select id from ids where name = 'e1')), '';

-- Asiento 2 con 1 ETH = 10^18 wei (no cabe en bigint).
insert into ids select 'e2', public.post_journal_entry('00000000-0000-0000-0000-0000000000a1', 'cobro ETH', date '2026-10-14',
  '[{"account":"1110","asset":"ETH","native":"1000000000000000000","debit":1200000000,"credit":0},
    {"account":"2205","asset":"COP","native":"1200000000","debit":0,"credit":1200000000}]'::jsonb);
insert into res select 'libro: guarda 1 ETH en wei (10^18)',
  (select native_amount = 1000000000000000000 from public.ledger_lines
    where entry_id = (select id from ids where name = 'e2') and line_no = 1), '';
insert into res select 'libro: cada asiento enlaza con el hash del anterior',
  (select e2.prev_hash = e1.hash and e2.seq = 2
     from public.journal_entries e1, public.journal_entries e2
    where e1.id = (select id from ids where name = 'e1') and e2.id = (select id from ids where name = 'e2')), '';
insert into res select 'libro: la cadena verifica íntegra',
  public.ledger_verify('00000000-0000-0000-0000-0000000000a1') is null, '';

-- Rechazos
select pg_temp.debe_fallar('libro: rechaza asiento descuadrado',
  $q$select public.post_journal_entry('00000000-0000-0000-0000-0000000000a1', 'malo', current_date,
     '[{"account":"1105","asset":"USDT","native":"1","debit":500,"credit":0},{"account":"2205","asset":"COP","native":"1","debit":0,"credit":400}]'::jsonb)$q$,
  'descuadrado');
select pg_temp.debe_fallar('libro: rechaza un asiento de una sola línea',
  $q$select public.post_journal_entry('00000000-0000-0000-0000-0000000000a1', 'malo', current_date,
     '[{"account":"1105","asset":"USDT","native":"1","debit":500,"credit":0}]'::jsonb)$q$,
  'al menos dos');
select pg_temp.debe_fallar('libro: la cuenta USDT no acepta ETH',
  $q$select public.post_journal_entry('00000000-0000-0000-0000-0000000000a1', 'malo', current_date,
     '[{"account":"1105","asset":"ETH","native":"1","debit":500,"credit":0},{"account":"2205","asset":"COP","native":"1","debit":0,"credit":500}]'::jsonb)$q$,
  'solo admite');
select pg_temp.debe_fallar('libro: no usa cuentas de otra entidad',
  $q$select public.post_journal_entry('00000000-0000-0000-0000-0000000000a2', 'malo', current_date,
     '[{"account":"1105","asset":"USDT","native":"1","debit":500,"credit":0},{"account":"2205","asset":"COP","native":"1","debit":0,"credit":500}]'::jsonb)$q$,
  'foreign key');
select pg_temp.debe_fallar('libro: línea con débito y crédito a la vez',
  $q$select public.post_journal_entry('00000000-0000-0000-0000-0000000000a1', 'malo', current_date,
     '[{"account":"1105","asset":"USDT","native":"1","debit":5,"credit":5},{"account":"2205","asset":"COP","native":"1","debit":0,"credit":0}]'::jsonb)$q$,
  'check');
select pg_temp.debe_fallar('libro: las líneas no se editan', $q$update public.ledger_lines set debit_cop_minor = 1$q$, 'solo inserción');
select pg_temp.debe_fallar('libro: las líneas no se borran', $q$delete from public.ledger_lines$q$, 'solo inserción');
select pg_temp.debe_fallar('libro: los asientos no se editan', $q$update public.journal_entries set event = 'x'$q$, 'solo inserción');
select pg_temp.debe_fallar('libro: los asientos no se borran', $q$delete from public.journal_entries$q$, 'solo inserción');
select pg_temp.debe_fallar('libro: los asientos no se vacían', $q$truncate public.journal_entries$q$, 'solo inserción');
insert into res select 'libro: un rechazo no consume número de secuencia',
  (select max(seq) = 2 from public.journal_entries where legal_entity_id = '00000000-0000-0000-0000-0000000000a1'), '';

-- Alteración saltándose los bloqueos (superusuario): la verificación debe señalar el asiento tocado.
alter table public.ledger_lines disable trigger ledger_lines_immutable;
update public.ledger_lines set debit_cop_minor = debit_cop_minor + 1
 where entry_id = (select id from ids where name = 'e1') and line_no = 1;
insert into res select 'libro: detecta un asiento alterado',
  public.ledger_verify('00000000-0000-0000-0000-0000000000a1') = 1, 'seq 1';
update public.ledger_lines set debit_cop_minor = debit_cop_minor - 1
 where entry_id = (select id from ids where name = 'e1') and line_no = 1;
alter table public.ledger_lines enable trigger ledger_lines_immutable;
insert into res select 'libro: vuelve a verificar íntegra al restaurar',
  public.ledger_verify('00000000-0000-0000-0000-0000000000a1') is null, '';

-- Reverso: invierte el asiento, lo referencia, y solo se puede hacer una vez.
insert into ids select 'r1', public.reverse_journal_entry((select id from ids where name = 'e1'), 'error de captura', date '2026-10-14');
insert into res select 'libro: el reverso deja la cuenta en cero',
  (select sum(debit_cop_minor) = sum(credit_cop_minor) and count(*) = 2
     from public.ledger_lines
    where account_code = '1105' and entry_id in (select id from ids where name in ('e1', 'r1'))), '';
insert into res select 'libro: el reverso referencia al original',
  (select reverses_entry_id = (select id from ids where name = 'e1')
     from public.journal_entries where id = (select id from ids where name = 'r1')), '';
select pg_temp.debe_fallar('libro: un asiento solo se reversa una vez',
  $q$select public.reverse_journal_entry((select id from pg_temp.ids where name = 'e1'), 'otra vez')$q$, 'duplicate');
insert into res select 'libro: la cadena sigue íntegra tras el reverso',
  public.ledger_verify('00000000-0000-0000-0000-0000000000a1') is null, '';

-- Tasas de cambio y eventos crudos
insert into public.fx_rates(id, asset_code, rate_cop, source, observed_at)
  values ('00000000-0000-0000-0000-0000000000f1', 'USDT', 4000.12345678, 'binance', '2026-10-14 12:00:00+00');
select pg_temp.debe_fallar('tasas: no se editan', $q$update public.fx_rates set rate_cop = 1$q$, 'solo inserción');
select pg_temp.debe_fallar('tasas: tasa positiva',
  $q$insert into public.fx_rates(asset_code, rate_cop, source, observed_at) values ('BTC', 0, 'x', now())$q$, 'check');
insert into public.raw_events(legal_entity_id, source, network, source_ref, payload)
  values ('00000000-0000-0000-0000-0000000000a1', 'onchain', 'tron', 'hash-1', '{"amount":"1000"}');
insert into res select 'eventos crudos: calcula el hash del contenido',
  (select payload_hash = encode(sha256(payload::text::bytea), 'hex') and length(payload_hash) = 64
     from public.raw_events where source_ref = 'hash-1'), '';
select pg_temp.debe_fallar('eventos crudos: no se duplican',
  $q$insert into public.raw_events(legal_entity_id, source, network, source_ref, payload)
     values ('00000000-0000-0000-0000-0000000000a1', 'onchain', 'tron', 'hash-1', '{}')$q$, 'duplicate');
select pg_temp.debe_fallar('eventos crudos: no se editan', $q$update public.raw_events set source_ref = 'x'$q$, 'solo inserción');

-- Asiento 3: se vende 100 USDT (100.000.000 unidades) = 400.000 COP; el banco recibe 398.000 y 2.000 es costo de conversión.
insert into ids select 'e3', public.post_journal_entry('00000000-0000-0000-0000-0000000000a1', 'conversión', date '2026-10-14',
  jsonb_build_array(
    jsonb_build_object('account', '1120', 'asset', 'COP', 'native', '39800000', 'debit', 39800000, 'credit', 0,
                       'fx_rate', '00000000-0000-0000-0000-0000000000f1'),
    jsonb_build_object('account', '5105', 'asset', 'COP', 'native', '200000', 'debit', 200000, 'credit', 0),
    jsonb_build_object('account', '1105', 'asset', 'USDT', 'native', '100000000', 'debit', 0, 'credit', 40000000)),
  null, '00000000-0000-0000-0000-0000000000b1', null,
  (select id from public.raw_events where source_ref = 'hash-1'));
insert into res select 'libro: un asiento enlaza su evento crudo y su tasa',
  (select e.raw_event_id is not null
          and exists (select 1 from public.ledger_lines l where l.entry_id = e.id and l.fx_rate_id is not null)
     from public.journal_entries e where e.id = (select id from ids where name = 'e3')), '';

-- Anclaje: raíz de Merkle del día
insert into res select 'anclaje: la raíz de 1 asiento es su propio hash',
  public.ledger_merkle_root('00000000-0000-0000-0000-0000000000a1', 1, 1) =
  (select hash from public.journal_entries
    where legal_entity_id = '00000000-0000-0000-0000-0000000000a1' and seq = 1), '';
insert into res select 'anclaje: la raíz de 2 asientos es sha256(h1 || h2)',
  public.ledger_merkle_root('00000000-0000-0000-0000-0000000000a1', 1, 2) =
  (select encode(sha256(decode(a.hash, 'hex') || decode(b.hash, 'hex')), 'hex')
     from public.journal_entries a, public.journal_entries b
    where a.legal_entity_id = '00000000-0000-0000-0000-0000000000a1' and a.seq = 1
      and b.legal_entity_id = '00000000-0000-0000-0000-0000000000a1' and b.seq = 2), '';
insert into res select 'anclaje: la raíz de 3 asientos duplica el último',
  public.ledger_merkle_root('00000000-0000-0000-0000-0000000000a1', 1, 3) =
  (select encode(sha256(
            sha256(decode(a.hash, 'hex') || decode(b.hash, 'hex')) ||
            sha256(decode(c.hash, 'hex') || decode(c.hash, 'hex'))), 'hex')
     from public.journal_entries a, public.journal_entries b, public.journal_entries c
    where a.legal_entity_id = '00000000-0000-0000-0000-0000000000a1' and a.seq = 1
      and b.legal_entity_id = '00000000-0000-0000-0000-0000000000a1' and b.seq = 2
      and c.legal_entity_id = '00000000-0000-0000-0000-0000000000a1' and c.seq = 3), '';
insert into ids select 'a1', public.create_anchor('00000000-0000-0000-0000-0000000000a1', (now() at time zone 'UTC')::date, 'opentimestamps_bitcoin');
insert into res select 'anclaje: el ancla del día cubre todos los asientos y su raíz coincide',
  (select entries_count = 4 and from_seq = 1 and to_seq = 4
          and merkle_root = public.ledger_merkle_root('00000000-0000-0000-0000-0000000000a1', 1, 4)
     from public.anchors where id = (select id from ids where name = 'a1')), '';
select pg_temp.debe_fallar('anclaje: un ancla por día y red',
  $q$select public.create_anchor('00000000-0000-0000-0000-0000000000a1', (now() at time zone 'UTC')::date, 'opentimestamps_bitcoin')$q$, 'duplicate');
select pg_temp.debe_fallar('anclaje: la raíz no se modifica', $q$update public.anchors set merkle_root = 'x'$q$, 'solo se completan');
select pg_temp.debe_fallar('anclaje: no se borra', $q$delete from public.anchors$q$, 'solo se completan');
update public.anchors set tx_ref = 'ots-1', status = 'confirmed', confirmed_at = now();
insert into res select 'anclaje: se completa la publicación (tx_ref y estado)',
  (select status = 'confirmed' and tx_ref = 'ots-1' from public.anchors limit 1), '';
select pg_temp.debe_fallar('anclaje: sin asientos no hay ancla',
  $q$select public.create_anchor('00000000-0000-0000-0000-0000000000a1', date '2020-01-01', 'ethereum')$q$, 'No hay asientos');

-- Conciliación diaria
insert into public.reconciliations(legal_entity_id, rec_date, account_code, source, ledger_balance, external_balance)
  values ('00000000-0000-0000-0000-0000000000a1', date '2026-10-14', '1105', 'onchain', 1000000000, 990000000),
         ('00000000-0000-0000-0000-0000000000a1', date '2026-10-14', '1120', 'bank', 398000000, 398000000);
insert into res select 'conciliación: marca la diferencia y el cuadre',
  (select bool_and(case account_code
                     when '1105' then status = 'difference' and difference = -10000000
                     else status = 'ok' and difference = 0 end)
     from public.reconciliations), '';
select pg_temp.debe_fallar('conciliación: no se edita', $q$update public.reconciliations set external_balance = 0$q$, 'solo inserción');

-- ===== Seguridad (RLS y permisos) =====
insert into res select 'rls: todas las tablas tienen RLS activo',
  not exists (select 1 from pg_tables where schemaname = 'public' and not rowsecurity),
  coalesce((select string_agg(tablename, ', ') from pg_tables where schemaname = 'public' and not rowsecurity), '');
insert into res select 'rls: ninguna política para anon o authenticated',
  not exists (select 1 from pg_policies where schemaname = 'public'), '';
insert into res select 'permisos: anon y authenticated sin acceso a tablas',
  not exists (select 1 from information_schema.role_table_grants
              where table_schema = 'public' and grantee in ('anon', 'authenticated')), '';
insert into res select 'permisos: anon sin ejecución de funciones',
  not exists (select 1 from information_schema.routine_privileges
              where routine_schema = 'public' and grantee in ('anon', 'authenticated', 'PUBLIC')), '';

-- ===== Resultado =====
select case when ok then 'OK   ' else 'FALLA' end as estado, test, case when ok then '' else detail end as detalle
from res order by ok, test;

do $$
declare n int;
begin
  select count(*) into n from res where not ok;
  if n > 0 then raise exception '% prueba(s) fallaron', n; end if;
end $$;

rollback;

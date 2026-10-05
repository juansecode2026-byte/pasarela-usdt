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
insert into public.ledger_accounts values
  ('00000000-0000-0000-0000-0000000000b1', '1105', 'USDT en custodia', 'asset'),
  ('00000000-0000-0000-0000-0000000000b1', '2205', 'Por pagar a comercios', 'liability');

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

-- ===== Libro contable =====
-- Asiento cuadrado: se acepta al cerrar la transacción.
insert into public.ledger_entries(id, project_id, event) values ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000b1', 'pago');
insert into public.ledger_lines(project_id, entry_id, account_code, debit_cop_minor) values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000d1', '1105', 1000);
insert into public.ledger_lines(project_id, entry_id, account_code, credit_cop_minor) values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000d1', '2205', 1000);
set constraints all immediate;
insert into res values ('libro: acepta asiento cuadrado', true, '');
set constraints all deferred;

-- Asiento descuadrado: se rechaza al cerrar.
insert into public.ledger_entries(id, project_id, event) values ('00000000-0000-0000-0000-0000000000d2', '00000000-0000-0000-0000-0000000000b1', 'descuadrado');
insert into public.ledger_lines(project_id, entry_id, account_code, debit_cop_minor) values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000d2', '1105', 500);
select pg_temp.debe_fallar('libro: rechaza asiento descuadrado', $q$set constraints all immediate$q$, 'descuadrado');
-- El asiento descuadrado queda pendiente hasta el ROLLBACK final; las pruebas que siguen no dependen de él.

-- Líneas inválidas (se rechazan al instante, por restricción CHECK).
select pg_temp.debe_fallar('libro: línea con débito y crédito a la vez',
  $q$insert into public.ledger_lines(project_id, entry_id, account_code, debit_cop_minor, credit_cop_minor)
     values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000d1', '1105', 5, 5)$q$, 'check');
select pg_temp.debe_fallar('libro: línea en cero',
  $q$insert into public.ledger_lines(project_id, entry_id, account_code)
     values ('00000000-0000-0000-0000-0000000000b1', '00000000-0000-0000-0000-0000000000d1', '1105')$q$, 'check');
select pg_temp.debe_fallar('libro: cuenta de otro proyecto',
  $q$insert into public.ledger_lines(project_id, entry_id, account_code, debit_cop_minor)
     values ('00000000-0000-0000-0000-0000000000b2', '00000000-0000-0000-0000-0000000000d1', '1105', 5)$q$, 'foreign key');
select pg_temp.debe_fallar('libro: las líneas no se editan', $q$update public.ledger_lines set debit_cop_minor = 1 where debit_cop_minor > 0$q$, 'solo inserción');
select pg_temp.debe_fallar('libro: las líneas no se borran', $q$delete from public.ledger_lines$q$, 'solo inserción');
select pg_temp.debe_fallar('libro: los asientos no se editan', $q$update public.ledger_entries set event = 'x'$q$, 'solo inserción');

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

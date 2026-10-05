# Recrea una base PostgreSQL LOCAL, aplica las migraciones y corre supabase/tests.
# Sin llamadas a Claude. Nunca apunta a Supabase.
#
# Requiere PostgreSQL 17 local. Variables (con valores por defecto):
#   PGHOST=localhost  PGPORT=5433  PGUSER=postgres  PGPASSWORD=<contraseña local>
# Uso: $env:PGPASSWORD = '...'; ./scripts/probar-esquema.ps1

$ErrorActionPreference = 'Stop'
$raiz = Split-Path $PSScriptRoot -Parent
$psql = (Get-ChildItem 'C:\Program Files\PostgreSQL\*\bin\psql.exe' | Sort-Object FullName -Descending | Select-Object -First 1).FullName
if (-not $psql) { throw 'No se encontró psql. Instala PostgreSQL 17.' }
if (-not $env:PGPASSWORD) { throw 'Define PGPASSWORD (contraseña de la base local).' }

$h = if ($env:PGHOST) { $env:PGHOST } else { 'localhost' }
$p = if ($env:PGPORT) { $env:PGPORT } else { '5433' }
$u = if ($env:PGUSER) { $env:PGUSER } else { 'postgres' }
$db = 'pasarela_test'
$base = @('-h', $h, '-p', $p, '-U', $u, '-v', 'ON_ERROR_STOP=1', '-q')

# Guarda de seguridad: solo hosts locales.
if ($h -notin @('localhost', '127.0.0.1', '::1')) { throw "Host '$h' no es local. Este script solo corre en local." }

& $psql @base -d postgres -c "drop database if exists $db with (force)"
& $psql @base -d postgres -c "create database $db"

# Piezas propias de Supabase que las migraciones suponen.
& $psql @base -d $db -c "do `$`$ begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role nologin bypassrls; end if;
end `$`$; create schema if not exists extensions;"

Get-ChildItem (Join-Path $raiz 'supabase\migrations\*.sql') | Sort-Object Name | ForEach-Object {
  Write-Host "Migración: $($_.Name)"
  & $psql @base -d $db -f $_.FullName
}

Write-Host "`nPruebas:"
& $psql @base -d $db -f (Join-Path $raiz 'supabase\tests\esquema.test.sql')
if ($LASTEXITCODE -ne 0) { Write-Host 'FALLARON PRUEBAS' -ForegroundColor Red; exit 1 }
Write-Host 'Todas las pruebas pasaron.' -ForegroundColor Green

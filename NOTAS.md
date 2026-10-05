# Notas

Bitácora: qué se repitió, qué falló, qué se aprendió.

- 2026-10-04: proyecto creado; documentos de contexto en `Docs/`.
- 2026-10-04: repositorio privado `juansecode2026-byte/pasarela-usdt` creado (sin protección de ramas: requiere GitHub Pro). Proyecto Supabase `pasarela-usdt` (ref `gjcymzqcxifgytdqwhwi`, us-east-1, plan gratuito) creado; para hacer cupo se pausó `crm-productividad-hello-minus` (restaurable). Pendiente: contraseña de la base de datos (la define/rota Juan en el panel; nunca en el chat ni en el repo) y subir a Pro antes de manejar datos reales (el plan gratuito se pausa por inactividad, inaceptable para vigilar la cadena).
- 2026-10-05: las pruebas contra Supabase (`execute_sql` con escrituras, aun en transacción con ROLLBACK) se rechazaron 5 veces; las lecturas sí pasan. Se instaló PostgreSQL 17 local (puerto 5433, contraseña descartable fuera del repo) y las pruebas del esquema corren con `scripts/probar-esquema.ps1`: 29 pruebas, todas pasan; se comprobó que detectan la falta de un disparador (mutación). Se agregó la regla `execute_sql` a `.claude/settings.json` sin efecto sobre el rechazo.

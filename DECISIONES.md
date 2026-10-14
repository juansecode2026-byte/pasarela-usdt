# Decisiones

Estado al 14 de octubre de 2026. El plan vigente está en `Docs/plan-paso-a-paso-proveedor-de-liquidez.md`.

## Aceptadas

| Decisión | Motivo |
|---|---|
| Proyecto aparte, repositorio privado, base de datos propia | Datos sensibles (identidad, bancos, UIAF/DIAN), acceso restringido, procesos permanentes, sirve a Hellominus y Zuhay |
| ~~Hellominus es el primer proyecto y primera entidad legal~~ **Reemplazada el 14 oct 2026**: Hellominus y Zuhay son los primeros clientes | Ya no es el dueño del sistema |
| Los clientes (Hellominus, Zuhay) consumen por API y webhooks; el pagador paga dentro de la aplicación del cliente | Aislamiento de claves y de datos |
| No construir el módulo de pagos antes de cerrar modelo legal y reparto | Define obligaciones y arquitectura |
| ~~El dinero llega a la cuenta de Hellominus (4 oct 2026, Juan). Hellominus es el `merchant`; el reparto a anfitriones y Zuhay queda fuera de la pasarela~~ **Reemplazada el 14 oct 2026** | Un solo receptor simplificaba la vinculación. Ya no aplica: Hellominus es un cliente |
| Se crean SAS nuevas; el proyecto atiende a Hellominus y a la empresa del CRM de ventas. ~~Hellominus construye la pasarela~~ (4 oct 2026, Juan; matizado el 14 oct) | Cada empresa es una entidad legal con su proyecto; el esquema es multi-entidad desde el inicio |
| **Cambio de enfoque (14 oct 2026, Juan):** el proyecto es un proveedor de liquidez independiente que presta servicio a otras compañías; DEVMINUS es la empresa principal, Hellominus está dentro y su socio es Zuhay; los pagos en pesos en Colombia van por la pasarela en pesos y los pagos USDT del mundo por este proyecto; Hellominus y Zuhay son los primeros clientes; nombre provisional "Proveedor de liquidez USDT" | Legalidad y orden. **Reemplaza** las dos decisiones anteriores sobre que el dinero llega a Hellominus y que Hellominus es el comercio |
| **Los pagos en USDT entran directo al proveedor de liquidez, y él hace la dispersión en pesos desde una cuenta de Bancolombia (14 oct 2026, Juan).** Hellominus y DEVMINUS reciben pagos en cripto, pero quien dispersa es el proveedor | Elegida la opción B. Es el camino de mayor carga regulatoria: el proveedor recibe fondos de terceros y paga a terceros. **Falta validación de abogado y contador (#1)** |
| **La dispersión en pesos va a la empresa cliente (14 oct 2026, Juan):** los pesos se envían a la cuenta de Hellominus o de DEVMINUS, y ellos reparten a sus anfitriones por su cuenta | Un solo beneficiario verificado por cliente (KYB). El proveedor no paga a anfitriones ni a otros terceros. Mantiene el diseño `merchant` = empresa cliente |

## Abiertas: Fase 0 (bloquean el módulo de pagos)

| # | Decisión | Opciones / nota | Quién |
|---|---|---|---|
| 1 | Modelo legal | A proveedor directo, B orquestador, C cobro propio. Recomendado MVP: C o B | Abogado y contador |
| 2 | Qué empresa será el proveedor de liquidez (entidad legal, cuentas de Binance y banco) y su nombre definitivo | Antes se asumía Hellominus; ahora es una empresa propia. Nombre provisional: Proveedor de liquidez USDT | Juan, DEVMINUS |
| 3 | Política de reembolso y qué recibe cada cliente y cuándo | Cada cliente reparte lo suyo a sus anfitriones fuera de este sistema; falta la política de reembolso (brecha 1) | Juan, socio |
| 4 | Cuándo se confirma la reserva | Pago válido en cadena o pesos recibidos; quién asume riesgo de precio y capital de trabajo | Juan, Zuhay |
| 5 | Proveedor de liquidez, análisis de billeteras, red (TRON o Polygon), banco; iniciar KYB | Binance es solo un adaptador | Juan |
| 6 | Respuestas de Zuhay y acuerdo SaaS | Falta agregar bloque de pagos externos y cripto al cuestionario | Zuhay |
| 8 | Rol del proveedor: principal (compra y vende con su balance) o agente (ejecuta por cuenta del cliente) | Cambia IVA, capital de trabajo y contratos. Se define con el contador (fase 0 del proveedor de liquidez) | Juan, contador |

## Aplazadas

| Candidato | Condición de activación |
|---|---|
| Reportes UIAF y DIAN, contador del proyecto | Cerrar el modelo legal (#1) |
| Módulo de pagos completo (Fases 4 a 7) | Cerrar #1 a #5 |
| Estándar reutilizable y segundo proyecto (Zuhay) | MVP de Hellominus funcionando |

## Rechazadas

| Candidato | Motivo |
|---|---|
| Construir dentro del repositorio de Hellominus | Es público; ver sección 7 del resumen |
| P2P de Binance como motor | No escala, pagos de terceros, riesgo de bloqueo bancario |

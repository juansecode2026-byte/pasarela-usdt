# Decisiones

Estado al 4 de octubre de 2026. Fuente: `Docs/resumen-proyecto-hellominus.md`, secciones 6 y 7.

## Aceptadas

| Decisión | Motivo |
|---|---|
| Proyecto aparte, repositorio privado, base de datos propia | Datos sensibles (identidad, bancos, UIAF/DIAN), acceso restringido, procesos permanentes, sirve a Hellominus y Zuhay |
| Hellominus es el primer proyecto y primera entidad legal | Acordado con Juan |
| Hellominus consume por API y webhooks; el viajero paga dentro de Hellominus | Aislamiento de claves y de datos |
| No construir el módulo de pagos antes de cerrar modelo legal y reparto | Define obligaciones y arquitectura |
| El dinero llega a la cuenta de Hellominus (4 oct 2026, Juan). Hellominus es el `merchant`; el reparto a anfitriones y Zuhay queda fuera de la pasarela | Un solo receptor simplifica la vinculación y el reparto. Falta validar con abogado y contador que baste ante UIAF y DIAN (#1) |
| Se crean SAS nuevas; el proyecto atiende a Hellominus y a la empresa del CRM de ventas, y Hellominus construye la pasarela (4 oct 2026, Juan) | Cada empresa es una entidad legal con su proyecto; el esquema es multi-entidad desde el inicio |

## Abiertas: Fase 0 (bloquean el módulo de pagos)

| # | Decisión | Opciones / nota | Quién |
|---|---|---|---|
| 1 | Modelo legal | A proveedor directo, B orquestador, C cobro propio. Recomendado MVP: C o B | Abogado y contador |
| 2 | Vendedor frente al viajero; entidad dueña de la cuenta de exchange | Cuenta bancaria: Hellominus (decidido). Falta confirmar la entidad legal exacta y quién figura como vendedor | Juan, Gabriel, Zuhay |
| 3 | Política de reembolso y reparto interno entre Hellominus, Zuhay y anfitriones | El reparto sale de la pasarela; sigue la política de reembolso (brecha 1) y el momento de pago al anfitrión, que decide Hellominus | Juan, socio |
| 4 | Cuándo se confirma la reserva | Pago válido en cadena o pesos recibidos; quién asume riesgo de precio y capital de trabajo | Juan, Zuhay |
| 5 | Proveedor de liquidez, análisis de billeteras, red (TRON o Polygon), banco; iniciar KYB | Binance es solo un adaptador | Juan |
| 6 | Respuestas de Zuhay y acuerdo SaaS | Falta agregar bloque de pagos externos y cripto al cuestionario | Zuhay |

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

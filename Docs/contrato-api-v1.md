# Contrato de la API v1 (borrador)

Estado: borrador del 4 de octubre de 2026. Es lo único que comparten la pasarela, Hellominus y Zuhay. Deriva de `pasarela-usdt-colombia-estandar.html` (secciones API y webhooks, flujo y reglas). Lo marcado **ABIERTO** depende de una decisión de la Fase 0 (`DECISIONES.md`) y no se implementa hasta cerrarla.

## 1. Convenciones

- **Base**: `https://<host>/v1`. Solo HTTPS. Cambios incompatibles van en `/v2`; agregar campos opcionales no rompe `v1`.
- **Autenticación**: `Authorization: Bearer <api_key_del_proyecto>`. Una llave por proyecto, con permisos limitados, rotable. La llave identifica el `project_id`; ningún cuerpo ni ruta lo lleva.
- **Idempotencia**: todo `POST` exige `Idempotency-Key` (UUID). Misma llave y mismo cuerpo devuelve la respuesta original; misma llave con cuerpo distinto devuelve `409 idempotency_conflict`. Se conserva 24 horas.
- **Dinero**: nunca decimales flotantes.
  - Pesos: entero en pesos (`amount_cop`) en la API; internamente centavos. **ABIERTO**: confirmar si se aceptan centavos en la entrada.
  - USDT: cadena de texto con 6 decimales (`"250.000000"`).
  - Tasa: cadena (`"4000.00"`).
- **Fechas**: ISO 8601 en UTC.
- **Identificadores**: prefijados y opacos (`mrc_`, `ord_`, `stl_`, `rfd_`, `evt_`).
- **Errores**: `{ "error": { "code": "...", "message": "...", "request_id": "..." } }`. Códigos: `400 invalid_request`, `401 unauthorized`, `403 forbidden`, `404 not_found`, `409 idempotency_conflict | invalid_state`, `422 merchant_not_approved | limit_exceeded | network_not_enabled`, `429 rate_limited`, `5xx internal`.
- **Paginación**: `?limit=` (máx. 100) y `?cursor=`; respuesta con `next_cursor`.
- **Límite de velocidad**: por llave; encabezado `Retry-After` en `429`.
- **Motivos de cumplimiento**: la API nunca revela por qué una orden queda en revisión ni expone resultados de análisis de billeteras.

## 2. Comercios

Quien recibe el dinero. **Decidido (4 de octubre de 2026)**: para Hellominus, el `merchant` es Hellominus mismo y el dinero llega a su cuenta; el reparto a anfitriones y a Zuhay no pasa por la pasarela. En la práctica Hellominus tiene un solo comercio. El modelo sigue admitiendo varios comercios por proyecto para otros casos futuros. **ABIERTO (#1)**: validación legal con abogado y contador.

### `POST /v1/merchants`
Registra un comercio y abre su vinculación (KYB o KYC).

```json
{
  "external_ref": "HOST-0042",
  "legal_name": "Alojamientos del Valle S.A.S.",
  "doc_type": "NIT",
  "doc_number": "900123456-7",
  "fiscal_residence": "CO",
  "beneficial_owners": [{ "name": "…", "doc_type": "CC", "doc_number": "…" }],
  "bank_account": { "bank_code": "…", "type": "savings", "number": "…", "holder_doc": "…" }
}
```

`201` → `{ "id": "mrc_…", "kyc_status": "pending", "risk_level": null }`. Los datos bancarios y documentos se cifran a nivel de aplicación; nunca se devuelven completos (solo últimos 4 dígitos).

### `GET /v1/merchants/{id}`
`{ id, external_ref, kyc_status, risk_level, limits: { per_order_cop, per_month_cop }, created_at }`. `kyc_status`: `pending | review | approved | rejected`. Solo un comercio `approved` puede recibir órdenes.

## 3. Órdenes

### `POST /v1/orders`

```json
{
  "merchant_id": "mrc_…",
  "external_ref": "HM-48213",
  "amount_cop": 1000000,
  "network": "tron",
  "metadata": { "booking": "HM-48213" }
}
```

`201`:

```json
{
  "id": "ord_…",
  "state": "AWAITING_PAYMENT",
  "deposit_address": "T…",
  "network": "tron",
  "token": "USDT",
  "usdt_amount": "250.000000",
  "rate_cop_per_usdt": "4000.00",
  "expires_at": "2026-10-04T15:30:00Z"
}
```

- `external_ref` es único por proyecto. Repetirlo con otra llave de idempotencia devuelve `409`.
- La dirección es única por orden. La cotización queda bloqueada hasta `expires_at` (15 minutos por defecto, configurable por proyecto).
- `metadata` es libre, hasta 2 KB, sin datos personales del viajero.
- No hay campo `splits`: con el dinero llegando a Hellominus, el reparto es interno de Hellominus y Zuhay. Se agregaría en una versión posterior solo si cambia esa decisión.
- **ABIERTO (#4)**: `payment_valid_until`, la hora hasta la cual el pago sigue siendo válido (las confirmaciones de red pueden llegar después de `expires_at`). Zuhay debe retener la disponibilidad al menos hasta ahí.

### `GET /v1/orders/{id}`
Orden completa más `history: [{ from, to, event, at }]`. Con `?expand=payment` agrega `usdt_received`, `confirmations`, `tx_hash`.

### `POST /v1/orders/{id}/cancel`
Solo si el estado es `CREATED` o `AWAITING_PAYMENT`. En otro estado devuelve `409 invalid_state`.

### Estados que ve el proyecto

`CREATED, AWAITING_PAYMENT, PAYMENT_DETECTED, CONFIRMING, CONFIRMED, CONVERTING, CONVERTED, SETTLING, SETTLED, UNDERPAID, HELD_COMPLIANCE, REJECTED, REFUND_PENDING, REFUNDED, FAILED_CONVERSION, FAILED_PAYOUT, EXPIRED, CANCELLED`.

Los estados internos de fallo (`FAILED_CONVERSION`, `FAILED_PAYOUT`) y `HELD_COMPLIANCE` se exponen sin causa. El proyecto debe tratarlos como "en proceso" y no mostrarle al viajero un motivo.

Terminales: `SETTLED, REFUNDED, REJECTED, CANCELLED`.

**ABIERTO (#4)**: qué estado dispara la confirmación de la reserva (`CONFIRMED` por pago válido en cadena, o `SETTLED`/pesos recibidos).

## 4. Reembolsos (ABIERTO, brecha 1 del estándar)

El estándar solo devuelve por error de pago (pago de menos, tardío o rechazado). No cubre cancelar una reserva ya liquidada. Propuesta, sujeta a #3:

- `POST /v1/orders/{id}/refunds` con `{ amount_cop, reason }` → `rfd_…`.
- Solo a la billetera de origen y con aprobación de cumplimiento.
- Requiere definir si el anfitrión ya cobró (custodia hasta el check-in, brecha 2).

## 5. Liquidaciones

### `GET /v1/settlements?merchant_id=&from=&to=`
Dispersiones por comercio y periodo: `{ id, order_id, merchant_id, gross_cop, fee_cop, net_cop, rail, bank_ref, status, settled_at }`. `status`: `pending | done | failed`.

**ABIERTO (#3)**: momento del pago al anfitrión (inmediato o después del check-in).

## 6. Webhooks

La pasarela envía `POST` a la URL configurada por proyecto.

```
X-Signature: t=1760000000,v1=<hmac_sha256(secret, t + "." + body)>
```

```json
{
  "id": "evt_…",
  "type": "order.confirmed",
  "created_at": "2026-10-04T15:12:00Z",
  "data": { "order_id": "ord_…", "external_ref": "HM-48213", "state": "CONFIRMED" }
}
```

- Eventos: `order.payment_detected`, `order.confirmed`, `order.converted`, `order.settled`, `order.expired`, `order.held`, `order.refunded`.
- `order.held` no lleva motivo.
- Receptor: verificar firma, rechazar si `t` tiene más de 5 minutos, responder `2xx` rápido y procesar de forma idempotente por `id`. El orden de entrega no está garantizado; usar `GET /v1/orders/{id}` ante la duda.
- Reintentos: 1 min, 5 min, 30 min, 2 h, 12 h; después alerta al equipo de la pasarela.
- El secreto de firma es por proyecto, se rota sin cortes aceptando dos secretos durante una ventana.

## 7. Qué consume cada proyecto

| Proyecto | Llama | Recibe |
|---|---|---|
| Hellominus (servidor) | `POST /orders`, `GET /orders/{id}`, `POST /orders/{id}/cancel` | Webhooks que se mapean a `bookings.payment_status` |
| Zuhay | Webhooks de la pasarela para registrar el pago externo `HM-…` (idempotente por `evt_` y `external_ref`) | Es quien debe retener la disponibilidad hasta `payment_valid_until` |
| Cuenta de operación (interna) | `GET /settlements`, consola de cumplimiento | — |

El navegador del viajero nunca llama a esta API ni ve la llave: Hellominus la usa solo desde su servidor.

## 8. Fuera de alcance de v1

Webhooks de comercios por separado, pagos recurrentes, otras monedas distintas de USDT y COP, múltiples cuentas bancarias por comercio.

## 9. Preguntas para cerrar el contrato

1. ~~¿Quién es el `merchant`?~~ Resuelto: Hellominus. Falta validación legal (#1).
2. ~~¿Hay reparto en la orden?~~ Resuelto: no, el reparto es interno.
3. ¿Qué estado confirma la reserva? (#4)
4. ¿Zuhay puede registrar un pago externo idempotente y retener fechas hasta `payment_valid_until`? (#6)
5. ¿Redes habilitadas en v1: solo `tron`, o también `polygon`? (#5)

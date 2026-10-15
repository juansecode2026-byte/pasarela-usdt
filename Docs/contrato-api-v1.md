# Contrato de la API v1 (borrador 2)

Estado: borrador del 14 de octubre de 2026. Reemplaza el borrador del 4 de octubre, que trataba a Hellominus como dueño del sistema. Ahora el sistema es el **proveedor de liquidez USDT** (nombre provisional), independiente, y sus **clientes** (Hellominus, DEVMINUS) lo consumen por esta API. Es lo único que comparten los proyectos.

Fuentes: `Docs/pasarela-usdt-colombia-estandar.html` (flujo y reglas), `Libro de contabilidad blockchain/` y `CLAUDE.md` (decisiones). Lo marcado **ABIERTO** depende de una decisión de `DECISIONES.md` y no se implementa hasta cerrarla.

## 0. Modelo en una página

1. Un **cliente** (Hellominus, DEVMINUS) se vincula una sola vez: pasa KYB y deja la cuenta bancaria a la que se le dispersa. Cada cliente es un `project` y tiene su **`merchant`**: la empresa que recibe los pesos.
2. Cuando un pagador del mundo quiere pagar en USDT, la aplicación del cliente (desde su servidor) **crea una orden**. La API devuelve una dirección de depósito única, el monto exacto en USDT y una hora límite.
3. El **pagador paga directo al proveedor de liquidez** (a esa dirección). El proveedor analiza la billetera de origen, espera confirmaciones y convierte USDT a pesos.
4. El proveedor **dispersa los pesos desde Bancolombia a la cuenta del merchant** (la empresa cliente), y avisa por webhook. El proveedor no paga a anfitriones ni a otros terceros: el cliente reparte por su cuenta.

## 1. Convenciones

- **Base**: `https://<host>/v1`. Solo HTTPS. Cambios incompatibles van en `/v2`; agregar campos opcionales no rompe `v1`.
- **Autenticación**: `Authorization: Bearer <api_key_del_proyecto>`. Una llave por cliente, con permisos limitados, rotable. La llave identifica el `project_id`; ningún cuerpo ni ruta lo lleva. Se usa solo desde el servidor del cliente, nunca desde el navegador del pagador.
- **Idempotencia**: todo `POST` exige `Idempotency-Key` (UUID). Misma llave y mismo cuerpo devuelve la respuesta original; misma llave con cuerpo distinto devuelve `409 idempotency_conflict`. Se conserva 24 horas.
- **Dinero**: nunca decimales flotantes.
  - Pesos: entero en pesos (`amount_cop`). Internamente centavos. **ABIERTO**: si se aceptan centavos en la entrada.
  - USDT: cadena de texto con 6 decimales (`"250.000000"`).
  - Tasa: cadena (`"4000.00"`).
- **Fechas**: ISO 8601 en UTC.
- **Identificadores**: prefijados y opacos (`mrc_`, `ord_`, `stl_`, `rfd_`, `evt_`).
- **Errores**: `{ "error": { "code": "...", "message": "...", "request_id": "..." } }`. Códigos: `400 invalid_request`, `401 unauthorized`, `403 forbidden`, `404 not_found`, `409 idempotency_conflict | invalid_state`, `422 merchant_not_approved | limit_exceeded | network_not_enabled | payer_not_allowed`, `429 rate_limited`, `5xx internal`.
- **Paginación**: `?limit=` (máx. 100) y `?cursor=`; respuesta con `next_cursor`.
- **Límite de velocidad**: por llave; encabezado `Retry-After` en `429`.
- **Motivos de cumplimiento**: la API nunca revela por qué una orden queda en revisión ni expone resultados de análisis de billeteras.

## 2. Comercios (la empresa que recibe los pesos)

Hay uno por cliente. **Decidido (14 de octubre de 2026)**: la dispersión va a la **empresa cliente**, no a cada anfitrión. Por eso el comercio es una empresa (NIT), con una cuenta bancaria verificada. Los documentos del proveedor de liquidez recomiendan atender solo personas jurídicas con KYB, y el comercio cumple eso.

### `POST /v1/merchants`
Registra la empresa cliente y abre su vinculación (KYB).

```json
{
  "external_ref": "HELLOMINUS",
  "legal_name": "Hellominus S.A.S.",
  "doc_type": "NIT",
  "doc_number": "900123456-7",
  "fiscal_residence": "CO",
  "beneficial_owners": [{ "name": "…", "doc_type": "CC", "doc_number": "…" }],
  "bank_account": { "bank_code": "…", "type": "savings", "number": "…", "holder_doc": "900123456-7" }
}
```

`201` → `{ "id": "mrc_…", "kyc_status": "pending", "risk_level": null }`.

- La cuenta debe estar **a nombre del mismo NIT** del comercio. Cualquier otra titularidad se rechaza.
- Los datos bancarios y documentos se cifran a nivel de aplicación y nunca se devuelven completos (solo últimos 4 dígitos).
- El alta normalmente la hace el equipo del proveedor con el cliente, no se automatiza en la primera versión. **ABIERTO**: si este endpoint queda interno.

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
  "payer": { "type": "person", "country": "AR" },
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
  "expires_at": "2026-10-14T15:30:00Z"
}
```

- `external_ref` es único por cliente. Repetirlo con otra llave de idempotencia devuelve `409`.
- La dirección es única por orden. La cotización queda bloqueada hasta `expires_at` (15 minutos por defecto, configurable por cliente). Los documentos del proveedor describen cotizaciones de 10 a 30 segundos para clientes institucionales (RFQ); para el pagador final de una reserva se mantiene la ventana larga.
- `payer`: **el pagador final es una persona**, no una empresa. Esto sube el KYC y el monitoreo. **ABIERTO (#1)**: qué datos del pagador se exigen (país, tipo, y nombre e identificación cuando el acumulado se acerca al umbral CARF). Hasta definirlo, solo `type` y `country`. Un pagador de un país sancionado se rechaza con `422 payer_not_allowed` antes de crear la orden.
- `metadata` es libre, hasta 2 KB, sin datos personales del pagador.
- No hay campo `splits`: el reparto a anfitriones es interno del cliente.
- **ABIERTO**: `payment_valid_until`, la hora hasta la cual el pago sigue siendo válido (las confirmaciones de red pueden llegar después de `expires_at`). El cliente debe retener la disponibilidad al menos hasta ahí.

### `GET /v1/orders/{id}`
Orden completa más `history: [{ from, to, event, at }]`. Con `?expand=payment` agrega `usdt_received`, `confirmations`, `tx_hash`.

### `POST /v1/orders/{id}/cancel`
Solo si el estado es `CREATED` o `AWAITING_PAYMENT`. En otro estado devuelve `409 invalid_state`.

### Estados que ve el cliente

`CREATED, AWAITING_PAYMENT, PAYMENT_DETECTED, CONFIRMING, CONFIRMED, CONVERTING, CONVERTED, SETTLING, SETTLED, UNDERPAID, HELD_COMPLIANCE, REJECTED, REFUND_PENDING, REFUNDED, FAILED_CONVERSION, FAILED_PAYOUT, EXPIRED, CANCELLED`.

Los estados de fallo y `HELD_COMPLIANCE` se exponen **sin causa**. El cliente debe tratarlos como "en proceso" y no mostrarle al pagador un motivo. Terminales: `SETTLED, REFUNDED, REJECTED, CANCELLED`.

**Decidido (14 de octubre de 2026, Juan):** la reserva se confirma cuando el pago es válido en la red, es decir en el estado `CONFIRMED`, sin esperar a que se conviertan los USDT ni a que salgan los pesos. El evento que el cliente espera es `order.confirmed`. **Decidido:** como se confirma antes de convertir y de dispersar, el proveedor asume el riesgo de precio entre ese momento y la dispersión.

## 4. Reembolsos (ABIERTO, brecha 1 del estándar)

El estándar solo devuelve por error de pago (pago de menos, tardío o rechazado). No cubre cancelar una reserva ya liquidada. Con la dispersión a la empresa cliente, un reembolso posterior a la liquidación implicaría que el cliente devuelva los pesos y el proveedor pague de vuelta al pagador. Propuesta, sujeta a #3:

- `POST /v1/orders/{id}/refunds` con `{ amount_cop, reason }` → `rfd_…`.
- Solo a la billetera de origen y con aprobación de cumplimiento.

## 5. Liquidaciones

### `GET /v1/settlements?merchant_id=&from=&to=`
Dispersiones al comercio por periodo: `{ id, order_id, merchant_id, gross_cop, fee_cop, net_cop, rail, bank_ref, status, settled_at }`. `status`: `pending | done | failed`. `rail` indica la entidad: **Bancolombia** como cuenta de dispersión del proveedor.

- **ABIERTO (#8)**: si el proveedor actúa como principal (compra y vende con su balance, con capital de trabajo) o como agente (ejecuta por cuenta del cliente y cobra comisión). Cambia IVA, contratos y el momento de la dispersión.
- **ABIERTO**: frecuencia de dispersión (inmediata por orden o por lote) y el segundo banco que recomiendan los documentos.

## 6. Webhooks

El proveedor envía `POST` a la URL configurada por cliente.

```
X-Signature: t=1760000000,v1=<hmac_sha256(secret, t + "." + body)>
```

```json
{
  "id": "evt_…",
  "type": "order.confirmed",
  "created_at": "2026-10-14T15:12:00Z",
  "data": { "order_id": "ord_…", "external_ref": "HM-48213", "state": "CONFIRMED" }
}
```

- Eventos: `order.payment_detected`, `order.confirmed`, `order.converted`, `order.settled`, `order.expired`, `order.held`, `order.refunded`.
- `order.held` no lleva motivo.
- Receptor: verificar firma, rechazar si `t` tiene más de 5 minutos, responder `2xx` rápido y procesar de forma idempotente por `id`. El orden de entrega no está garantizado; usar `GET /v1/orders/{id}` ante la duda.
- Reintentos: 1 min, 5 min, 30 min, 2 h, 12 h; después alerta al equipo del proveedor.
- El secreto de firma es por cliente y se rota aceptando dos secretos durante una ventana.

## 6b. Cómo se entera el cliente de que llegó el pago (sincronía)

**Decidido (14 de octubre de 2026, Juan):**
- El proveedor es quien avisa, porque es quien recibe los USDT y el único que sabe qué pasó con el pago.
- La confirmación a Hellominus es un **correo** que el proveedor envía **inmediatamente** después de que el pago es válido en la red (estado `CONFIRMED`).
- El proveedor **asume la volatilidad**: confirma antes de convertir, y el riesgo de precio entre la confirmación y la conversión es suyo.
- Ese mismo pago se **registra en el libro contable** en el momento de confirmarse, con: hash de la transacción, red, fecha y hora exacta (UTC), monto, direcciones de origen y destino, referencia de la orden y resultado del análisis de riesgo.
- El pagador debe haber hecho el KYC en un exchange (Binance u otro que cumpla los criterios del proveedor) y pagar desde su cuenta, a su nombre. El proveedor mantiene una lista de exchanges aceptados y sus criterios (paso 3.10 del plan). El KYC propio del proveedor sigue siendo necesario.

**Contenido del correo (propuesta):** referencia de la orden (`external_ref`), monto en USDT y en pesos, hash con enlace al explorador, fecha y hora exacta, y estado.

| Canal | Para qué sirve | ¿Confirma una reserva? |
|---|---|---|
| **Correo inmediato** | Es el aviso que decidió Juan. | **Sí** (decisión de Juan). |
| **Webhook firmado** (recomendado, no decidido) | Mismo evento, pero para que el servidor del cliente lo procese solo. | Sí, si se adopta. |
| **Consulta** `GET /v1/orders/{id}` | Comprobar el estado cuando hay dudas o se perdió un aviso. | Sí, si devuelve `CONFIRMED`. |
| **Conciliación diaria** `GET /v1/settlements` | Cuadrar lo liquidado contra lo registrado. | No: detecta diferencias. |
| **Leer la blockchain por su cuenta** | Comprobación extra. | **No.** |

**Riesgos del correo, y cómo reducirlos (recomendación, no decisión):** un correo puede llegar tarde, perderse o falsificarse (alguien podría mandar uno que diga "pago recibido"), y si lo procesa una persona puede equivocarse o duplicar. Para reducirlo, sin cambiar lo decidido:
1. Enviarlo desde el dominio de la empresa con SPF, DKIM y DMARC configurados, para que no se pueda falsificar fácilmente.
2. Incluir la referencia de la orden y el hash con enlace al explorador, para que quien lo recibe pueda comprobarlo.
3. Que Hellominus compruebe la orden con una consulta antes de confirmar, o que se envíe también el webhook firmado desde el mismo evento.
4. Guardar una copia de cada correo enviado en el expediente de la operación.

**Por qué el cliente no debe confirmar mirando la blockchain:** ve que llegaron USDT, pero no sabe si la billetera de origen fue marcada por el análisis de riesgo, ni si la orden quedó en revisión de cumplimiento. Podría confirmar una reserva con dinero que luego se retiene.

## 7. Qué consume cada cliente

| Cliente | Llama | Recibe |
|---|---|---|
| Hellominus (servidor) | `POST /orders`, `GET /orders/{id}`, `POST /orders/{id}/cancel` | Webhooks que se mapean al estado de pago de su reserva |
| DEVMINUS (servidor) | Igual | Igual |
| Zuhay | **ABIERTO**: si es cliente directo o recibe los avisos a través de Hellominus | Si registra pagos externos, debe hacerlo de forma idempotente por `evt_` y `external_ref`, y retener fechas hasta `payment_valid_until` |
| Equipo del proveedor (interno) | `GET /settlements`, consola de cumplimiento, alta de comercios | — |

## 8. Fuera de alcance de v1

- RFQ institucional con cotización de 10 a 30 segundos para otras empresas que compren o vendan liquidez en bloque (el modelo del documento Proveedor de liquidez). Se agrega en una versión posterior si el negocio lo pide.
- Dispersión a anfitriones o a otros terceros.
- Pagos recurrentes, otras monedas distintas de USDT y COP (el libro prevé BTC, ETH y USD), múltiples cuentas bancarias por comercio.

## 9. Preguntas para cerrar el contrato

1. ¿Zuhay es cliente directo o recibe los avisos a través de Hellominus? Dijiste primero "Hellominus y Zuhay" y después "Hellominus y DEVMINUS".
2. ¿Qué datos del pagador final exige el abogado (país, nombre, identificación)? (#1)
3. ¿Principal o agente? (#8)
4. ~~¿Qué estado confirma la reserva?~~ Resuelto: `CONFIRMED`, pago válido en la red. El riesgo de precio lo asume el proveedor.
5. ¿Política de reembolso? (#3)
6. ¿Redes habilitadas en v1: solo `tron`, o también `polygon`? (#5)
7. ¿El alta de comercios es interna del proveedor?

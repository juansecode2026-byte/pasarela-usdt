# Pasarela de pago USDT en Colombia: estándar reutilizable

> Versión en Markdown de `pasarela-usdt-colombia-estandar.html`, generada con `scripts/sincronizar-md.py`. No editar a mano: se regenera desde el HTML. El HTML tiene las partes interactivas.

El comercio cobra en pesos, el cliente paga en USDT, la plataforma convierte y dispersa a una cuenta bancaria, y cada operación queda documentada para la UIAF y la DIAN. Este documento define el proceso completo, la lógica, los datos y la estructura que se repite en todos los proyectos.

**Orden**Monto en COP, cotización bloqueada

**Depósito**Dirección única por orden

**Confirmación**On-chain más screening AML

**Conversión**USDT a COP con tasa registrada

**Dispersión**Transferencia bancaria al comercio

**Reporte**UIAF mensual, DIAN anual

**Capa de cumplimiento en cada paso:** KYC del comercio, análisis de la billetera de origen, bitácora inmutable, expediente por operación, retención de datos por cinco años.

## Qué resuelve este estándar

Cada proyecto nuevo no debería reinventar el cobro en USDT ni el cumplimiento. La idea es un núcleo común y piezas intercambiables.

- **Un solo núcleo** con la máquina de estados, el libro contable, las cotizaciones y el motor de reportes.
- **Adaptadores** para lo que cambia: red blockchain, proveedor de liquidez, banco, KYC, analítica on-chain.
- **Configuración por proyecto** en un archivo, sin tocar el código del núcleo.
- **Trazabilidad completa**: de cada peso que sale del banco se puede demostrar de qué USDT vino y quién lo pagó.

## Rol legal: la decisión que define todo

Antes de escribir código hay que saber quién es el proveedor frente a la ley. Cambia las obligaciones, los registros y la arquitectura.

| Modelo | Qué hace la plataforma | Obligaciones |
| --- | --- | --- |
| **A. Proveedor directo** | Recibe USDT por cuenta de terceros, lo convierte y dispersa pesos. | Queda como proveedor de servicios de activos virtuales (UIAF) y de criptoactivos (DIAN): SIREL, SARLAFT, reportes mensuales y anuales, RUT actualizado. |
| **B. Orquestador** | Coordina el flujo, pero la custodia y la conversión las hace un exchange o proveedor ya registrado. | Carga más liviana, pero depende contractualmente del tercero y debe poder entregarle datos completos. Hay que validar si la orquestación sola evita la condición de proveedor. |
| **C. Cobro propio** | Cada proyecto recibe USDT como pago de sus propias ventas y los convierte en Binance a nombre propio. | El proyecto actúa como usuario de un proveedor (Binance), no como proveedor. En principio no le aplican los reportes de proveedor ante UIAF y DIAN, pero sí factura, IVA, renta y patrimonio. Validar con abogado. |

**Validar con abogado y tributarista**

Qué modelo aplica a cada proyecto, y qué entidad figura como responsable ante la UIAF y la DIAN. Si los proyectos pertenecen a empresas distintas, puede que cada una necesite su propio registro, o que una sola entidad opere para todas. Este documento diseña para ambos casos con el campo `legal_entity_id`.

## Arquitectura estándar

Tres capas. Solo la tercera cambia de un proyecto a otro.

#### Núcleo (igual en todos)

Máquina de estados de la orden, cotizaciones, libro contable de doble partida, motor de reglas, bitácora de auditoría, generador de reportes y expediente.

#### Adaptadores (intercambiables)

Red blockchain (TRON, Polygon…), liquidez (exchange u OTC), dispersión bancaria, KYC/KYB, análisis on-chain, formato de reporte UIAF y DIAN.

#### Proyecto (solo configuración)

Comisiones, redes habilitadas, tolerancias, umbrales de revisión, webhooks, entidad legal, cuenta bancaria de dispersión.

### Módulos del núcleo

| Módulo | Responsabilidad |
| --- | --- |
| `orders` | Crea órdenes, aplica la máquina de estados, expira y cancela. |
| `chain-watcher` | Detecta depósitos, cuenta confirmaciones, maneja reorganizaciones de cadena y evita procesar dos veces la misma transacción. |
| `screening` | Analiza la billetera de origen y el riesgo antes de aceptar fondos. |
| `quotes` | Calcula USDT esperado, bloquea la tasa por un tiempo y guarda spread. |
| `conversion` | Ejecuta USDT a COP con el proveedor y guarda la tasa efectiva. |
| `payouts` | Dispersa al banco del comercio y concilia el comprobante. |
| `ledger` | Asientos de doble partida por cada evento, con saldos por proyecto y comercio. |
| `compliance` | KYC, casos en revisión, ROS, extracción de datos para UIAF y DIAN, expediente. |
| `webhooks` | Notifica al proyecto con firma HMAC y reintentos. |

## Flujo del pago, paso a paso

El proceso completo, desde que el comercio se registra hasta el reporte regulatorio.

### Antes del primer pago: alta del comercio

1. **KYB/KYC del comercio**

   Razón social, NIT o documento, representante legal, beneficiario final, residencia fiscal, actividad económica, origen de fondos. Se consulta contra listas restrictivas.

   Responsable: cumplimiento
2. **Cuenta bancaria en COP a nombre del comercio**

   Se valida la titularidad. La plataforma nunca dispersa a terceros distintos del comercio aprobado.

   Responsable: operaciones
3. **Perfil de riesgo y límites**

   Se asigna nivel de riesgo (bajo, medio, alto) y topes por operación y por mes. A mayor riesgo, más revisión manual.

   Responsable: oficial de cumplimiento

### Durante el pago

1. **El proyecto crea la orden**

   Envía monto en COP, referencia propia, comercio y red. La plataforma responde con la dirección de depósito, el monto exacto en USDT y la hora límite.

   Sistema: `POST /v1/orders`
2. **Cotización bloqueada**

   Se fija la tasa COP por USDT con el spread configurado. Normalmente de 10 a 15 minutos. Pasado ese plazo, la orden expira.

   Sistema: `quotes`
3. **El cliente paga en USDT**

   Envía desde su billetera a la dirección única de la orden, por la red indicada. Una dirección por orden evita confundir pagos.

   Cliente
4. **Detección y análisis de la billetera de origen**

   Al ver la transacción se consulta al proveedor de analítica. Si el riesgo supera el umbral, la orden pasa a revisión de cumplimiento y no avanza.

   Sistema: `chain-watcher` y `screening`
5. **Confirmaciones y verificación del monto**

   Se espera el número de confirmaciones de la red. Luego se compara lo recibido con lo esperado: exacto, de menos o de más.

   Sistema
6. **Conversión USDT a COP**

   Se ejecuta con el proveedor de liquidez. Se guarda tasa efectiva, comisión y referencia del proveedor.

   Sistema: `conversion`
7. **Dispersión al comercio**

   Se calcula el neto (monto menos comisión de la plataforma) y se transfiere a su cuenta. Se guarda el comprobante bancario.

   Sistema: `payouts`
8. **Notificación y asientos contables**

   Se envía el webhook `order.settled` al proyecto y se cierran los asientos de la operación.

   Sistema: `webhooks` y `ledger`

### Después: reportes y conciliación

1. **Conciliación diaria en tres vías**

   Saldo on-chain contra saldo del libro contable contra saldo bancario. Cualquier diferencia abre un caso.

   Responsable: operaciones
2. **Reportes periódicos**

   Los datos ya están estructurados por operación, por lo que los reportes de UIAF y DIAN se generan desde la base de datos, sin reconstruir nada.

   Responsable: cumplimiento

## Máquina de estados de la orden

Toda la lógica de negocio sale de aquí. Una orden solo puede estar en un estado y solo se mueve por eventos permitidos. Cualquier otro evento se rechaza y queda registrado.

### Simulador

Prueba el flujo: elige eventos y mira cómo cambia el estado, qué se registra y qué se notifica. Esta tabla de transiciones es la misma que usa el código de abajo.

Estado actual: **CREATED**

Camino normal

Excepciones

Eventos permitidos ahora

### Tabla de transiciones

| Estado | Evento | Nuevo estado | Qué ocurre |
| --- | --- | --- | --- |

### Implementación de referencia

```
export type OrderState =
  | 'CREATED' | 'AWAITING_PAYMENT' | 'PAYMENT_DETECTED' | 'CONFIRMING'
  | 'CONFIRMED' | 'CONVERTING' | 'CONVERTED' | 'SETTLING' | 'SETTLED'
  | 'UNDERPAID' | 'HELD_COMPLIANCE' | 'REJECTED'
  | 'REFUND_PENDING' | 'REFUNDED'
  | 'FAILED_CONVERSION' | 'FAILED_PAYOUT'
  | 'EXPIRED' | 'CANCELLED';

export type OrderEvent = string;

const TRANSITIONS: Record<string, Record<string, OrderState>> = {
  CREATED:            { activate: 'AWAITING_PAYMENT', cancel: 'CANCELLED' },
  AWAITING_PAYMENT:   { tx_detected: 'PAYMENT_DETECTED', expire: 'EXPIRED', cancel: 'CANCELLED' },
  PAYMENT_DETECTED:   { screen_pass: 'CONFIRMING', screen_flag: 'HELD_COMPLIANCE' },
  CONFIRMING:         { confirmed_ok: 'CONFIRMED', confirmed_under: 'UNDERPAID', tx_dropped: 'AWAITING_PAYMENT' },
  UNDERPAID:          { topup_received: 'CONFIRMING', grace_expired: 'REFUND_PENDING' },
  HELD_COMPLIANCE:    { approve: 'CONFIRMING', reject: 'REJECTED' },
  CONFIRMED:          { start_conversion: 'CONVERTING' },
  CONVERTING:         { conversion_ok: 'CONVERTED', conversion_fail: 'FAILED_CONVERSION' },
  FAILED_CONVERSION:  { retry: 'CONVERTING', abort: 'REFUND_PENDING' },
  CONVERTED:          { start_payout: 'SETTLING' },
  SETTLING:           { payout_ok: 'SETTLED', payout_fail: 'FAILED_PAYOUT' },
  FAILED_PAYOUT:      { retry: 'SETTLING' },
  REFUND_PENDING:     { refund_sent: 'REFUNDED' },
  EXPIRED:            { late_tx: 'REFUND_PENDING' },
  // terminales: SETTLED, REFUNDED, REJECTED, CANCELLED
};

export function transition(order, event, actor) {
  const next = TRANSITIONS[order.state]?.[event];
  if (!next) {
    audit('INVALID_TRANSITION', { orderId: order.id, from: order.state, event, actor });
    throw new Error(`Evento ${event} no permitido en ${order.state}`);
  }
  // Una sola transacción de base de datos: estado + historial + asientos + eventos de cumplimiento
  return db.tx(async (t) => {
    await t.orders.updateState(order.id, order.state, next);   // bloqueo optimista: falla si otro proceso cambió el estado
    await t.history.insert({ orderId: order.id, from: order.state, to: next, event, actor });
    await ledger.postFor(t, order, event);                      // asientos de doble partida
    await compliance.recordFor(t, order, event);               // ROS, UIAF, CARF según corresponda
    await webhooks.enqueue(t, order, event);                   // se envía después del commit
    return { ...order, state: next };
  });
}
```

### Clasificación del monto recibido

```
// Montos en unidades mínimas: USDT con 6 decimales (1 USDT = 1_000_000n)
export function classifyAmount(received: bigint, expected: bigint,
                               tol: { underBps: number; overBps: number }) {
  const min = expected - (expected * BigInt(tol.underBps)) / 10_000n;
  const max = expected + (expected * BigInt(tol.overBps)) / 10_000n;
  if (received < min) return 'UNDER';   // evento confirmed_under
  if (received > max) return 'OVER';    // confirmed_ok + excedente a devolver o abonar
  return 'EXACT';                       // evento confirmed_ok
}

// Cotización: COP en centavos y tasa en centavos de COP por 1 USDT (spread incluido)
export function usdtForOrder(amountCopMinor: bigint, rateMinor: bigint): bigint {
  const num = amountCopMinor * 1_000_000n;
  return (num + rateMinor - 1n) / rateMinor;   // redondeo hacia arriba: nunca cobrar de menos
}
// Ej.: 1.000.000 COP = 100_000_000n centavos; tasa 4.000,00 = 400_000n
//      usdtForOrder(100_000_000n, 400_000n) = 250_000_000n = 250,000000 USDT
```

### Idempotencia del detector on-chain

```
// La misma transacción puede llegar dos veces (reconexión, reorg, webhook duplicado).
// La unicidad (network, tx_hash, log_index) en la base de datos es la defensa final.
async function onObservedTx(tx) {
  const inserted = await db.onchainTxs.insertIfAbsent(tx);   // ON CONFLICT DO NOTHING
  if (!inserted) return;                                     // ya procesada
  const order = await db.orders.findByDepositAddress(tx.to);
  if (!order) return quarantine(tx);                         // pago sin orden: se revisa a mano
  await transition(order, 'tx_detected', 'chain-watcher');
}
```

## Reglas de negocio

Los valores son ejemplos iniciales. Cada proyecto los ajusta en su configuración.

| Regla | Comportamiento estándar | Configurable |
| --- | --- | --- |
| Expiración | La orden vence a los 15 minutos. La tasa deja de ser válida. | `quote_ttl_seconds` |
| Pago de menos | Pasa a `UNDERPAID`. Se espera un complemento durante un plazo de gracia. Si no llega, se devuelve. | `tolerance.under_bps`, `underpaid_grace_minutes` |
| Pago de más | Se procesa el monto esperado y el excedente se registra para devolver o abonar según política del proyecto. | `tolerance.over_bps`, `overpay_policy` |
| Pago tardío | Llega a una orden vencida. Por defecto se devuelve. Opcional: recotizar y aceptar. | `late_payment_policy` |
| Confirmaciones | Se exige un mínimo por red antes de dar el pago por válido. Se calibra con el proveedor y el riesgo de reorganización. | `networks[].min_confirmations` |
| Reorganización de cadena | Si una transacción desaparece, la orden vuelve a `AWAITING_PAYMENT` y se alerta. | No |
| Revisión reforzada | Operaciones sobre un umbral, comercios de riesgo alto o billeteras con alertas pasan a revisión manual. | `review.over_usd`, `review.risk_score` |
| Devoluciones | Solo a la billetera de origen y solo si cumplimiento lo autoriza. Fondos sospechosos no se devuelven sin guía legal. | No |
| Redondeo | Todo en enteros (centavos de COP, unidades de 6 decimales de USDT). Nunca decimales flotantes. | No |
| Reintentos | Conversión y dispersión se reintentan con retroceso exponencial y un número máximo. Después, a revisión manual. | `retry.max_attempts` |

**Fondos de origen dudoso**

Si una transacción se marca como sospechosa, la plataforma no avanza, no devuelve automáticamente y no avisa al cliente del motivo. El oficial de cumplimiento decide si se libera o se rechaza y si corresponde un ROS inmediato.

## Modelo de conversión con Binance

Binance entra como proveedor de liquidez: recibe los USDT, los vende por pesos y permite retirar COP hacia un banco colombiano. Se implementa como un adaptador más, sin tocar la máquina de estados de la orden.

**Lo que cambia frente al diseño base**

Binance no le paga al comercio. El retiro de pesos va a la cuenta bancaria de la entidad operadora, y desde ahí el banco dispersa a cada comercio. Son dos saltos: Binance al banco de la entidad, y banco de la entidad al comercio.

### Flujo con Binance

1. **Cobro y confirmación en direcciones propias**

   Igual que en el diseño base: una dirección por orden, análisis AML y confirmaciones. La atribución del pago a la orden se resuelve aquí, porque la dirección de depósito de Binance pertenece a la cuenta y no distingue órdenes.

   Sistema: `chain-watcher`
2. **Barrido a Binance**

   El USDT confirmado se envía a la dirección de depósito de la cuenta corporativa en la misma red, por orden o por lote. Se espera a que Binance acredite el depósito.

   Sistema: `conversion`
3. **Venta USDT a COP**

   Orden en el par USDT/COP o cotización con precio fijo mediante Convert. Se guarda identificador de la orden, monto ejecutado, comisión y tasa efectiva.

   Sistema: adaptador Binance
4. **Retiro de COP al banco de la entidad**

   Por Transfiya, Bre-B o ACH. Con Transfiya, el retiro hay que aceptarlo en la app del banco, así que este paso se modela como tarea con doble aprobación hasta confirmar que se puede automatizar.

   Responsable: finanzas
5. **Conciliación del retiro**

   Se compara el crédito en el extracto bancario con el historial de órdenes fiat de Binance y con el monto esperado del lote.

   Sistema: conciliación diaria
6. **Dispersión al comercio desde el banco de la entidad**

   Se paga el neto del comercio. Puede hacerse apenas la venta queda confirmada, con un colchón de pesos propio, o cuando el retiro llega al banco.

   Sistema: `payouts`

### Dos decisiones de diseño

| Decisión | Opción | Cómo funciona | Ventaja | Riesgo |
| --- | --- | --- | --- | --- |
| Liquidación | Por orden | Una venta y un retiro por cada orden. | Trazabilidad uno a uno y expediente simple. | Más comisiones y más tareas manuales. |
| Por lote | Se agrupan órdenes confirmadas y se vende y retira cada cierto tiempo. El resultado se reparte proporcionalmente. | Menos operaciones y mejor ejecución en montos mayores. | Exposición al precio mientras se acumula; el reparto debe quedar documentado. |
| Fondeo del pago al comercio | Con colchón propio | Se paga desde un saldo en pesos del banco y Binance lo repone después. | El comercio recibe rápido. | Requiere capital de trabajo y un saldo mínimo vigilado. |
| Contra retiro | Se paga cuando los pesos llegan al banco. | No exige capital propio. | Más lento y sujeto a la aceptación de Transfiya o a los tiempos de ACH. |

### Qué permite Binance y qué hay que validar

Resumen de lo que se encontró en documentación y guías públicas. Las condiciones de Binance cambian, así que cada punto se confirma con Binance antes de construir.

| Tema | Qué se encontró | Qué hacer |
| --- | --- | --- |
| Retiro de pesos | Se puede retirar COP a un banco colombiano, pero primero hay que convertir los USDT a COP dentro de Binance. | Diseñar la venta como paso previo obligatorio. |
| Destino del retiro | Con Transfiya solo se retira a la cuenta asociada al celular del titular de la cuenta de Binance, y el retiro se acepta desde la app del banco. | Retirar siempre a la cuenta de la entidad operadora y dispersar desde ahí. |
| Rieles y tiempos | Transfiya es inmediato y ACH puede tardar hasta tres días hábiles según una guía de Binance. Una fuente reporta retiro directo por Bre-B desde el 10 de febrero de 2026. | Confirmar rieles vigentes, límites y horarios con Binance. |
| API de venta | Existen las API de Spot y de Convert. El par USDT/COP lo menciona una guía, no la documentación oficial. | Confirmar que el par y los límites existen para la cuenta antes de fijar el diseño. |
| API de retiro en pesos | El conector oficial consultado lista retiro fiat por API para BRL, ARS y MXN. COP no aparece. | Asumir paso manual con doble aprobación hasta que Binance confirme lo contrario. |
| Tipo de cuenta | Para usar la API fiat se exige KYC o KYB completado y el servicio fiat activado. | Abrir cuenta corporativa a nombre de la entidad operadora. No operar el flujo desde una cuenta personal. |
| Costos de referencia | Comisión de operación spot de 0,1 %. El retiro de COP por Transfiya sin comisión de Binance. | Verificar tarifas de la cuenta y tomar la comisión real de cada ejecución. |
| Mercado P2P | Es la vía más común para personas, con contraparte individual. | No usarlo como motor de la pasarela: no escala, hay pagos de terceros y riesgo de bloqueo bancario. Solo contingencia manual con aprobación de cumplimiento. |

**Binance no reemplaza las obligaciones de la entidad**

Si la entidad recibe USDT por cuenta de los comercios y los cambia a pesos, sigue siendo quien presta el servicio ante la UIAF y la DIAN (modelo A del apartado de rol legal), aunque la conversión ocurra en Binance. Las fuentes consultadas no permiten confirmar si Binance está registrado ante la UIAF, y la UIAF indica que sus reportes aplican a los obligados domiciliados en Colombia. Hay que verificarlo directamente y no apoyarse en el reporte de un tercero.

**Riesgos propios de usar un exchange**

Contraparte (fondos depositados en Binance), precio y deslizamiento entre la confirmación y la venta, liquidez limitada del par, limitación o cierre de la cuenta por parte de Binance o del banco receptor, cambios en rieles y productos, y caída de la API. Mitigación: mantener saldo mínimo en Binance, vender apenas se acredite, pausar si la tasa efectiva se aleja de la cotización más de un umbral, y tener un segundo proveedor de liquidez detrás del mismo contrato de adaptador.

### Estados del trabajo de conversión

La orden sigue usando la misma máquina de estados. Dentro de `CONVERTING` corre un trabajo de conversión con su propia máquina, que puede abarcar una orden o un lote.

| Estado | Evento | Nuevo estado | Qué ocurre |
| --- | --- | --- | --- |
| `PENDING_SWEEP` | `sweep_sent` | `SWEEP_SENT` | Se envía el USDT a la dirección de depósito de Binance y se guarda el hash. |
| `SWEEP_SENT` | `deposit_credited` | `AT_EXCHANGE` | Binance acredita el depósito. |
| `SWEEP_SENT` | `sweep_failed` | `MANUAL_REQUIRED` | Depósito no acreditado en el tiempo esperado. Caso para operaciones. |
| `AT_EXCHANGE` | `sell_placed` | `SELL_PLACED` | Se envía la orden de venta con identificador propio (idempotencia). |
| `SELL_PLACED` | `filled` | `SOLD` | Se guardan pesos obtenidos, comisión y tasa efectiva. Se revisa el deslizamiento. |
| `SELL_PLACED` | `sell_failed` | `MANUAL_REQUIRED` | Rechazo, ejecución parcial sin completar o deslizamiento sobre el umbral. |
| `SOLD` | `withdraw_requested` | `FIAT_WITHDRAW_REQUESTED` | Se crea la tarea de retiro de COP (manual con doble aprobación o por API si está disponible). |
| `FIAT_WITHDRAW_REQUESTED` | `bank_credited` | `FIAT_RECEIVED` | Se concilia el crédito en el banco con el retiro. |
| `FIAT_WITHDRAW_REQUESTED` | `withdraw_failed` | `MANUAL_REQUIRED` | Retiro rechazado o sin acreditar. Caso para finanzas. |

La orden pasa de `CONVERTING` a `CONVERTED` (evento `conversion_ok`) cuando el trabajo llega a `SOLD` si el pago al comercio se hace con colchón propio, o a `FIAT_RECEIVED` si se paga contra retiro. Se controla con `conversion_ok_at` en la configuración.

### Contabilidad con Binance

Mismo ejemplo de la sección contable: orden de 1.000.000 COP (250 USDT). El costo de conversión de 5.000 COP se desglosa, a modo ilustrativo, en 1.000 de comisión de operación (0,1 %) y 4.000 de deslizamiento.

| Evento | Cuenta | Débito (COP) | Crédito (COP) |
| --- | --- | --- | --- |
| Pago confirmado | USDT en custodia propia (activo) | 1.000.000 |  |
| Por pagar a comercios (pasivo) |  | 1.000.000 |
| Barrido a Binance | USDT en Binance (activo) | 1.000.000 |  |
| USDT en custodia propia |  | 1.000.000 |
| Venta en Binance | COP en Binance (activo) | 995.000 |  |
| Costo de conversión (gasto) | 5.000 |  |
| USDT en Binance |  | 1.000.000 |
| Retiro de COP al banco | Bancos COP (activo) | 995.000 |  |
| COP en Binance |  | 995.000 |
| Comisión reconocida | Por pagar a comercios | 15.000 |  |
| Ingreso por comisión |  | 15.000 |
| Dispersión al comercio | Por pagar a comercios | 985.000 |  |
| Bancos COP |  | 985.000 |

Al cerrar, "Por pagar a comercios" queda en cero y el banco retiene 10.000 COP (15.000 de comisión menos 5.000 de costo). Con colchón propio, la dispersión ocurre antes del retiro y el saldo bancario baja temporalmente: esa diferencia es el capital de trabajo que se vigila. Los saldos de "USDT en Binance" y "COP en Binance" deben cerrar en cero al final del día en la conciliación; si no, hay saldo ocioso o una diferencia.

**Validar con el contador**

Tratamiento de la comisión y del deslizamiento como costo, y cómo se registran los saldos mantenidos en un exchange extranjero o en uno con presencia local, incluidos los saldos al cierre del año para efectos de patrimonio.

### Código y datos

#### Contrato del adaptador de exchange

El adaptador declara qué puede hacer por API. El núcleo se adapta: si no puede retirar pesos por API, crea una tarea manual en lugar de fallar.

```
export interface ExchangeCapabilities {
  sellViaApi: boolean;
  fiatWithdrawViaApi: boolean;   // COP en Binance: asumir false hasta confirmarlo
  quoteLock: boolean;            // cotización con precio fijo (Convert)
}

export interface ExchangeAdapter extends LiquidityAdapter {
  capabilities: ExchangeCapabilities;
  depositAddress(network: string): Promise<string>;      // dirección de la cuenta, no de la orden
  getDeposit(txHash: string): Promise<{ credited: boolean }>;
  sell(p: { usdtUnits: bigint; symbol: string; clientOrderId: string }): Promise<SellResult>;
  requestFiatWithdraw?(p: { copMinor: bigint; rail: string; ref: string }): Promise<WithdrawResult>;
  getFiatWithdrawStatus(ref: string): Promise<'pending' | 'done' | 'failed'>;
}
```

#### Avance del trabajo de conversión

```
// Cada llamada externa usa job.id como identificador propio: reintentar nunca duplica una venta.
async function advanceConversionJob(job) {
  const ex = adapters.exchange(job.projectId);
  switch (job.status) {
    case 'SWEEP_SENT': {
      const d = await ex.getDeposit(job.sweepTxHash);
      return d.credited ? save(job, 'AT_EXCHANGE') : waitOrEscalate(job);
    }
    case 'AT_EXCHANGE': {
      const fill = await ex.sell({ usdtUnits: job.usdtUnits, symbol: 'USDTCOP', clientOrderId: job.id });
      const slipBps = deviationBps(fill.rateMinor, job.quotedRateMinor);
      if (slipBps > job.config.maxSlippageBps) return save(job, 'MANUAL_REQUIRED', { reason: 'SLIPPAGE' });
      await save(job, 'SOLD', { copMinor: fill.copMinor, feeCopMinor: fill.feeMinor, effectiveRateMinor: fill.rateMinor });
      return job.config.conversionOkAt === 'SOLD' ? fireOrderEvents(job, 'conversion_ok') : null;
    }
    case 'SOLD': {
      if (!ex.capabilities.fiatWithdrawViaApi) {
        return queueManualTask(job, 'RETIRO_COP_BINANCE');   // doble aprobación
      }
      return requestWithdraw(job);
    }
    case 'FIAT_WITHDRAW_REQUESTED': {
      const s = await ex.getFiatWithdrawStatus(job.fiatWithdrawId);
      if (s === 'done' && bankCreditMatches(job)) {
        await save(job, 'FIAT_RECEIVED');
        return job.config.conversionOkAt === 'FIAT_RECEIVED' ? fireOrderEvents(job, 'conversion_ok') : null;
      }
      return s === 'failed' ? save(job, 'MANUAL_REQUIRED', { reason: 'WITHDRAW_FAILED' }) : null;
    }
  }
}

// Reparto de un lote: proporcional a los USDT de cada orden; la última absorbe el redondeo.
function allocate(job, orders) {
  let left = job.copMinor;
  return orders.map((o, i) => {
    const share = i === orders.length - 1 ? left : (job.copMinor * o.usdtUnits) / job.usdtUnits;
    left -= share;
    return { orderId: o.id, copMinorAllocated: share };
  });
}
```

#### Configuración del proyecto

Se agrega este bloque al `config.json` del proyecto. Valores de ejemplo.

```
"liquidity": {
  "provider": "binance",
  "account": "cuenta-corporativa-entidad-operadora",
  "pair": "USDTCOP",
  "method": "spot_market",
  "settlement_mode": "batched",
  "batch_every_minutes": 60,
  "max_slippage_bps": 40,
  "fiat_withdraw": { "rail": "transfiya", "mode": "manual_two_approvals" },
  "payout_funding": "prefunded_float",
  "float_min_cop": 20000000,
  "conversion_ok_at": "SOLD",
  "api_key_policy": { "withdrawals_enabled": false, "ip_allowlist": true }
}
```

Valores posibles: `method` es `spot_market` o `convert`; `settlement_mode` es `per_order` o `batched`; `payout_funding` es `prefunded_float` o `after_fiat_received`; `conversion_ok_at` es `SOLD` o `FIAT_RECEIVED`. La llave de API debe tener solo lectura y trading, con retiros desactivados y lista de IP permitidas.

#### Tablas adicionales

```
create table exchange_accounts (
  id uuid primary key default gen_random_uuid(),
  legal_entity_id uuid not null references legal_entities(id),
  provider text not null,               -- binance
  label text not null,
  api_key_ref text not null,            -- referencia al gestor de secretos
  status text not null default 'active'
);

create table conversion_jobs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id),
  exchange_account_id uuid not null references exchange_accounts(id),
  mode text not null check (mode in ('per_order','batched')),
  status text not null,
  usdt_units bigint not null,
  quoted_rate_minor bigint,
  cop_minor bigint,
  fee_cop_minor bigint,
  effective_rate_minor bigint,
  sweep_tx_hash text,
  exchange_deposit_id text,
  exchange_order_id text,
  fiat_withdraw_id text,
  bank_credit_ref text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table conversion_job_orders (
  job_id uuid not null references conversion_jobs(id),
  order_id uuid not null references orders(id),
  usdt_units bigint not null,            -- parte de la venta que corresponde a la orden
  cop_minor_allocated bigint,            -- reparto proporcional del resultado
  primary key (job_id, order_id)
);

create table manual_tasks (
  id uuid primary key default gen_random_uuid(),
  job_id uuid references conversion_jobs(id),
  kind text not null,                    -- RETIRO_COP_BINANCE, REVISION_DESLIZAMIENTO
  status text not null default 'open',   -- open, approved_1, approved_2, done, cancelled
  requested_by text not null,
  approved_by text[] not null default '{}',
  created_at timestamptz not null default now()
);
```

Al cerrar un lote se crea una fila en `conversions` por cada orden con su parte del resultado. Así la vista `v_carf_annual`, el expediente y los reportes UIAF y DIAN siguen funcionando sin cambios.

#### Qué suma al expediente de cada operación

- Hash del barrido y comprobante del depósito en Binance.
- Identificador de la orden de venta, monto ejecutado, comisión y tasa efectiva.
- Identificador del retiro de pesos y el extracto bancario donde aparece el crédito.
- Si fue por lote, el detalle del reparto a cada orden.

Estos soportes también responden la pregunta del banco sobre el origen de los pesos que recibe de un exchange.

## Modelo de datos

Esquema para PostgreSQL. Cada tabla operativa lleva `project_id`, de modo que un mismo núcleo atiende varios proyectos sin mezclar información ni saldos.

```
-- Quién responde ante UIAF y DIAN
create table legal_entities (
  id uuid primary key default gen_random_uuid(),
  legal_name text not null,
  nit text not null,
  rut_resp_67_updated_at date,       -- actualización del RUT para el reporte de criptoactivos
  uiaf_sirel_user text               -- código/usuario de SIREL
);

create table projects (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  legal_entity_id uuid not null references legal_entities(id),
  config jsonb not null,             -- ver sección de configuración
  status text not null default 'active'
);

create table merchants (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id),
  legal_name text not null,
  doc_type text not null,            -- NIT, CC, CE, PAS
  doc_number text not null,
  fiscal_residence text not null default 'CO',
  kyc_status text not null check (kyc_status in ('pending','review','approved','rejected')),
  risk_level text not null default 'medium',
  beneficial_owners jsonb,
  bank_account jsonb not null,       -- cifrado a nivel de aplicación
  unique (project_id, doc_type, doc_number)
);

create table orders (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id),
  merchant_id uuid not null references merchants(id),
  external_ref text not null,        -- referencia del proyecto
  state text not null,
  amount_cop_minor bigint not null,  -- centavos de COP
  network text not null,
  token text not null default 'USDT',
  deposit_address text not null unique,
  usdt_expected_units bigint not null,   -- 6 decimales
  usdt_received_units bigint not null default 0,
  quote_id uuid,
  expires_at timestamptz not null,
  version int not null default 0,    -- bloqueo optimista
  created_at timestamptz not null default now(),
  unique (project_id, external_ref)
);

create table order_state_history (
  id bigserial primary key,
  order_id uuid not null references orders(id),
  from_state text not null, to_state text not null,
  event text not null, actor text not null,
  at timestamptz not null default now()
);

create table onchain_txs (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id),
  network text not null,
  tx_hash text not null,
  log_index int not null default 0,
  from_address text not null,
  to_address text not null,
  amount_units bigint not null,
  confirmations int not null default 0,
  status text not null,              -- seen, confirmed, dropped
  seen_at timestamptz not null default now(),
  unique (network, tx_hash, log_index)   -- idempotencia
);

create table aml_screenings (
  id uuid primary key default gen_random_uuid(),
  onchain_tx_id uuid not null references onchain_txs(id),
  provider text not null,
  risk_score numeric,
  result text not null,              -- pass, flag, block
  raw jsonb,
  created_at timestamptz not null default now()
);

create table quotes (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id),
  rate_cop_per_usdt_minor bigint not null,
  spread_bps int not null,
  source text not null,
  locked_until timestamptz not null
);

create table conversions (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id),
  provider text not null, provider_ref text,
  usdt_units bigint not null,
  cop_minor bigint not null,
  effective_rate_minor bigint not null,
  status text not null,              -- pending, done, failed
  executed_at timestamptz
);

create table payouts (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id),
  merchant_id uuid not null references merchants(id),
  amount_cop_minor bigint not null,
  rail text not null,                -- transferencia, ACH, etc.
  bank_ref text,
  status text not null,
  settled_at timestamptz
);

-- Libro contable de doble partida
create table ledger_accounts (code text primary key, name text not null, type text not null);
create table ledger_entries (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id),
  order_id uuid references orders(id),
  event text not null,
  created_at timestamptz not null default now()
);
create table ledger_lines (
  entry_id uuid not null references ledger_entries(id),
  account_code text not null references ledger_accounts(code),
  debit_cop_minor bigint not null default 0,
  credit_cop_minor bigint not null default 0,
  native_amount bigint, currency text      -- USDT o COP
);
-- Restricción diferida: por entrada, suma de débitos = suma de créditos

-- Cumplimiento
create table compliance_events (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id),
  order_id uuid references orders(id),
  kind text not null,                -- ROS, UIAF_TX, UIAF_CLIENT, CARF_USER
  payload jsonb not null,
  report_batch_id uuid,
  reported_at timestamptz
);

-- Bitácora inmutable encadenada por hash
create table audit_log (
  id bigserial primary key,
  actor text not null, action text not null,
  entity text not null, entity_id uuid,
  prev_hash text, hash text not null,
  at timestamptz not null default now()
);

-- Base del reporte anual de criptoactivos por usuario
create view v_carf_annual as
select o.project_id, m.id as merchant_id, m.doc_type, m.doc_number, o.token,
       date_part('year', c.executed_at) as tax_year,
       count(*) as n_transactions,
       sum(c.usdt_units) / 1000000.0 as usdt_total,
       sum(c.cop_minor) / 100.0 as cop_value
from conversions c
join orders o on o.id = c.order_id
join merchants m on m.id = o.merchant_id
where c.status = 'done'
group by 1,2,3,4,5,6;
```

**Definición pendiente del contador**

La vista `v_carf_annual` usa el valor en COP de la conversión como valor de la transacción. Cómo se define el "valor razonable" para el reporte, y qué campos exactos exige el anexo técnico de la DIAN, se confirma contra el anexo vigente antes de implementar el generador de XML.

## Contabilidad de la operación

Cada evento genera asientos balanceados. Ejemplo ilustrativo: orden de 1.000.000 COP, tasa de 4.000 COP por USDT (250 USDT), comisión de plataforma de 1,5 % y costo de conversión de 5.000 COP.

| Evento | Cuenta | Débito (COP) | Crédito (COP) |
| --- | --- | --- | --- |
| Pago confirmado | USDT en custodia (activo) | 1.000.000 |  |
| Por pagar a comercios (pasivo) |  | 1.000.000 |
| Conversión ejecutada | Bancos COP (activo) | 995.000 |  |
| Costo de conversión (gasto) | 5.000 |  |
| USDT en custodia (activo) |  | 1.000.000 |
| Comisión reconocida | Por pagar a comercios | 15.000 |  |
| Ingreso por comisión |  | 15.000 |
| Dispersión al comercio | Por pagar a comercios | 985.000 |  |
| Bancos COP |  | 985.000 |

Al final, la cuenta "Por pagar a comercios" queda en cero y el banco retiene 10.000 COP: la comisión de 15.000 menos el costo de conversión de 5.000. Esa verificación se automatiza en la conciliación diaria.

**Validar con el contador**

Los códigos de cuenta del ejemplo son ilustrativos y deben mapearse al PUC. También queda por definir el tratamiento de IVA sobre la comisión, retenciones, ICA y la facturación electrónica de la comisión, y cómo se registran los USDT en custodia por cuenta de terceros.

## API y webhooks

La misma interfaz en todos los proyectos. Cada proyecto tiene su propia llave de API.

| Endpoint | Uso |
| --- | --- |
| `POST /v1/merchants` | Registra un comercio y dispara el KYB. |
| `GET /v1/merchants/{id}` | Estado del KYC, límites y nivel de riesgo. |
| `POST /v1/orders` | Crea una orden y devuelve dirección, monto en USDT y vencimiento. |
| `GET /v1/orders/{id}` | Estado actual e historial. |
| `POST /v1/orders/{id}/cancel` | Cancela una orden aún sin pago. |
| `GET /v1/settlements` | Dispersiones por comercio y periodo, con comprobantes. |

```
POST /v1/orders
Idempotency-Key: 7c1f9a52-3b8e-4d1a-9f0e-2a6b1c4d8e10
Authorization: Bearer <api_key_del_proyecto>

{
  "merchant_id": "mrc_01H...",
  "external_ref": "PEDIDO-48213",
  "amount_cop": 1000000,
  "network": "tron",
  "metadata": { "cliente": "..." }
}

201 Created
{
  "id": "ord_01H...",
  "state": "AWAITING_PAYMENT",
  "deposit_address": "T...",
  "network": "tron",
  "token": "USDT",
  "usdt_amount": "250.000000",
  "rate_cop_per_usdt": "4000.00",
  "expires_at": "2026-10-03T15:30:00Z"
}
```

### Webhooks

Eventos: `order.payment_detected`, `order.confirmed`, `order.converted`, `order.settled`, `order.expired`, `order.held`, `order.refunded`. No se revela el motivo de una retención de cumplimiento.

```
X-Signature: t=1760000000,v1=<hmac_sha256(secret, t + "." + body)>

// Receptor: verificar firma, rechazar si t tiene más de 5 minutos,
// responder 2xx rápido y procesar de forma idempotente por event_id.
// Reintentos: 1 min, 5 min, 30 min, 2 h, 12 h; luego alerta al equipo.
```

## Cumplimiento en Colombia

Dos regímenes distintos: la UIAF vigila lavado de activos y financiación del terrorismo; la DIAN recibe información tributaria sobre criptoactivos. Ambos se alimentan de los mismos datos.

### UIAF: Resolución 314 de 2021

Aplica a personas y empresas que prestan servicios de activos virtuales: intercambio entre activos virtuales y moneda fiat, entre activos virtuales, transferencias y custodia. Los reportes se envían por el sistema SIREL, para lo cual hay que darse de alta y solicitar código y usuario.

| Obligación | Frecuencia | De dónde sale el dato |
| --- | --- | --- |
| Reporte de operaciones sospechosas (ROS) | Inmediato al detectarse | `compliance_events` tipo `ROS` |
| Reporte de transacciones con activos virtuales (individuales y múltiples) | Mensual | `conversions`, `onchain_txs`, `orders` |
| Reporte de clientes (activos, inactivos, desvinculados) | Mensual | `merchants` |
| Reporte de ausencia de transacciones | Dentro de los primeros 20 días calendario del mes siguiente, cuando no hubo operaciones | Control de periodo vacío |

**Confirmar en los anexos técnicos de la UIAF**

Los umbrales vigentes para transacciones individuales y múltiples, los formatos y los plazos exactos. Además, la UIAF espera un sistema de administración del riesgo de lavado (SARLAFT) con oficial de cumplimiento, manual y capacitación, que va más allá del software.

### DIAN: Resolución 000240 de 2025 (CARF)

Los proveedores de servicios de criptoactivos deben reportar a la DIAN desde el año gravable 2026, siguiendo el Marco de Reporte de Criptoactivos de la OCDE. Se reporta información de los usuarios reportables y el tipo de criptoactivo, con valor razonable y número de transacciones.

| Obligación | Plazo | Detalle |
| --- | --- | --- |
| Actualizar el RUT (Responsabilidad 67) | Antes del primer reporte | Campo `rut_resp_67_updated_at` en `legal_entities`. |
| Reporte del año gravable 2026 | Último día hábil de mayo de 2027 | Formato XML según anexo técnico. Cada año, el último día hábil de mayo del año siguiente. |
| Reporte en cero | Mismo plazo | Si no hay usuarios reportables, igual se presenta. |
| Debida diligencia continua | Permanente | Datos del usuario: nombre, dirección, residencia, NIT o equivalente, fecha y lugar de nacimiento si es persona natural. |
| Conservación | Mínimo 5 años | Información reportada, usuarios no reportables y soportes de debida diligencia. |
| Sanciones | Por incumplimiento | Multa de hasta 7.500 UVT por no reportar a tiempo. Y una UVT por cada día de retraso en actualizar el RUT. |

### Expediente por operación

La forma de "declarar" la salida de USDT hacia el banco es poder demostrarla. Por cada dispersión, el sistema arma automáticamente un expediente que une la cadena completa:

1. KYC del comercio y soporte de beneficiario final.
2. Orden: monto, cotización y tasa bloqueada.
3. Transacción on-chain: hash, billetera de origen, confirmaciones.
4. Resultado del análisis AML de la billetera.
5. Conversión: proveedor, referencia, tasa efectiva.
6. Comprobante de la transferencia bancaria.
7. Factura electrónica de la comisión y asientos contables.

El expediente se exporta en PDF y JSON, se firma con hash y se guarda al menos cinco años. Es el documento que se entrega al banco, al auditor o a la autoridad si lo piden.

### Relación con los bancos

**Riesgo operativo real**

Los bancos pueden cerrar o limitar cuentas que reciben fondos vinculados a criptoactivos. Mitigación: una cuenta dedicada por entidad legal, conversación temprana con el oficial de cumplimiento del banco, entregarle el expediente y el manual SARLAFT, y evitar dispersar a terceros o fraccionar montos.

### Otros temas a validar con especialista

- Régimen cambiario y si la conversión o la dispersión tiene implicaciones frente al Banco de la República.
- Impuestos del lado del comercio y del lado de la plataforma: renta, IVA, retenciones, ICA, impuesto al patrimonio sobre saldos en criptoactivos.
- Regla de viaje (travel rule) y si aplica a la operación.
- Tratamiento de datos personales conforme a la Ley 1581 de 2012: autorizaciones, finalidades y transferencias a proveedores.

## Contador por proyecto

Cada proyecto que cobra en USDT tiene su propio contador: un módulo que lleva los libros del proyecto, clasifica cada ingreso según de dónde viene el pagador, prepara los borradores tributarios y regulatorios, y le entrega todo listo a un contador público, que revisa y firma.

**Por qué uno por proyecto**

Cada proyecto tiene clientes, países, tratamiento de IVA y calendario distintos. Mezclarlos en un solo libro impide cerrar el mes por proyecto y complica demostrar el origen de cada ingreso. El núcleo es el mismo; lo que cambia es la configuración contable de cada uno.

### Qué hace el contador de cada proyecto

| Función | Detalle |
| --- | --- |
| Libros propios | Asientos de doble partida separados por `project_id`, con su propio plan de cuentas mapeado al PUC. |
| Captura automática | Cada evento de la orden genera su asiento: pago confirmado, barrido, venta, retiro, comisión, dispersión, devolución. |
| Clasificación del ingreso | Por país del pagador, tipo de cliente y tratamiento de IVA (nacional, exportación exenta o gravada). |
| Valoración | Moneda funcional en COP con el valor real de la conversión, y referencia en USD con la TRM del día para análisis. |
| Conciliación | Diaria en tres vías (on-chain, libro, banco) más Binance si se usa como proveedor. |
| Cierre mensual | Bloquea el periodo, genera balance de prueba y estado de resultados del proyecto. |
| Borradores | Datos para facturas, IVA, información exógena, reportes UIAF y CARF. Nunca presenta nada por sí solo. |
| Alertas | Pagadores cerca de umbrales, ventas al exterior sin soportes, diferencias de conciliación, periodos sin cerrar. |
| Paquete para el contador público | Exportación mensual con libros, soportes, expedientes y lista de pendientes. |

### Qué cambia con ingresos de todo el mundo

Hasta ahora el diseño identificaba bien al comercio, pero el pagador era solo una billetera. Con clientes en muchos países, el pagador pasa a ser un sujeto que el contador debe conocer.

#### IVA en ventas a clientes del exterior

Los servicios prestados desde Colombia y usados exclusivamente en el exterior por empresas o personas sin negocios ni actividades en el país están exentos de IVA, siempre que el prestador esté inscrito como exportador de servicios en el RUT y conserve los soportes que prueban la exportación. Si falta un requisito, el servicio se factura con IVA aunque el cliente esté en el exterior. No hay una factura distinta para extranjeros: es la misma factura electrónica, cambiando la identificación del comprador y el tratamiento del impuesto. Para software dirigido al mercado internacional, la norma lo considera exportación aunque se pueda acceder a él desde Colombia.

#### Identificación del pagador (CARF)

El Marco de Reporte de Criptoactivos incluye los pagos minoristas: transferencias de criptoactivos para comprar bienes o servicios por encima de USD 50.000, caso en el que hay que identificar al cliente del comercio. El umbral no exime los pagos menores: debajo de él, el pago se sigue reportando como una transferencia corriente. Las fuentes no coinciden en si el umbral se mide por operación o acumulado anual por cliente, así que el diseño acumula por pagador y por año, que cubre ambas lecturas.

Por eso el contador captura datos del pagador en dos niveles: siempre billetera, país declarado y país detectado; y datos completos (nombre, dirección, residencia fiscal, número de identificación tributaria y, si es persona, fecha y lugar de nacimiento) cuando el acumulado se acerca al umbral o cumplimiento lo pide.

#### Jurisdicciones y sanciones

Con pagadores globales aparece el riesgo geográfico: pagos desde países sancionados se bloquean antes de crear la orden, y los de jurisdicciones de alto riesgo pasan por debida diligencia reforzada. Las listas usadas y su fecha quedan registradas en el expediente.

**Validar con el contador público y un especialista cambiario**

El tratamiento de ingresos del exterior pagados en USDT frente al régimen cambiario (los mecanismos de reintegro están pensados para divisas, no para criptoactivos), la renta del proyecto por ventas al exterior, la diferencia en cambio si se mantienen USDT, y cómo adopta la DIAN el umbral de pagos minoristas. Para bienes físicos exportados aplica además el régimen aduanero.

### Clasificador de ingresos

Prueba cómo el contador clasifica una venta. Es la misma función que corre en el sistema; su resultado es una orientación para el contador público, no una conclusión tributaria.

Residencia del pagador
ExteriorColombia
¿Tiene negocios o actividades en Colombia?
NoSí
¿El servicio se usa exclusivamente en el exterior?
SíNo
¿El proyecto está inscrito como exportador en el RUT?
SíNo
¿Hay soportes de la exportación?
SíNo
Jurisdicción del pagador
Sin alertasAlto riesgoSancionada
Acumulado anual del pagador (USD)

### Panel del contador de cada proyecto

| Indicador | Para qué sirve |
| --- | --- |
| Ingresos por país del pagador | Ver de dónde viene el dinero y detectar concentraciones o países nuevos. |
| Ingresos por tratamiento de IVA | Separar nacional, exportación exenta y exterior gravado; vigilar exportaciones sin soportes. |
| Pagadores cerca del umbral CARF | Pedir los datos completos antes de que el acumulado lo cruce. |
| Estado de conciliación | Diferencias abiertas entre cadena, libro, Binance y banco. |
| Costo de conversión | Comisión y deslizamiento acumulados contra lo presupuestado en el spread. |
| Calendario | Cierre mensual, IVA, UIAF y CARF con su estado. |

### Ciclo del contador

| Cuándo | Qué hace el sistema | Qué hace el contador público |
| --- | --- | --- |
| Diario | Asientos automáticos, conciliación, clasificación de ventas, alertas. | Revisa alertas abiertas. |
| Semanal | Lista de pagadores cerca del umbral y ventas al exterior sin soportes. | Decide qué datos o soportes pedir. |
| Mensual | Cierre del periodo, balance de prueba, paquete del mes, borrador UIAF. | Revisa, ajusta y aprueba el cierre. |
| Por periodo de IVA | Borrador con ventas nacionales, exentas y gravadas al exterior. | Presenta la declaración. |
| Anual | Base CARF, información exógena, saldos al cierre para patrimonio. | Presenta renta, exógena y reportes; firma estados financieros. |

### Datos y configuración

#### Tablas nuevas

```
create table payers (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id),
  kind text not null default 'unknown',       -- person, company, unknown
  legal_name text,
  declared_country char(2),
  detected_country char(2),                   -- geolocalización al momento del pago
  tax_residence char(2),
  tin text,                                    -- identificación tributaria de su país
  birth_date date,
  birth_place text,
  address text,
  has_business_in_co boolean,
  kyc_level text not null default 'minimal',  -- minimal, standard, enhanced
  risk_level text not null default 'medium',
  created_at timestamptz not null default now()
);

create table payer_wallets (
  payer_id uuid not null references payers(id),
  network text not null,
  address text not null,
  primary key (payer_id, network, address)
);

alter table orders add column payer_id uuid references payers(id);

create table sales_documents (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references projects(id),
  order_id uuid not null references orders(id),
  payer_id uuid references payers(id),
  doc_type text not null,                -- factura_electronica, nota_credito
  number text,
  cufe text,
  iva_treatment text not null,           -- gravado, exento_exportacion, excluido
  iva_minor bigint not null default 0,
  export_evidence jsonb,                 -- contrato y prueba de uso en el exterior
  value_cop_minor bigint not null,
  value_usd_ref_minor bigint,            -- referencia con la TRM del día
  issued_at timestamptz
);

create table fx_rates (
  day date not null,
  pair text not null,                    -- USDCOP (TRM), USDTCOP (ejecución)
  rate numeric(18,6) not null,
  source text not null,
  primary key (day, pair, source)
);

create table accounting_periods (
  project_id uuid not null references projects(id),
  period char(7) not null,               -- 2026-10
  status text not null default 'open',   -- open, review, closed
  closed_by text,
  closed_at timestamptz,
  primary key (project_id, period)
);

-- Acumulado por pagador y año: base para el umbral de pagos minoristas
create view v_payer_annual as
select o.project_id, o.payer_id,
       date_part('year', c.executed_at) as year,
       count(*) as n_payments,
       sum(c.usdt_units) / 1000000.0 as usdt_total,   -- USDT como aproximación al USD
       sum(c.cop_minor) / 100.0 as cop_total
from conversions c
join orders o on o.id = c.order_id
where c.status = 'done' and o.payer_id is not null
group by 1, 2, 3;
```

#### Bloque de configuración del proyecto

```
"accounting": {
  "functional_currency": "COP",
  "reference_currency": "USD",
  "chart_of_accounts": "puc-mapeo-proyecto",
  "iva_responsible": true,
  "rut_service_exporter": true,
  "default_sale_type": "servicios_digitales",
  "carf_retail_threshold_usd": 50000,
  "carf_warn_ratio": 0.8,
  "blocked_jurisdictions_list": "lista-sanciones-vigente",
  "high_risk_jurisdictions_list": "lista-alto-riesgo-vigente",
  "period_close_day": 5,
  "public_accountant": { "name": "por-asignar", "email": "por-asignar" }
}
```

### El contador como agente

El módulo puede correr como un agente por proyecto con herramientas acotadas. Su trabajo es preparar y alertar; las decisiones tributarias y las firmas siguen siendo humanas.

| Puede hacer | No hace |
| --- | --- |
| Leer libros, órdenes, pagadores y conciliaciones del proyecto. | Leer datos de otros proyectos. |
| Clasificar ventas y proponer el tratamiento de IVA. | Presentar declaraciones o reportes ante la DIAN o la UIAF. |
| Pedir al pagador los datos que faltan, con plantilla aprobada. | Cambiar el tratamiento tributario sin aprobación del contador público. |
| Abrir casos de conciliación y de cumplimiento. | Liberar fondos retenidos o decidir sobre un ROS. |
| Armar el paquete mensual y los borradores. | Reabrir un periodo cerrado. |

En el plugin de Claude Code esto se agrega como el skill `contador-proyecto`, con un hook que impide asientos en periodos cerrados y otro que exige `project_id` en toda consulta del agente.

## Qué se declara y cómo

Supuesto de trabajo: el USDT se convierte a pesos apenas llega y termina en el banco. Esto simplifica mucho: casi no hay saldo en cripto al cierre del año, la diferencia por variación de precio es mínima y cada ingreso queda soportado en pesos.

**Primero: ¿el proyecto cobra para sí mismo o para otros?**

Si cada proyecto recibe USDT como pago de sus propias ventas y lo convierte en Binance a nombre propio (modelo C), el proyecto es usuario de un proveedor, no proveedor. Sus obligaciones son las de cualquier empresa que vende: factura, IVA, renta, patrimonio y exógena. Si una sola entidad cobra para varios proyectos o empresas distintas, esa entidad presta el servicio y suma las obligaciones de proveedor ante la UIAF y la DIAN. La lista de abajo marca cuál aplica en cada caso.

### Lista de lo que se declara

| Obligación | Quién | Cuándo | Qué incluye | Dato en el sistema |
| --- | --- | --- | --- | --- |
| Factura electrónica | Proyecto vendedor | En cada venta | Precio en COP, comprador identificado (incluido el extranjero) y tratamiento de IVA. | `sales_documents` |
| Declaración de IVA | Proyecto, si es responsable | Cada periodo de IVA | Ventas nacionales gravadas, exportaciones de servicios exentas y ventas al exterior gravadas por no cumplir requisitos. | `sales_documents` |
| Declaración de renta | Proyecto | Anual | Ingresos por ventas en COP, costo de conversión y comisiones como gasto con soporte, y cualquier diferencia por haber mantenido USDT. | `ledger_lines` |
| Patrimonio en la renta | Proyecto | Saldo al 31 de diciembre | USDT o pesos que queden en Binance o en billeteras al cierre. Con conversión inmediata debería ser cercano a cero. | Saldos del libro |
| Información exógena | Proyecto, si está obligado | Anual | Terceros con los que operó, incluidos clientes del exterior. | `payers`, `sales_documents` |
| Soporte de costos con proveedores del exterior | Proyecto | Por cada costo | Comisiones de Binance y otros proveedores que no facturan en Colombia (validar si aplica documento soporte). | `conversion_jobs` |
| RUT actualizado | Proyecto | Al iniciar o cambiar | Actividad económica, responsabilidad de IVA y exportador de servicios si vende al exterior. | `legal_entities` |
| Reportes UIAF | Solo si presta servicios de activos virtuales | Mensual e inmediato (ROS) | Transacciones, clientes, ausencia y operaciones sospechosas. | `compliance_events` |
| Reporte CARF a la DIAN | Solo si es proveedor de servicios de criptoactivos | Anual, último día hábil de mayo | Usuarios reportables, operaciones y pagos minoristas. | `v_carf_annual`, `v_payer_annual` |
| Activos en el exterior | Proyecto (validar) | Anual | Si los saldos en un exchange extranjero cuentan como activos en el exterior al 1 de enero. | Saldos del libro |
| Régimen cambiario | Proyecto (validar) | Por operación | Si un ingreso del exterior pagado en USDT requiere algún registro o canalización. | Expediente |

### Preguntas frecuentes

Respuestas de orientación basadas en la doctrina pública de la DIAN y en el diseño de esta pasarela. Cada proyecto las confirma con su contador público.

Si alguien de otro país paga en USDT, ¿cómo se declara?

Ejemplo: un cliente en España paga 250 USDT por un servicio de 1.000.000 COP. El proyecto convierte de inmediato en Binance y recibe 995.000 COP en el banco.

1. **Identificar al pagador.** País declarado y detectado, billetera y, según el monto acumulado, datos completos.
2. **Facturar en pesos.** Factura electrónica por 1.000.000 COP a nombre del cliente extranjero. Es la misma factura de siempre, con la identificación del comprador del exterior.
3. **Definir el IVA.** Exenta si es exportación de servicios y se cumplen los requisitos; gravada si falta alguno.
4. **Registrar el ingreso.** Ingreso por venta de 1.000.000 COP. El USDT recibido entra como activo por los minutos que dura en la billetera.
5. **Registrar la conversión.** Entran 995.000 COP y salen los USDT. Los 5.000 COP de diferencia son costo de conversión.
6. **Retiro al banco.** Es un traslado entre cuentas propias: no genera ingreso nuevo.
7. **Al año.** El ingreso va a la renta del proyecto como ingreso ordinario, la venta va en la declaración de IVA del periodo, y el cliente aparece en exógena si el proyecto está obligado.

| Momento | Débito | Crédito |
| --- | --- | --- |
| Cobro | USDT (activo) 1.000.000 | Ingreso por venta 1.000.000 |
| Conversión | COP en Binance 995.000 y costo de conversión 5.000 | USDT 1.000.000 |
| Retiro | Bancos 995.000 | COP en Binance 995.000 |

¿El ingreso es lo que dice la factura o lo que llega al banco?

Lo que dice la factura: el precio pactado en pesos. Lo que llega al banco puede ser algo menos por la comisión del exchange y el movimiento del precio; esa diferencia se registra aparte como costo de conversión, con el extracto de Binance como soporte. Así el ingreso coincide con la factura y el costo queda visible.

¿Hay que pagar ganancia ocasional por el USDT?

En este modelo, normalmente no. La DIAN trata como ganancia ocasional la venta de un criptoactivo poseído como activo fijo por más de dos años; si se tuvo menos tiempo, el resultado es renta ordinaria. Como el USDT se vende minutos después de recibirlo, cualquier diferencia es ordinaria y queda dentro de la renta del proyecto.

¿La venta del USDT en Binance tiene IVA?

No. La DIAN ha dicho que la venta de criptoactivos no está gravada con IVA, por ser un activo intangible no relacionado con la propiedad industrial. El IVA que importa es el de la venta del bien o servicio al cliente, no el de cambiar el USDT a pesos.

¿Hay que declarar el USDT como patrimonio?

Solo lo que se tenga al 31 de diciembre. Los residentes que tengan criptoactivos deben incluirlos en el patrimonio de su declaración de renta. Con conversión inmediata, el saldo al cierre debería ser cero o muy pequeño (pagos en tránsito). El contador toma el saldo exacto del libro a esa fecha.

¿Hay que reintegrar divisas o llenar un formulario cambiario?

No está resuelto de forma clara. Los mecanismos de canalización están diseñados para divisas, y el pago llega en USDT, que no es una divisa. Pero que un servicio exportado se pague en cripto y se convierta en un exchange es justo el tipo de caso que un especialista cambiario debe revisar antes de operar a escala. Mientras tanto, el expediente de cada operación guarda toda la trazabilidad por si se requiere.

¿Tengo que identificar a cada pagador extranjero?

Siempre se guardan billetera, país declarado y país detectado, porque se necesitan para la factura, la exógena y el control de sanciones. Los datos completos se piden cuando el acumulado del pagador se acerca a USD 50.000, cuando la jurisdicción es de alto riesgo o cuando cumplimiento lo pide. Si el proyecto es proveedor (no cobro propio), el umbral de pagos minoristas del CARF también aplica.

¿Qué pasa si el precio cambia entre el pago y la conversión?

La diferencia es ganancia o pérdida ordinaria. Por eso la regla es convertir apenas el depósito se acredite y pausar si la tasa se aleja más del umbral configurado. El sistema guarda la tasa de la cotización y la tasa de ejecución para que el contador vea cada diferencia.

¿Cómo se declara una devolución a un cliente del exterior?

Con una nota crédito que anula total o parcialmente la factura. Si la devolución se hace en USDT, el proyecto compra USDT con pesos y lo envía: esa compra es otra operación con criptoactivos que queda en el libro y en el expediente.

¿Qué reporta Binance y qué reporto yo?

Binance, como plataforma, tiene sus propias obligaciones de reporte según su situación en cada país. El proyecto no se apoya en ese reporte: declara su factura, IVA, renta, patrimonio y exógena con sus propios datos. Si la DIAN recibe información de Binance sobre las ventas de USDT del proyecto, las cifras deben cuadrar con las del libro; la conciliación diaria está pensada para eso.

**Alcance**

Estas respuestas resumen doctrina pública de la DIAN y la lógica del sistema. No reemplazan el concepto del contador público y del abogado de cada proyecto, sobre todo en tratamiento cambiario, exportación de servicios y condición de proveedor.

## Seguridad y protección de datos

| Área | Práctica |
| --- | --- |
| Custodia | Direcciones derivadas por orden desde una clave extendida pública del proyecto. Las claves privadas viven en un custodio o módulo de seguridad, nunca en el servidor de la aplicación. Barrido periódico a billetera fría. |
| Separación de fondos | Billeteras y cuentas bancarias separadas por entidad legal, y saldos separados por proyecto en el libro contable. |
| Accesos | Roles mínimos: operaciones, cumplimiento, finanzas, ingeniería. Cambios de configuración y aprobación de retiros con doble aprobación. |
| Secretos | Gestor de secretos, rotación periódica, llaves de API por proyecto con permisos limitados. |
| Auditoría | Bitácora inmutable encadenada por hash. Toda decisión manual de cumplimiento queda con autor y motivo. |
| Datos personales | Cifrado en tránsito y en reposo; datos bancarios y documentos cifrados a nivel de aplicación; acceso registrado. |
| Resiliencia | Respaldos probados, plan de recuperación, límites de velocidad y alertas por comportamiento anómalo. |

## Operación diaria y calendario

### Rutina diaria

- Conciliación en tres vías: on-chain, libro contable y banco.
- Revisión de órdenes en `HELD_COMPLIANCE`, `UNDERPAID`, `FAILED_CONVERSION` y `FAILED_PAYOUT`.
- Pagos recibidos sin orden (cuarentena) y devoluciones pendientes.
- Alertas: diferencia de saldos, tasa fuera de rango, caída del proveedor, cola de webhooks atascada.

### Calendario de cumplimiento

| Cuándo | Qué |
| --- | --- |
| Inmediato | ROS ante la UIAF por operaciones sospechosas. |
| Mensual | Reporte UIAF de transacciones y de clientes; reporte de ausencia si no hubo operaciones (primeros 20 días del mes siguiente). |
| Antes del primer reporte DIAN | Actualizar RUT con la responsabilidad de criptoactivos. |
| Anual | Reporte DIAN de criptoactivos, último día hábil de mayo del año siguiente (el del año gravable 2026 vence en mayo de 2027). |
| Permanente | Conservación de información y soportes por mínimo 5 años. |

## Estándar multi-proyecto

Cómo usar la misma pasarela en varios proyectos sin copiar código ni mezclar fondos.

### Modelo de despliegue

Un solo núcleo multi-tenant, con aislamiento lógico por `project_id`, llaves de API por proyecto, billeteras y cuentas por entidad legal, y libro contable separado por proyecto. Si un cliente exige aislamiento total, el mismo código se despliega en una instancia dedicada con su propia base de datos.

### Configuración por proyecto

Todo lo que cambia entre proyectos vive en un archivo. Valores de ejemplo.

```
{
  "project": "proyecto-ejemplo",
  "legal_entity": "entidad-operadora",
  "networks": [
    { "name": "tron",    "token": "USDT", "min_confirmations": 20 },
    { "name": "polygon", "token": "USDT", "min_confirmations": 30 }
  ],
  "quote": { "ttl_seconds": 900, "spread_bps": 80 },
  "tolerance": { "under_bps": 30, "over_bps": 100 },
  "underpaid_grace_minutes": 30,
  "overpay_policy": "refund",
  "late_payment_policy": "refund",
  "fees": { "platform_bps": 150, "min_fee_cop": 2000 },
  "review": { "over_usd": 3000, "max_risk_score": 60 },
  "payout": { "rail": "bank_transfer", "schedule": "immediate", "min_cop": 20000 },
  "retry": { "max_attempts": 5 },
  "webhooks": { "url": "https://proyecto.example/hooks/usdt", "secret_ref": "kms://..." },
  "reports": { "uiaf": true, "dian_carf": true }
}
```

### Contratos de adaptadores

El núcleo solo conoce estas interfaces. Cambiar de red, banco o proveedor es escribir un adaptador nuevo, no tocar la lógica.

```
export interface ChainAdapter {
  network: string;
  newDepositAddress(orderId: string): Promise<string>;
  subscribe(address: string, cb: (tx: ObservedTx) => void): void;
  getConfirmations(txHash: string): Promise<number>;
}
export interface ScreeningAdapter {
  screen(tx: ObservedTx): Promise<{ score: number; flags: string[]; result: 'pass'|'flag'|'block' }>;
}
export interface LiquidityAdapter {
  quote(usdtUnits: bigint): Promise<Quote>;
  execute(q: Quote): Promise<Conversion>;
}
export interface PayoutAdapter {
  send(p: PayoutRequest): Promise<PayoutResult>;   // idempotente por p.reference
}
export interface KycAdapter {
  verify(m: MerchantInput): Promise<KycResult>;
}
export interface ReportAdapter {
  build(period: Period): Promise<ReportFile>;      // uiaf-sirel, dian-carf-xml, expediente-pdf
}
```

### Empaquetado como plugin

Para que cualquier proyecto nuevo arranque con la misma estructura, el estándar se distribuye como paquete y como plugin de Claude Code.

| Pieza | Contenido |
| --- | --- |
| `usdt-gateway-core` | Estados, libro contable, cotizaciones, reglas, reportes, esquema SQL. |
| `adapters/*` | Uno por red, proveedor de liquidez, banco, KYC y analítica. |
| `compliance/*` | Generadores de reportes UIAF y DIAN, expediente de operación. |
| `projects/<nombre>/config.json` | La configuración de cada proyecto. |
| Skills del plugin | `onboard-project` (crea el proyecto y su config), `add-network`, `reconcile-daily`, `build-uiaf-report`, `build-carf-report`, `operation-file`. |
| Hooks del plugin | Bloquear cambios a la tabla de transiciones sin pruebas, y verificar que toda migración conserve `project_id` y la bitácora. |

## Checklist para sumar un proyecto nuevo

1. Definir la entidad legal responsable y el modelo (proveedor directo u orquestador).
2. Confirmar registro en SIREL, SARLAFT vigente y RUT con la responsabilidad de criptoactivos.
3. Abrir cuenta bancaria dedicada y presentar el manual de cumplimiento al banco.
4. Crear el proyecto y su `config.json`; definir redes, comisiones y umbrales.
5. Generar billeteras o claves extendidas propias del proyecto y registrarlas en el custodio.
6. Configurar webhooks y llave de API; probar la firma.
7. Cargar el KYB de los primeros comercios y aprobarlos.
8. Ejecutar el ciclo completo en pruebas: pago exacto, pago de menos, pago de más, pago tardío, billetera marcada, falla de conversión y de dispersión.
9. Revisar el expediente de una operación de prueba con el contador y el oficial de cumplimiento.
10. Activar la conciliación diaria y el calendario de reportes.
11. Salir con montos bajos durante una semana antes de subir límites.

## Fases de construcción

| Fase | Entrega |
| --- | --- |
| Base | Modelo de datos, máquina de estados con pruebas, libro contable, bitácora, API de órdenes. |
| Cadena | Adaptador de una red (por ejemplo TRON), detector con idempotencia y reorganizaciones, análisis AML. |
| Dinero | Cotizaciones, conversión con un proveedor, dispersión bancaria, conciliación en tres vías. |
| Cumplimiento | KYB, casos en revisión, ROS, reportes UIAF, expediente de operación. |
| DIAN | Vista anual, generador del XML según anexo técnico, calendario y alertas. |
| Estándar | Extraer configuración y adaptadores, empaquetar el plugin y migrar el segundo proyecto como prueba de reutilización. |

## Decisiones y validaciones pendientes

**Antes de construir**

1. Modelo legal (proveedor directo u orquestador) y qué entidad responde en cada proyecto.
2. Proveedor de custodia, de liquidez y de analítica on-chain.
3. Banco para la dispersión y su postura frente a flujos de criptoactivos.
4. Tratamiento contable y tributario: PUC, IVA, retenciones, ICA, facturación electrónica, patrimonio.
5. Aplicabilidad del régimen cambiario y de la regla de viaje.
6. Anexos técnicos vigentes de UIAF y DIAN: formatos, umbrales y definición de valor razonable.
7. Si cada proyecto cobra para sí mismo (modelo C, usuario de Binance) o una entidad cobra para varios (proveedor), porque cambia la lista de declaraciones.
8. Contador público asignado a cada proyecto o entidad, y tratamiento de IVA de cada tipo de venta al exterior (requisitos de exportación de servicios y soportes).
9. Ingresos del exterior pagados en USDT: implicaciones cambiarias, renta y diferencia en cambio; y si la DIAN mide el umbral de pagos minoristas por operación o acumulado anual.
10. Binance: aprobación del KYB de la entidad operadora, disponibilidad del par USDT/COP y límites, si el retiro de COP se puede automatizar por API, rieles vigentes (Transfiya, Bre-B, ACH) y su estado de registro frente a la UIAF.

Este documento es una guía técnica y de diseño, no constituye asesoría legal, tributaria ni contable. La información regulatoria citada corresponde a la Resolución 314 de 2021 de la UIAF y a la Resolución 000240 de 2025 de la DIAN, según fuentes públicas consultadas; debe contrastarse con el texto oficial y los anexos técnicos vigentes con un especialista antes de operar. Las condiciones de Binance (rieles, comisiones, API, límites) se tomaron de documentación y guías públicas y cambian con frecuencia: confírmalas con Binance antes de implementar.

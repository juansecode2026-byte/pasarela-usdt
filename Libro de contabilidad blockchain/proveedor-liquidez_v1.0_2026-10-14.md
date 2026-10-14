# Ruta Proveedor de Liquidez

> Versión en Markdown de `proveedor-liquidez_v1.0_2026-10-14.html`, generada con `scripts/sincronizar-md.py`. No editar a mano: se regenera desde el HTML. El HTML tiene las partes interactivas.

Guía operativa · Pasarela de pagos USDT / Minus

# Cómo convertirse en proveedor de liquidez institucional en Colombia

Ruta paso a paso para cotizar y liquidar cripto ↔ COP/USD a clientes empresariales (exchanges, pasarelas, fintechs, corporativos), con las obligaciones ante DIAN, UIAF, Supersociedades y el régimen cambiario.

Versión
:   v1.0

Fecha
:   14 oct 2026

Estado
:   Borrador para validar

Jurisdicción
:   Colombia

**Validar antes de ejecutar.**

Este documento organiza la normativa pública vigente a la fecha. No reemplaza la opinión de un abogado financiero ni de un contador tributario. Los puntos marcados como *validar* dependen de tu estructura concreta.

01 · Contexto

## Marco regulatorio actual

En Colombia no existe hoy una licencia específica para operar con cripto. El proyecto de ley que regula a los Proveedores de Servicios de Activos Virtuales (PL 510 de 2025 Cámara) sigue en trámite, y el Gobierno ha anunciado un texto propio. Eso no significa que no haya reglas: cuatro frentes ya te obligan.

| Entidad | Norma | Qué te exige | Aplica a un LP |
| --- | --- | --- | --- |
| UIAF | Resolución 314 de 2021 | Reporte mensual de clientes y de transacciones, y Reporte de Operaciones Sospechosas (ROS). | Sí. Cubre intercambio cripto ↔ fiat, cripto ↔ cripto, transferencias y custodia. |
| DIAN | Resolución 000240 de 2025 (CARF) | Reporte anual de usuarios y transacciones en XML. Responsabilidad 67 en el RUT. | Sí. La definición incluye a quien actúa como contraparte o intermediario. |
| Supersociedades | Capítulo X, Circular Básica Jurídica (SAGRILAFT) | Sistema de gestión de riesgo LA/FT, oficial de cumplimiento y debida diligencia intensificada. | Sí, el sector activos virtuales está listado, al superar el umbral sectorial (*validar cifras vigentes*). |
| Banco de la República | Resolución Externa 1 de 2018 y DCIN-83 | Cripto no es divisa. Los USD que entren o salgan sí siguen el régimen cambiario. | Sí, en la pata fiat en dólares. |

**Consecuencia práctica**

Como no hay licencia que mostrar, tu credibilidad ante bancos y contrapartes se construye con cumplimiento demostrable: SAGRILAFT implementado, reportes UIAF al día, RUT con CARF y estados financieros auditables.

02 · Modelo

## Qué es un proveedor de liquidez institucional y cómo gana dinero

Eres la contraparte que siempre tiene precio de compra y de venta. Un cliente institucional te pide cotización (RFQ), tú le das un precio firme por unos segundos, él acepta y ambos liquidan. Ganas el spread entre tu precio y el costo de reponer inventario con tus propios proveedores aguas arriba.

Cliente (pasarela, exchange, empresa)
│ 1. RFQ: "compro 50.000 USDT contra COP"
▼
Tú (LP) ── 2. Cotización firme, válida 10–30 s
│ 3. Acepta → orden ejecutada
│ 4. Liquidación: él envía COP → tú envías USDT (o al revés)
▼
Reposición ── 5. Recompras inventario en Binance OTC / segundo proveedor
│ 6. Conciliación y registro para UIAF / DIAN

### Como principal

Compras y vendes con tu propio balance. Mayor margen, pero cargas riesgo de precio e inventario y necesitas capital. Es el modelo típico de un LP.

### Como agente

Ejecutas por cuenta del cliente y cobras comisión. Menos capital y riesgo, pero el ingreso es un servicio de intermediación gravado con IVA.

La decisión entre principal y agente cambia el tratamiento de IVA, el capital requerido y los contratos. Defínela en la fase 0, con el contador.

03 · Ruta

## Ruta en 8 fases

Las fases van en orden porque cada una desbloquea la siguiente. Las etiquetas indican prioridad: P0 bloqueante P1 antes de lanzar P2 primeros meses

0

### Definir el modelo de negocio

P01–2 semanasSocios + abogado + contador

- Principal o agente (ver sección anterior).
- Activos: empezar con USDT y USDC contra COP; BTC/ETH después.
- Clientes objetivo: solo personas jurídicas (KYB). Excluir retail al inicio reduce mucho el riesgo AML.
- Tamaño de ticket mínimo y volumen mensual esperado. Los bancos te lo van a preguntar.
- Modelo de liquidación: prefondeado (el cliente paga primero) o contra entrega. Empieza con prefondeado.

1

### Constituir la sociedad

P02–4 semanasCámara de Comercio

- SAS separada de Minus. No mezcles el riesgo cripto con la agencia.
- Objeto social que mencione expresamente servicios de activos virtuales: intercambio, transferencia y custodia.
- Registro de beneficiarios finales y composición accionaria clara. Los bancos lo revisan primero.
- Revisor fiscal y contador con experiencia en cripto, aunque por tamaño no sea obligatorio aún.

2

### Inscripción y obligaciones ante la DIAN

P01–2 semanasContador

Detalle completo en la sección [Todo lo de la DIAN](#dian). En resumen: RUT con actividad económica correcta y responsabilidad 67 (CARF), firma electrónica, habilitación de facturación electrónica y política de IVA definida.

3

### Montar el sistema de cumplimiento (SAGRILAFT)

P04–8 semanasOficial de cumplimiento

- Nombrar oficial de cumplimiento con idoneidad acreditada.
- Manual SAGRILAFT aprobado por la asamblea: matriz de riesgo, segmentación, señales de alerta, procedimiento ROS.
- Debida diligencia intensificada para todas las contrapartes (lo exige el Capítulo X al sector activos virtuales).
- Onboarding KYB: cámara de comercio, RUT, beneficiarios finales, estados financieros, origen de fondos, listas restrictivas y PEP.
- Herramienta de análisis on-chain para revisar wallets de entrada y salida (Chainalysis, Elliptic, TRM o similar).
- Política de Travel Rule para transferencias entre proveedores.
- Inscripción como reportante ante la UIAF en SIREL y prueba de los formatos de reporte.

Implementa SAGRILAFT aunque todavía no superes el umbral. Es lo primero que pide un banco y lo que reemplaza la licencia que no existe.

4

### Banca y régimen cambiario

P04–12 semanasGerencia + oficial de cumplimiento

- Dossier bancario: certificado de existencia, RUT, manual SAGRILAFT, organigrama, perfil de clientes, volúmenes esperados y flujo de fondos.
- Una cuenta operativa principal para COP. Una segunda cuenta en otro banco antes de los 6 meses.
- Cuentas separadas para fondos de clientes y fondos propios, desde el primer día.
- Pata USD: cripto no es divisa para el Banco de la República, pero los dólares que muevas sí lo son. Canaliza por un intermediario del mercado cambiario o cuenta de compensación, y declara el numeral cambiario que corresponda (*validar con asesor cambiario*).

5

### Liquidez aguas arriba y tesorería

P13–6 semanasTesorería

- Proveedor principal: cuenta institucional en Binance OTC (onboarding KYB propio).
- Segundo proveedor con contrato escrito: otra mesa OTC o market maker. Asegura spreads, límites y tiempos de liquidación.
- Capital de trabajo: inventario en COP y en USDT suficiente para el volumen de 1 a 2 días por lado (criterio inicial, ajustar con datos).
- Límites de riesgo escritos: exposición máxima abierta, pérdida diaria máxima y tamaño máximo por operación.
- Custodia: wallets institucionales con multifirma o MPC. Nunca una sola persona con acceso a las llaves.
- Conciliación diaria: banco, wallets, cuentas en exchanges y libro interno deben cuadrar.

6

### Contratos con clientes

P12–4 semanasAbogado

- Acuerdo marco de negociación OTC: cómo se cotiza, cuándo una operación queda cerrada, plazos de liquidación, incumplimiento y errores de precio.
- Anexo de cumplimiento: obligación del cliente de entregar información KYB y aceptar monitoreo de wallets.
- Política de tarifas y spreads por escrito.
- Términos sobre redes soportadas (por ejemplo TRC-20, ERC-20) y responsabilidad por envíos a direcciones erradas.

7

### Tecnología operativa

P14–8 semanasEquipo técnico

- Motor de cotización: toma precio de referencia de tus proveedores y aplica spread y límites.
- Canal RFQ: API para clientes técnicos y canal manual (chat registrado) para los demás.
- Libro de operaciones inmutable: cada cotización, aceptación y liquidación con marca de tiempo.
- Exportadores de reportes en los formatos de UIAF (texto plano) y DIAN CARF (XML).
- Monitoreo transaccional con alertas automáticas hacia el oficial de cumplimiento.

8

### Lanzamiento controlado y operación continua

P2PermanenteTodos

- Piloto con 2 o 3 clientes conocidos y límites bajos durante el primer mes.
- Reportes UIAF mensuales desde el primer mes, incluso si no hay operaciones (reporte de ausencia).
- Revisión mensual de la matriz de riesgo y de los límites de tesorería.
- Seguimiento del proyecto de ley PSAV: si se aprueba, habrá registro y requisitos nuevos.

04 · DIAN

## Todo lo que necesitas de la DIAN

| Trámite u obligación | Qué es | Cuándo |
| --- | --- | --- |
| RUT de la sociedad | Inscripción con la actividad económica (código CIIU) que describa intercambio de activos virtuales. Defínela con el contador; usualmente se evalúan códigos de servicios financieros auxiliares. | Al constituir |
| Responsabilidad 67 en el RUT | "Intercambio Automático de Información CARF". Te identifica como proveedor de servicios de criptoactivos sujeto a reporte. | Antes de operar |
| Firma electrónica | Necesaria para presentar el reporte CARF y demás declaraciones en línea. | Antes de operar |
| Facturación electrónica | Habilitación como facturador. Debes facturar los servicios que prestes. | Antes de la primera venta |
| IVA | La venta de criptoactivos no está gravada. La intermediación en compra y venta sí lo está. Si cobras comisión explícita, o si tu operación se califica como servicio, hay IVA. Define el tratamiento del spread con el contador. | Desde la fase 0 |
| Reporte CARF | Reporte anual en XML con datos de usuarios reportables (nombre, dirección, residencia fiscal, NIT) y sus transacciones: tipo de activo, unidades, valor de mercado. Incluye a quienes ejercen control sobre clientes empresa. | Año gravable 2026 → último día hábil de mayo 2027 |
| Debida diligencia CARF | Procedimientos alineados con el estándar de beneficiario final. Conservar soportes 5 años y corregir inconsistencias dentro de 30 días si la DIAN lo pide. | Permanente |
| Información exógena | Reporte del valor patrimonial de criptoactivos a 31 de diciembre (formato 1012, concepto 1206), más los formatos generales que te correspondan. | Anual, según calendario DIAN |
| Renta | Para efectos tributarios los criptoactivos son intangibles. Si son inventario de tu negocio, la utilidad es ingreso ordinario. La valorización no realizada no es ingreso gravable hasta que vendes. | Anual |
| Retenciones y GMF | Aplicación de retención en la fuente según el tipo de operación y del 4×1000 en los movimientos bancarios. Ver exención de una cuenta y costo del GMF en tu margen. | Mensual |
| Exógena cambiaria | Si canalizas USD, la DIAN fiscaliza el régimen cambiario y las declaraciones de cambio. | Según operación |

**Ojo con el margen**

Un spread de 0,3 % puede desaparecer entre GMF, IVA mal calculado y costos bancarios. Modela los impuestos dentro del precio desde la primera cotización.

05 · Operación

## Calendario de reportes

| Reporte | Destino | Frecuencia | Plazo |
| --- | --- | --- | --- |
| Transacciones con activos virtuales | UIAF | Mensual | Primeros 20 días calendario del mes siguiente (también si no hubo operaciones) |
| Clientes (activos, inactivos, desvinculados) | UIAF | Mensual | Según anexo técnico UIAF |
| Operación sospechosa (ROS) | UIAF | Cuando ocurra | Inmediato al detectarla |
| CARF | DIAN | Anual | Último día hábil de mayo del año siguiente |
| Exógena | DIAN | Anual | Calendario tributario según NIT |
| Declaraciones de IVA y retención | DIAN | Bimestral o cuatrimestral / mensual | Calendario tributario |
| Informe del oficial de cumplimiento | Junta / asamblea | Al menos semestral | Según manual SAGRILAFT |
| Conciliación de fondos | Interno | Diaria | Cierre del día |

06 · Checklist

## Qué necesitas

0 de 0 listos

### Documentos

- Certificado de existencia con objeto social cripto
- RUT con CIIU correcto y responsabilidad 67
- Manual SAGRILAFT aprobado
- Matriz de riesgo LA/FT
- Dossier bancario completo
- Acuerdo marco OTC para clientes
- Contratos con 2 proveedores de liquidez
- Política de tesorería y límites de riesgo

### Personas

- Oficial de cumplimiento (y suplente)
- Contador con experiencia en cripto
- Abogado financiero / cambiario
- Responsable de tesorería y trading
- Revisor fiscal (si aplica)

### Herramientas

- Custodia multifirma o MPC
- Análisis on-chain de wallets
- Consulta de listas restrictivas y PEP
- Motor de cotización y libro de operaciones
- Exportadores UIAF y CARF
- Firma electrónica DIAN y facturador

### Capital y cuentas

- Inventario COP para 1–2 días de volumen
- Inventario USDT para 1–2 días de volumen
- Cuenta bancaria principal operativa
- Cuenta separada para fondos de clientes
- Segundo banco (meta: antes de 6 meses)
- Cuenta institucional Binance OTC

Las marcas se guardan solo en este navegador.

07 · Pendientes

## Riesgos y puntos abiertos

| Tema | Riesgo | Acción |
| --- | --- | --- |
| Ley PSAV | Si se aprueba, puede crear un registro obligatorio, requisitos de capital o un supervisor nuevo. | Diseñar desde ya con estándares GAFI para que la adaptación sea menor. |
| Cierre de cuentas | Los bancos pueden cerrar cuentas de negocios cripto con poco aviso. | Dos bancos, comunicación proactiva con el oficial de cumplimiento del banco y reportes al día. |
| Tratamiento del spread en IVA | Ganancia por compraventa (no gravada) o servicio de intermediación (gravado). | Pedir concepto escrito a tu contador; considerar consulta formal a la DIAN. |
| Concentración en Binance | Binance también compite por clientes en Colombia. | Segundo proveedor firmado antes de escalar volumen. |
| Riesgo de contraparte | Un cliente no paga después de que tú entregas. | Liquidación prefondeada hasta tener historial con cada cliente. |
| Umbral SAGRILAFT | Las cifras del umbral sectorial cambian con el salario mínimo y circulares nuevas. | Confirmar la cifra vigente con Supersociedades. |

08 · Control de versiones

| Versión | Fecha | Cambios |
| --- | --- | --- |
| v1.0 | 14 oct 2026 | Versión inicial: marco regulatorio, ruta en 8 fases, obligaciones DIAN, calendario, checklist y riesgos. |

Fuentes

1. DIAN, Resolución 000240 de 2025 (CARF), resumen en [CERLATAM](https://www.cerlatam.com/normatividad/dian-resolucion-240-de-2025/) y [Holland & Knight](https://www.hklaw.com/en/insights/publications/2026/01/la-dian-busca-regular-el-reporte-de-informacion-sobre-criptoactivos)
2. DIAN, [Concepto 005146 de 2026](https://normograma.dian.gov.co/dian/compilacion/docs/oficio_dian_5146_2026.htm)
3. DIAN, [Concepto unificado sobre criptoactivos (2023)](https://incp.org.co/publicaciones/infoincp-publicaciones/informacion-para-empresas/contable/2023/10/la-dian-publica-concepto-unificado-sobre-criptoactivos/) y [Oficio 35238 de 2018](https://normograma.dian.gov.co/dian/compilacion/docs/oficio_dian_35238_2018.htm)
4. UIAF, [Resolución 314 de 2021](https://www.ambitojuridico.com/sites/default/files/2022-01/RES-314-21%28UIAF%29.pdf) y [plazos de reporte](https://actualicese.com/reporte-a-la-uiaf-de-servicios-de-activos-virtuales-en-colombia/)
5. Supersociedades, [Capítulo X — Oficio 220-159034 de 2021](https://www.supersociedades.gov.co/documents/107391/159040/OFICIO%20220-159034%20DE%202021)
6. Banco de la República, [Concepto C21-79245](https://banrep.gov.co/es/banco/junta-directiva/conceptos/c21-79245)
7. Congreso, [PL 510 de 2025 Cámara (PSAV)](https://apicongresovisible.uniandes.edu.co/uploads/proyecto-ley/14405/632/25.pdf)

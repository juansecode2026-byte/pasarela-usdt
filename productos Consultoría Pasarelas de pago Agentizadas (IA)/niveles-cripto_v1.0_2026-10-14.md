# Tres Niveles Cripto

> Versión en Markdown de `niveles-cripto_v1.0_2026-10-14.html`, generada con `scripts/sincronizar-md.py`. No editar a mano: se regenera desde el HTML. El HTML tiene las partes interactivas.

Minus · Documento técnico-comercial

# Formalización, operación formal y proveedor de liquidez: diferencias, construcción, beneficios legales e impuestos

Los tres niveles son una escalera. Cada uno se construye sobre el anterior, suma obligaciones y abre oportunidades de negocio distintas.

Versión
:   v1.0

Fecha
:   14 oct 2026

Jurisdicción
:   Colombia

Relacionado
:   Plan comercial v2.0

1 · Resumen

## La diferencia en una mirada

Nivel 1

### Formalización

La empresa queda en regla. Cumple lo que la ley ya exige a quien mueve cripto: reportes, cumplimiento LA/FT y registro tributario correcto.

**Pregunta que responde:** ¿estoy cumpliendo?

Nivel 2

### Operación formal

La empresa cobra y convierte cripto para su propio negocio con procesos automáticos, trazables y tributariamente ordenados.

**Pregunta que responde:** ¿puedo operar a escala sin riesgo?

Nivel 3

### Proveedor de liquidez

La empresa vende liquidez a otras empresas. Se vuelve contraparte, con inventario propio, clientes institucionales y obligaciones mayores.

**Pregunta que responde:** ¿puedo hacer de esto mi negocio?

**Importante.** En Colombia no existe hoy una licencia cripto. Ningún nivel da una licencia: lo que dan es cumplimiento demostrable de las normas vigentes (UIAF, DIAN, Supersociedades, Banco de la República) y una estructura lista para la ley de proveedores de servicios de activos virtuales que está en trámite.

Nivel 1

## Formalización

Para la empresa que ya recibe, vende o custodia cripto, o que va a empezar, y necesita ponerse en regla antes de crecer.

### Cómo se construye

1. **Diagnóstico regulatorio.** Qué hace hoy la empresa con cripto, con quién y por cuánto. Resultado: matriz de brechas.
2. **Estructura societaria.** Objeto social que mencione los servicios con activos virtuales y beneficiarios finales identificados. Si hace falta, sociedad separada.
3. **Registro tributario.** RUT con la actividad económica correcta y la responsabilidad 67 (CARF). Firma electrónica habilitada.
4. **Sistema de cumplimiento.** Manual SAGRILAFT, matriz de riesgo LA/FT, oficial de cumplimiento y debida diligencia intensificada de contrapartes.
5. **Registro ante la UIAF.** Inscripción como reportante y prueba de los reportes mensuales de clientes y transacciones.
6. **Dossier bancario.** Paquete documental para abrir o defender cuentas.
7. **Agentes.** KYB y reportes UIAF en funcionamiento.

### Beneficios legales

- Cumple la obligación de reporte mensual a la UIAF de la Resolución 314 de 2021, que aplica a quien intercambia, transfiere o custodia activos virtuales para clientes.
- Cumple la obligación CARF de la DIAN (Resolución 000240 de 2025) para el año gravable 2026.
- Reduce el riesgo de sanciones de Supersociedades por no tener SAGRILAFT cuando la empresa está obligada.
- Reduce el riesgo de cierre de cuentas bancarias, porque la empresa puede mostrar controles.
- Deja la empresa preparada para registrarse rápido si se aprueba la ley de proveedores de activos virtuales.

### Impuestos

| Tema | Tratamiento |
| --- | --- |
| Naturaleza | Para efectos tributarios, los criptoactivos son activos intangibles y forman parte del patrimonio. |
| Renta | La valorización no realizada no es ingreso gravable. Se tributa cuando se venden o se intercambian. |
| Patrimonio y exógena | Se reporta el valor patrimonial de los criptoactivos a 31 de diciembre (formato 1012, concepto 1206). |
| CARF | Reporte anual en XML de usuarios y transacciones. El año gravable 2026 se reporta hasta el último día hábil de mayo de 2027. |

### Qué no incluye

No automatiza la operación de cobro o conversión, ni ordena el tratamiento de IVA de una operación comercial. La empresa queda en regla, pero sigue operando de forma manual.

Nivel 2

## Operación formal

Para la empresa que cobra, paga o convierte cripto como parte de su negocio y necesita hacerlo a volumen sin que el cumplimiento se vuelva un cuello de botella.

### Cómo se construye

Todo el nivel 1, más:

1. **Pasarela USDT.** Recepción en hasta 3 redes, con wallet institucional multifirma o MPC.
2. **Conversión.** Integración con Binance OTC por API para pasar de USDT a COP y viceversa.
3. **Motor de cotización y límites.** Precio con spread, montos máximos y exposición máxima abierta.
4. **Separación de fondos.** Cuentas y wallets distintas para fondos de clientes y fondos propios.
5. **Política tributaria escrita.** Tratamiento de IVA, facturación y retenciones definido con el contador.
6. **Segundo banco.** Acompañamiento para no depender de una sola cuenta.
7. **Agentes.** Monitoreo transaccional, conciliación diaria y CARF.

### Beneficios legales

- Trazabilidad completa de cada operación: quién, cuánto, cuándo, desde qué wallet. Es la evidencia que piden UIAF, DIAN y bancos.
- Monitoreo continuo con escalamiento al oficial de cumplimiento, como lo exige un SAGRILAFT funcionando y no solo documentado.
- Separación de fondos de clientes, que protege a la empresa y a sus clientes ante un embargo o disputa.
- Redundancia bancaria: si un banco cierra la cuenta, la operación no se detiene.

### Impuestos

| Tema | Tratamiento |
| --- | --- |
| IVA en la venta de cripto | La venta de criptoactivos no está sujeta a IVA, según la doctrina de la DIAN. |
| IVA en servicios | La intermediación en la compra y venta de criptoactivos sí está gravada. Si la empresa cobra comisión por convertir para clientes, esa comisión lleva IVA. |
| Facturación electrónica | Obligatoria para los servicios prestados. Definir qué se factura en cada tipo de operación. |
| GMF (4×1000) | Aplica a los movimientos bancarios. Con volumen alto, afecta el margen y debe entrar en el precio. |
| Retención en la fuente | Según el tipo de operación y de contraparte. Definir con el contador. |
| Renta | La utilidad por conversión es ingreso del negocio en el año en que se realiza. |

El punto crítico de este nivel es decidir si el ingreso de la empresa es una ganancia por compraventa (sin IVA) o un servicio de intermediación (con IVA). Debe quedar por escrito con el contador antes de la primera operación.

### Qué no incluye

La empresa convierte para su propio negocio y sus propios clientes finales. No da cotizaciones a otras empresas ni actúa como contraparte institucional.

Nivel 3

## Proveedor de liquidez

Para la empresa que quiere que la liquidez sea su negocio: cotizar y liquidar cripto ↔ COP/USD a exchanges, pasarelas, fintechs y corporativos.

### Cómo se construye

Todo el nivel 2, más:

1. **Modelo de principal.** La empresa compra y vende con su propio balance. Requiere capital de trabajo en COP y en USDT.
2. **API de cotización (RFQ).** Los clientes piden precio, reciben una cotización firme por unos segundos y aceptan.
3. **Segundo proveedor de liquidez.** Contrato escrito con otra mesa OTC o market maker, y ruteo al mejor precio.
4. **Contratos institucionales.** Acuerdo marco OTC con cada cliente: cotización, cierre, liquidación, incumplimiento.
5. **Tesorería profesional.** Límites de riesgo, política de inventario y conciliación diaria entre banco, wallets y exchanges.
6. **Pata en dólares.** Canalización de USD por intermediarios del mercado cambiario cuando aplique.
7. **Integración ERP y auditoría.** Libro de operaciones auditable y auditoría simulada anual.
8. **Agentes.** Regulatorio y tesorería, sobre los cinco anteriores.

### Beneficios legales

- Estructura que cumple los criterios con los que un exchange o una fintech evalúa a su proveedor de liquidez: KYB, SAGRILAFT, reportes, contratos y auditoría.
- Contratos marco que definen la responsabilidad en errores de precio, envíos fallidos e incumplimientos. Reducen el riesgo de litigio.
- Cumplimiento cambiario en la pata USD: la cripto no es divisa, pero los dólares sí siguen el régimen del Banco de la República.
- Mejor posición para registrarse como proveedor de servicios de activos virtuales cuando exista el registro.

### Impuestos

| Tema | Tratamiento |
| --- | --- |
| Inventario | La cripto que la empresa compra para revender es inventario de su negocio. La utilidad es ingreso ordinario, no ganancia ocasional. |
| CARF | La definición de la DIAN incluye expresamente a quien actúa como contraparte. Un proveedor de liquidez es sujeto obligado. |
| IVA | El spread como principal se analiza como compraventa. Cualquier comisión explícita se analiza como servicio gravado. Requiere concepto escrito del contador. |
| GMF y costos bancarios | Con márgenes de fracciones de punto porcentual, el 4×1000 puede ser una parte grande del margen. Se modela en cada cotización. |
| Cambiario | Los ingresos y egresos en USD se canalizan y declaran según el régimen cambiario. La DIAN fiscaliza estas operaciones. |
| Exógena | Mayor volumen de información a reportar: terceros, transacciones y saldos de cripto a 31 de diciembre. |

### Riesgos propios de este nivel

- Riesgo de precio: el inventario puede perder valor entre la compra y la venta.
- Riesgo de contraparte: un cliente puede no pagar después de recibir. Se mitiga con liquidación prefondeada.
- Concentración: depender solo de Binance, que además compite por clientes en Colombia.

5 · Comparativo

## Comparativo completo

| Dimensión | Formalización | Operación formal | Proveedor de liquidez |
| --- | --- | --- | --- |
| Objetivo | Estar en regla | Operar a volumen en regla | Vender liquidez a otras empresas |
| Quién es el cliente final | Clientes propios | Clientes propios | Otras empresas |
| Rol en la operación | Usuario de cripto | Usuario y convertidor | Contraparte (principal) |
| Capital de trabajo | No requiere | Bajo | Alto: inventario COP y USDT |
| UIAF | Reportes mensuales | Reportes mensuales + monitoreo continuo | Reportes + monitoreo + debida diligencia institucional |
| DIAN | RUT, CARF, exógena | + IVA, facturación, retenciones | + inventario, cambiario, mayor exógena |
| Supersociedades | SAGRILAFT documentado | SAGRILAFT operando | SAGRILAFT operando + auditoría anual |
| Bancos | Dossier | Dos bancos y separación de fondos | Dos bancos, separación de fondos y canal cambiario |
| Contratos | No requiere | Términos con clientes finales | Acuerdo marco OTC y contratos con proveedores |
| Agentes | 2 | 5 | 7 |
| Plazo | 8–10 semanas | 10–14 semanas | 14–20 semanas |
| Precio (plan v2.0) | USD 18.000 + 1.500/mes | USD 35.000 + 3.000/mes | USD 60.000 + 5.000/mes |

6 · Diagnóstico

## Cómo saber qué nivel necesita un cliente

#### Formalización si…

- Ya mueve cripto pero no reporta a la UIAF
- Un banco le pidió documentación o le cerró la cuenta
- El volumen es bajo o la operación es ocasional

#### Operación formal si…

- Cobra o paga en USDT de forma recurrente
- Convierte a COP varias veces por semana
- Su equipo concilia a mano y se equivoca

#### Proveedor de liquidez si…

- Otras empresas ya le piden precio
- Tiene capital para mantener inventario
- Quiere que la liquidez sea su línea de negocio

**Regla de venta:** todo cliente empieza por formalización, aunque compre un nivel superior. Sin el nivel 1 resuelto, los niveles 2 y 3 no se sostienen ante un banco.

7 · Fuentes y control de versiones

| Versión | Fecha | Cambios |
| --- | --- | --- |
| v1.0 | 14 oct 2026 | Versión inicial: diferencias entre los tres niveles, construcción, beneficios legales, impuestos, comparativo y criterios de selección. |

Este documento resume normativa pública y doctrina vigente a la fecha. No reemplaza la opinión de un abogado ni de un contador. Los tratamientos de IVA y renta deben confirmarse para cada cliente.

1. DIAN, Resolución 000240 de 2025 (CARF): [CERLATAM](https://www.cerlatam.com/normatividad/dian-resolucion-240-de-2025/), [Holland & Knight](https://www.hklaw.com/en/insights/publications/2026/01/la-dian-busca-regular-el-reporte-de-informacion-sobre-criptoactivos), [INCP](https://incp.org.co/?p=128922)
2. DIAN, [Concepto unificado sobre criptoactivos (2023)](https://incp.org.co/publicaciones/infoincp-publicaciones/informacion-para-empresas/contable/2023/10/la-dian-publica-concepto-unificado-sobre-criptoactivos/) y [Oficio 35238 de 2018](https://normograma.dian.gov.co/dian/compilacion/docs/oficio_dian_35238_2018.htm)
3. [Exógena: formato 1012, concepto 1206](https://accounter.co/noticias/actualidad/rusell-bedford-concepto-unificado-sobre-criptoactivos)
4. UIAF, [Resolución 314 de 2021](https://www.ambitojuridico.com/sites/default/files/2022-01/RES-314-21%28UIAF%29.pdf)
5. Supersociedades, [Capítulo X (SAGRILAFT)](https://www.supersociedades.gov.co/documents/107391/159040/OFICIO%20220-159034%20DE%202021)
6. Banco de la República, [Concepto C21-79245](https://banrep.gov.co/es/banco/junta-directiva/conceptos/c21-79245)

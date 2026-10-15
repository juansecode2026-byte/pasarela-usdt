# Plan paso a paso para construir el proveedor de liquidez USDT

Versión del 14 de octubre de 2026. Nombre del proveedor: provisional ("Proveedor de liquidez USDT").

Une las dos mitades que hay que construir: **la empresa** (sociedad, impuestos, cumplimiento, bancos, contratos) y **el sistema** (código y base de datos). Una no funciona sin la otra: el sistema puede estar listo, pero sin SAS, cuenta bancaria y cumplimiento no se puede recibir un solo peso.

Sale de los documentos de `Libro de contabilidad blockchain/` (ruta de 8 fases y Parte II legal) y de las decisiones de `DECISIONES.md`. Todo lo legal y tributario está **sin validar**: lo confirman un abogado y un contador antes de ejecutarlo.

## Qué vamos a construir, en una frase

Una empresa independiente (SAS nueva, separada de DEVMINUS) que **recibe USDT de pagadores de cualquier parte del mundo, los convierte a pesos y los dispersa desde Bancolombia a la empresa cliente** (Hellominus, DEVMINUS), dejando cada operación documentada para la UIAF y la DIAN.

## Estado de un vistazo

| Fase | Tema | Estado |
|---|---|---|
| 0 | Decisiones previas | Parcial |
| 1 | Constituir la sociedad | Sin iniciar |
| 2 | DIAN | Sin iniciar |
| 3 | Cumplimiento | Sin iniciar |
| 4 | Bancos | Sin iniciar |
| 5 | Liquidez y tesorería | Sin iniciar |
| 6 | Contratos | Sin iniciar |
| 7 | Tecnología | **En curso** (base hecha) |
| 8 | Lanzamiento controlado | Sin iniciar |

Las fases 1 a 6 son de la empresa y las lideran personas (socios, abogado, contador, oficial de cumplimiento). La fase 7 la construimos nosotros. **Las fases 0 a 3 bloquean la salida a producción; la tecnología se puede avanzar en paralelo.**

---

## Fase 0. Decisiones previas (sin código)

Bloquean lo demás. Se cierran con los socios, el abogado y el contador.

| # | Decisión | Estado |
|---|---|---|
| 0.1 | Nombre definitivo del proveedor | Pendiente |
| 0.2 | Socios, porcentajes y roles de la SAS nueva (con desempate si es 50/50) | Pendiente |
| 0.3 | Modelo legal: proveedor directo, orquestador o cobro propio | Pendiente, con abogado y contador |
| 0.4 | Rol: **principal** (compra y vende con su balance) o **agente** (ejecuta por cuenta del cliente) | Pendiente, con contador |
| 0.5 | Clientes objetivo y pagadores: los clientes son empresas (KYB), pero los **pagadores finales serán personas**. Qué datos se les exigen | Pendiente, con abogado |
| 0.6 | Activos iniciales: solo USDT (contra pesos); BTC, ETH y USD después | **Decidido** (14 oct 2026) |
| 0.7 | Cuándo se confirma la reserva: cuando el pago es válido en la red (CONFIRMED). El proveedor asume la volatilidad | **Decidido** (14 oct 2026) |
| 0.8 | Política de reembolso | Pendiente |
| 0.9 | Red inicial (TRON o Polygon) | Pendiente |
| 0.10 | Clientes directos: Hellominus y DEVMINUS. Confirmar si Zuhay (CRM de ventas de la landing de Hellominus, socio de Hellominus) también es cliente de la API | Pendiente |
| 0.11 | Los pagos entran directo al proveedor y la dispersión va a la empresa cliente desde Bancolombia | **Decidido** (14 oct 2026) |
| 0.12 | El proveedor es una empresa independiente, separada de DEVMINUS | **Decidido** (14 oct 2026) |
| 0.13 | El pagador debe haber hecho el KYC en un exchange (Binance u otro que cumpla los criterios del proveedor) y pagar desde su cuenta, a su nombre (control 1 del libro v1.8) | **Decidido** (14 oct 2026) |
| 0.14 | Flujo limpio: todo lo que los pagadores le envían al proveedor entra como cripto; por su cuenta bancaria no entra nada de pagadores. El flujo con cuenta bancaria, incluido el de dólares, queda en las otras empresas | **Decidido** (14 oct 2026) |
| 0.15 | Países de los pagadores: permitidos, de riesgo y prohibidos | Pendiente |
| 0.16 | Jurisdicción: comparar 2 o 3 y decidir dónde se licencia y opera (hoy se asume una SAS colombiana, sin licencia disponible) | Pendiente |

## Fase 1. Constituir la sociedad

Quién: socios, abogado societario, Cámara de Comercio. Plazo de referencia: 2 a 4 semanas.

1. **Acuerdo de proyecto entre los socios**: el proyecto es de ambos, en qué porcentaje, y se cederá a la SAS cuando exista. Se firma antes de construir, y ya hay código escrito.
2. Verificar el nombre en el RUES y reservar el **dominio y el correo** de la empresa (ver nota al final).
3. Redactar el **acuerdo entre socios**: participación, roles, aportes, permanencia, decisiones que requieren a ambos, dividendos, exclusividad.
4. Redactar **estatutos** con un objeto social específico (compraventa, intermediación y custodia de activos virtuales; provisión de liquidez; consultoría). Decidir antes si el software o la consultoría de formalización van en el objeto o se hacen desde otra empresa.
5. Inscribir la SAS en la Cámara de Comercio (matrícula mercantil).
6. Registrar beneficiarios finales y composición accionaria clara. Los bancos lo revisan primero.
7. Contratar contador con experiencia en cripto. Revisor fiscal si se superan los topes.
8. Correo corporativo con dominio propio, distinto del de DEVMINUS, cuando exista el nombre (ver nota al final).
9. **Separar el proyecto de DEVMINUS**: no reutilizar su código, agentes, módulos ni cuentas; cuentas propias de correo, GitHub, Supabase y dominio.
10. Revisar los contratos de trabajo o de servicios de cada socio que puedan reclamar lo que crea.
11. Regla vigente: mientras no exista la SAS, no pasar dinero de clientes por cuentas personales de Binance ni del banco.

## Fase 2. Inscripción y obligaciones ante la DIAN

Quién: contador. 1 a 2 semanas.

1. RUT y NIT con la actividad económica (CIIU) correcta.
2. Agregar la **responsabilidad 67** (intercambio automático de información, CARF) antes de operar.
3. Firma electrónica.
4. Habilitar **facturación electrónica**.
5. Inscribirse en el ICA del municipio.
6. Definir por escrito la **política de IVA** y el tratamiento del spread, antes de la primera operación.

## Fase 3. Sistema de cumplimiento (SAGRILAFT)

Quién: oficial de cumplimiento. 4 a 8 semanas.

1. Nombrar oficial de cumplimiento y suplente.
2. Manual SAGRILAFT aprobado por la asamblea: matriz de riesgo, segmentación, señales de alerta, procedimiento de reporte de operaciones sospechosas.
3. Onboarding KYB de clientes: cámara de comercio, RUT, beneficiarios finales, estados financieros, origen de fondos, listas restrictivas y PEP.
4. Procedimiento de identificación de los **pagadores finales** (personas), según lo que decida la fase 0.5.
5. Contratar la herramienta de análisis on-chain de billeteras (Chainalysis, Elliptic o TRM Labs).
6. Política de Travel Rule.
7. Inscripción como reportante ante la UIAF en SIREL y prueba de los formatos.
8. Controles mínimos por pago (siete puntos del paso 13 del libro v1.8). El KYC de Binance no reemplaza el propio.
9. Revisar los términos de Binance para cuentas de negocio antes de operar.
10. **Lista de exchanges aceptados y sus criterios** (verifican identidad, están regulados): el pagador puede venir de cualquier exchange con KYC, pero solo de los que estén en la lista. Por ahora, Binance.

## Fase 4. Bancos y régimen cambiario

Quién: gerencia y oficial de cumplimiento. 4 a 12 semanas. **Riesgo real: los bancos cierran cuentas cripto con poco aviso.**

1. Armar el **dossier bancario**: certificado de existencia, RUT, manual SAGRILAFT, organigrama, perfil de clientes, volúmenes esperados y flujo de fondos.
2. Abrir la cuenta operativa principal en **Bancolombia** (la que dispersa).
3. Abrir una **segunda cuenta en otro banco** antes de los 6 meses.
4. Cuentas **separadas** para fondos de clientes y fondos propios desde el primer día.
5. Pata en dólares: **no se usa mientras el proveedor solo reciba cripto** (decisión del flujo limpio). Confirmar con un asesor cambiario que no hay obligaciones cambiarias, y reabrir este paso si algún día entran dólares por banco.
6. **Política de movimientos bancarios** del proveedor: qué entra y qué sale de su cuenta, con la regla de que ningún pagador paga por banco.

## Fase 5. Liquidez aguas arriba y tesorería

Quién: tesorería. 3 a 6 semanas. Requiere la sociedad constituida.

1. Cuenta institucional en **Binance** (KYB propio de la empresa).
2. **Segundo proveedor** de liquidez con contrato escrito, para no depender de uno solo.
3. Capital de trabajo: inventario en COP y en USDT para 1 a 2 días de volumen.
4. **Límites de riesgo** escritos: exposición máxima abierta, pérdida diaria máxima y tamaño máximo por operación.
5. **Custodia** con billeteras multifirma o MPC. Nunca una sola persona con acceso a las llaves.
6. Billetera fría de reserva, con su prueba de control documentada.

## Fase 6. Contratos

Quién: abogado. 2 a 4 semanas.

1. **Acuerdo marco** con cada cliente (Hellominus, DEVMINUS, y Zuhay si aplica): cómo se cotiza, cuándo una operación queda cerrada, plazos, errores de precio, envíos a direcciones erradas, incumplimientos.
2. Anexo de cumplimiento: el cliente entrega información KYB y acepta el monitoreo.
3. Política de tarifas y spreads por escrito, con los impuestos dentro del precio.
4. **Cesión de lo construido hacia la SAS** y traspaso de las cuentas del proyecto. No hay contrato de licencia con DEVMINUS; si DEVMINUS presta algún servicio en el futuro, contrato a precio de mercado aprobado por escrito por los socios (partes vinculadas).
5. Términos de redes soportadas y de uso de datos personales (Ley 1581).
6. **Partes vinculadas**: con los mismos dueños, las empresas se tratan como vinculadas. Confirmar con contador y abogado precios de transferencia, registro de situación de control o grupo empresarial, política de precios entre empresas y quién paga la infraestructura compartida.
7. **Gobierno**: comité de riesgos y cumplimiento con actas, políticas escritas, términos y aviso de riesgos, seguros si existen y auditoría independiente con calendario fijo.

## Fase 7. Tecnología (lo que construimos)

Se puede avanzar en paralelo a las fases 1 a 6. Código en este repositorio; base de datos en el proyecto `pasarela-usdt` de Supabase.

| # | Paso | Estado |
|---|---|---|
| 7.1 | Repositorio privado y proyecto de Supabase | **Hecho** |
| 7.2 | Contrato de la API | **Hecho** (borrador 2, puntos abiertos) |
| 7.3 | Esquema base: clientes, llaves de API, órdenes, cadena, bitácora (4 migraciones, 29 pruebas) | **Hecho** |
| 7.4 | **Libro contable v1.8**: activos genéricos, asientos con hash encadenado, anclaje diario, tasas, eventos crudos y conciliación | **En curso** |
| 7.5 | Máquina de estados de la orden, con pruebas | Pendiente |
| 7.6 | Vinculación de clientes (KYB, límites, cuenta bancaria) | Pendiente |
| 7.7 | API de órdenes con idempotencia y llave por cliente | Pendiente |
| 7.8 | Captura on-chain: direcciones por orden, detector de depósitos idempotente, confirmaciones y reorganizaciones | Pendiente |
| 7.9 | Análisis de la billetera de origen y revisión de cumplimiento (sin avisar el motivo al pagador) | Pendiente |
| 7.10 | Cotización, conversión por el adaptador de Binance y control de deslizamiento | Pendiente |
| 7.11 | Dispersión desde Bancolombia, manual con doble aprobación al principio | Pendiente |
| 7.12 | Conciliación diaria en tres vías: cadena, libro y banco | Pendiente |
| 7.13 | Reportes: UIAF mensual, CARF anual en XML, expediente por operación | Pendiente |
| 7.14 | Webhooks firmados y cliente liviano para Hellominus y DEVMINUS | Pendiente |
| 7.15 | Seguridad: custodia fuera del libro, secretos, roles y copias de seguridad | Pendiente |
| 7.16 | Pruebas del ciclo completo en redes de prueba: pago exacto, de menos, de más, tardío, billetera marcada, falla de conversión y de dispersión | Pendiente |

### Fase 7 · Infraestructura y bloqueos técnicos

Situaciones que salieron en el camino.

| # | Paso | Estado |
|---|---|---|
| 7.17 | Restablecer la base de pruebas local (se perdió su contraseña) y guardar la nueva en `%APPDATA%\postgresql\pgpass.conf` | Pendiente |
| 7.18 | Correr las 40 pruebas nuevas del libro v1.8 (bloqueado por 7.17) | Pendiente |
| 7.19 | Aplicar el libro v1.8 en Supabase después de las pruebas | Pendiente |
| 7.20 | Probar el comportamiento de la base en Supabase (escrituras de prueba bloqueadas por permisos) | Pendiente |
| 7.21 | Supabase a plan Pro antes del primer dato real | Pendiente |
| 7.22 | Contraseña de la base de Supabase: la define Juan, nunca en el chat ni en el repositorio | Pendiente |
| 7.23 | Protección de ramas en GitHub (requiere Pro u organización) | Pendiente |
| 7.24 | Renombrar el repositorio con el nombre definitivo | Pendiente |
| 7.25 | Decidir si se restaura el proyecto pausado `crm-productividad-hello-minus` | Pendiente |
| 7.26 | Contexto desde `.md`: cada HTML tiene su `.md` gemelo y se regenera con `scripts/sincronizar-md.py` | **Hecho** |
| 7.27 | Sincronización automática HTML y `.md`: gancho de Claude Code al editar un HTML y gancho de git antes de cada commit | **Hecho** |
| 7.28 | Cuentas propias del proyecto, separadas de DEVMINUS: la base ya es independiente, pero la organización de Supabase y la cuenta de GitHub se comparten. Hacerlo antes del primer dato real, de dar acceso a alguien que no sea socio o de constituir la SAS | Pendiente |
| 7.29 | Aviso al cliente: el proveedor le envía un correo inmediato a Hellominus (decidido); webhook firmado y consulta como respaldo (recomendación) | **En curso** |
| 7.30 | Correo de confirmación: dominio de la empresa con SPF, DKIM y DMARC, plantilla con los datos del pago y prueba de entrega | Pendiente |
| 7.31 | Registrar cada pago confirmado en el libro con hash, fecha y hora exacta, montos, direcciones, orden y análisis de riesgo | Pendiente |
| 7.32 | Prueba de penetración externa y auditoría de código antes del lanzamiento | Pendiente |
| 7.33 | Plan de recuperación ante desastres y monitoreo permanente | Pendiente |

**Se construye ya, con planes gratuitos y redes de prueba, sin dinero real.** Las herramientas que exigen contrato y empresa (análisis on-chain, custodia institucional, Binance institucional) se cotizan en paralelo para que estén firmadas al llegar el primer cliente. **Supabase debe pasar a Pro antes de guardar el primer dato real.**

## Fase 8. Lanzamiento controlado

Quién: todos.

1. Piloto con 2 o 3 clientes conocidos y **límites bajos durante el primer mes**.
2. Primera semana con montos bajos y límites progresivos.
3. Reportes a la UIAF desde el primer mes, aunque no haya operaciones (reporte de ausencia).
4. Revisar un expediente de prueba con el contador y el oficial de cumplimiento.
5. Operar un mes en paralelo con la contabilidad actual antes de apagar cualquier sistema anterior.
6. Revisión mensual de la matriz de riesgo y de los límites de tesorería.
7. Seguir el proyecto de ley de proveedores de servicios de activos virtuales (PL 510 de 2025): si se aprueba, habrá registro y requisitos nuevos.

---

## Qué bloquea qué

- **Sin 0.3, 0.4 y 0.5** no se puede cerrar el contrato de la API ni la vinculación de pagadores.
- **Sin la SAS (fase 1)** no hay RUT, ni cuenta bancaria, ni cuenta institucional en Binance, ni contratos con herramientas de pago.
- **Sin cumplimiento (fase 3)** los bancos no abren la cuenta.
- **Sin cuenta bancaria (fase 4)** no hay dispersión.
- **Todo lo anterior bloquea la salida a producción**, no la construcción de la fase 7.

## Nota sobre el correo y el dominio

El correo de la empresa se crea **cuando esté definido el nombre y exista la SAS**, con un dominio propio y distinto del de DEVMINUS. Un correo con el dominio de DEVMINUS ligaría la actividad cripto a la agencia, que es justo lo que la estructura independiente busca evitar. Para el dossier bancario y los procesos KYB conviene un correo con dominio propio, no uno gratuito.

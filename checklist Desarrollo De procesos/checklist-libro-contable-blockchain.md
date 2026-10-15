# Checklist: libro contable blockchain

> Versión en Markdown de `checklist-libro-contable-blockchain.html`, generada con `scripts/sincronizar-md.py`. No editar a mano: se regenera desde el HTML. La guía de cada paso (sitio y pasos) y la marcación interactiva están solo en el HTML.

Versión en checklist de Libro de contabilidad blockchain/libro-contable-blockchain_v1.8 : 15 pasos en 4 fases, herramientas, archivos de Excel y la Parte II legal. Un libro de partida doble, inalterable, encadenado con hashes y anclado cada día en una blockchain pública.

Actualizado: 14 de octubre de 2026 · El tratamiento contable y tributario debe validarlo el contador antes de producción.

**Avance registrado:** 6 hechos y 23 en curso, de 102 pasos.

Leyenda: `[x]` hecho · `[~]` en curso · `[ ]` pendiente. Cada paso trae su responsable.

## Herramientas de trazabilidad (sección C) (0/12)

_Casi todo se construye hoy con planes gratuitos y redes de prueba. Lo que exige contrato y empresa se cotiza en paralelo._

- [ ] **C.1** Exploradores para verificar a mano: Etherscan, Tronscan, mempool.space, Blockchair — _Cumplimiento_
- [ ] **C.2** APIs de lectura: Etherscan, TronGrid, Esplora (Bitcoin) o proveedor de nodos — _Tecnología_
- [ ] **C.3** API de Binance con llave de solo lectura, sin permiso de retiro — _Tecnología_
- [ ] **C.4** TRM oficial y una fuente única de precios de cripto — _Tecnología_
- [~] **C.5** Supabase con tablas del libro de solo inserción — _Tecnología_
- [~] **C.6** SHA-256 y OpenTimestamps para sellar y anclar — _Tecnología_
- [ ] **C.7** Generación de los archivos de Excel (openpyxl o SheetJS) — _Tecnología_
- [ ] **C.8** Redes de prueba: Sepolia (Ethereum), Nile o Shasta (Tron), testnet o signet (Bitcoin) — _Tecnología_
- [ ] **C.9** Antes de operar: analítica on-chain contratada (Chainalysis, Elliptic o TRM Labs) — _Cumplimiento_
- [ ] **C.10** Antes de operar: custodia multifirma o MPC (Safe, Fireblocks o BitGo) — _Tesorería_
- [ ] **C.11** Supabase en plan Pro antes del primer dato real (copias automáticas) — _Socios_
- [ ] **C.12** Con volumen: nodos propios, monitoreo continuo y segundo proveedor de datos — _Tecnología_

## Paso 1. Alcance y principios (3/6)

_Fase 1 · Diseño. Entregable: documento aprobado por gerencia y contador._

- [x] **1.1** Activos y redes: USDT (TRC-20 y ERC-20), BTC, ETH, USD y COP — _Producto_
- [~] **1.2** Fuentes: wallets propias, wallets de clientes, Binance, bancos — _Producto_
- [x] **1.3** Moneda funcional COP, guardando también la cantidad original — _Producto y contador_
- [x] **1.4** Principios: solo inserción, partida doble, evidencia, separación de fondos — _Producto_
- [ ] **1.5** Método de costo por activo (promedio ponderado o PEPS) — _Contador_
- [ ] **1.6** Documento de alcance aprobado por gerencia y contador — _Gerencia y contador_

## Paso 2. Plan de cuentas (0/3)

_Alineado al PUC y a NIIF. Códigos finales con el contador._

- [~] **2.1** Grupos: bancos, cripto propios, saldos en exchange, fondos de clientes, obligaciones con clientes, ingresos, gastos — _Contador_
- [ ] **2.2** Decidir si la cripto es inventario o intangible (cambia renta) — _Contador_
- [ ] **2.3** Códigos finales cargados en la base de datos — _Contador y tecnología_

## Paso 3. Modelo de datos (0/5)

_Separar evidencia cruda, asientos y cadena de verificación._

- [~] **3.1** Tablas: cuentas, wallets, contrapartes, eventos crudos, asientos, líneas, tasas, anclas, conciliaciones — _Tecnología_
- [~] **3.2** Migraciones versionadas y probadas — _Tecnología_
- [ ] **3.3** Base de pruebas local operativa (contraseña perdida; guardar la nueva en pgpass.conf) — _Juan y tecnología_
- [ ] **3.4** Correr las 40 pruebas del libro v1.8 (bloqueado por 3.3) — _Tecnología_
- [ ] **3.5** Aplicar la migración del libro en Supabase después de que pasen las pruebas — _Tecnología_

## Paso 4. Partida doble inalterable (0/4)

_Fase 2 · Núcleo. La base de datos misma impide errores._

- [~] **4.1** Validación en servidor: débitos = créditos en COP en cada asiento — _Tecnología_
- [~] **4.2** Tablas del libro solo de inserción: ningún rol edita ni borra — _Tecnología_
- [~] **4.3** Correcciones solo con asiento de reverso que referencia al original — _Tecnología_
- [~] **4.4** Cantidades en unidades mínimas enteras (satoshis, wei, 6 decimales USDT) — _Tecnología_

## Paso 5. Cadena de hashes (0/4)

_Cualquier cambio en un asiento antiguo rompe la cadena._

- [~] **5.1** Serialización fija de cada asiento — _Tecnología_
- [~] **5.2** Hash = SHA-256(hash anterior + contenido) — _Tecnología_
- [~] **5.3** Asiento génesis con valor fijo documentado — _Tecnología_
- [~] **5.4** Verificador que recorre y recalcula toda la cadena — _Tecnología_

## Paso 6. Anclaje en blockchain pública (0/5)

_Solo sale una huella de 32 bytes por día; ningún dato de clientes._

- [~] **6.1** Raíz de Merkle diaria de los hashes del día — _Tecnología_
- [ ] **6.2** Publicar la raíz en Bitcoin con OpenTimestamps — _Tecnología_
- [ ] **6.3** Opcional: publicarla también en Ethereum — _Tecnología_
- [~] **6.4** Guardar raíz, red, transacción y prueba en la tabla de anclas — _Tecnología_
- [ ] **6.5** Pantalla de verificación para auditores (asiento, ruta de Merkle, anclaje) — _Tecnología_

## Paso 7. Captura on-chain por red (1/5)

_Fase 3 · Conexiones. Solo transacciones confirmadas, guardadas como evidencia._

- [ ] **7.1** Después del inicio (solo USDT al inicio): Bitcoin: lectura por xpub, comisión como gasto, confirmaciones configurables — _Tecnología_
- [ ] **7.2** Después del inicio (solo USDT al inicio): Ethereum: transferencias y eventos Transfer ERC-20, gas como gasto, bloque finalizado — _Tecnología_
- [ ] **7.3** USDT: TRC-20 y ERC-20 como subcuentas, contrato oficial validado, costo de energía — _Tecnología_
- [x] **7.4** Sin duplicados: clave única por red, hash e índice — _Tecnología_
- [ ] **7.5** Detectar reorganizaciones de cadena y reversar — _Tecnología_

## Paso 8. Bancos y exchange (0/4)

_La pata fiat con la misma disciplina que la cadena._

- [ ] **8.1** Binance: depósitos, retiros, operaciones OTC y comisiones (solo lectura) — _Tecnología_
- [ ] **8.2** Bancos COP: extractos por API o archivo diario estandarizado — _Tecnología_
- [ ] **8.3** Después del inicio (solo USDT al inicio): Bancos USD, con vínculo a la declaración de cambio — _Tecnología y contador_
- [~] **8.4** Cada movimiento en eventos crudos con su soporte — _Tecnología_

## Paso 9. Reglas contables automáticas (0/3)

_Lo que no coincide con una regla va a revisión manual; no se contabiliza solo._

- [ ] **9.1** Catálogo: cobro en USDT, conversión, compra de BTC con USDT, gas, custodia, spread OTC — _Contador y tecnología_
- [ ] **9.2** Bandeja de revisión manual para eventos sin regla — _Tecnología_
- [ ] **9.3** Catálogo aprobado por el contador y probado con casos reales — _Contador_

## Paso 10. Valoración y tasas de cambio (0/5)

_Una fuente única, trazable y repetible._

- [ ] **10.1** USD a COP con la TRM oficial del día — _Tecnología_
- [ ] **10.2** Cripto a USD con una fuente de precio definida y marca de tiempo — _Tecnología_
- [~] **10.3** Cada línea guarda la tasa usada y su fuente — _Tecnología_
- [ ] **10.4** Costo y utilidad realizada con el método del paso 1 — _Tecnología y contador_
- [ ] **10.5** Valoración al cierre de mes y a 31 de diciembre — _Contador_

## Paso 11. Conciliación diaria (0/5)

_Fase 4 · Control. El libro cuadra con cada fuente, todos los días._

- [~] **11.1** Registro de conciliación por cuenta y fuente, con diferencia calculada — _Tecnología_
- [ ] **11.2** Wallets contra saldo on-chain; alerta y bloqueo del cierre si no cuadra — _Tecnología_
- [ ] **11.3** Binance contra su API; alerta a tesorería — _Tecnología_
- [ ] **11.4** Bancos contra extracto; alerta a contabilidad — _Tecnología_
- [ ] **11.5** Fondos de clientes contra obligaciones con clientes (alerta crítica) — _Tecnología_

## Paso 12. Impuestos y costo fiscal (0/7)

_El impuesto se calcula sobre la utilidad, no sobre el valor vendido._

- [ ] **12.1** Lotes de compra con fecha, cantidad, costo en COP y tasa — _Tecnología_
- [ ] **12.2** Tiempo de tenencia por lote (menos o más de 2 años) — _Tecnología_
- [ ] **12.3** Utilidad realizada por venta, con su impuesto (renta o ganancia ocasional) — _Tecnología y contador_
- [ ] **12.4** Costos de transacción (comisiones y gas) en el costo, según el contador — _Contador_
- [ ] **12.5** Datos de USDT del exterior: país, contraparte, motivo, tasa y hash — _Tecnología_
- [ ] **12.6** Revisar el ICA sobre ingresos brutos antes de fijar tarifas — _Contador_
- [ ] **12.7** Reportes: renta, exógena 1012/1206, CARF, IVA, ICA — _Contador_

## Paso 13. Trazabilidad y cumplimiento (0/9)

_Desde cualquier asiento se llega al cliente, la evidencia y el riesgo._

- [~] **13.1** Cada asiento enlaza evento crudo, transacción, cliente y expediente KYB — _Tecnología_
- [ ] **13.2** Puntaje de riesgo de cada wallet externa — _Cumplimiento_
- [ ] **13.3** Datos de origen y beneficiario (Travel Rule) — _Cumplimiento_
- [ ] **13.4** Exportadores: UIAF mensual, CARF anual en XML, saldos para exógena — _Tecnología_
- [ ] **13.5** Conservar evidencia al menos 5 años — _Tecnología_
- [ ] **13.6** Cliente del exterior que paga como persona natural: registrar el ingreso en pesos al valor del día de llegada, facturarlo y confirmar con el contador el IVA si es exportación — _Contador_
- [ ] **13.7** El KYC de Binance no reemplaza el propio: verificar identificación, país, actividad, propósito y origen de fondos, y registrar en el libro qué se usó de Binance — _Oficial de cumplimiento_
- [ ] **13.8** Siete controles mínimos por pago: cuentas verificadas a nombre del cliente, KYC proporcional, orden con monto y referencia únicos, análisis de riesgo, registro en el libro y límite por cliente — _Oficial de cumplimiento_
- [ ] **13.9** Cláusula en los términos: cada cliente responde por sus impuestos. Aclara, pero no libera a la empresa de sus obligaciones — _Abogado_

## Paso 14. Seguridad, accesos y billetera fría (1/8)

_El sistema contable nunca puede mover fondos._

- [~] **14.1** El libro no guarda llaves privadas: solo direcciones públicas — _Tecnología_
- [ ] **14.2** Llaves de API de exchange y bancos solo de lectura — _Tecnología_
- [ ] **14.3** Roles separados: quien registra, quien aprueba ajustes, quien audita — _Gerencia_
- [x] **14.4** Bitácora de accesos y acciones encadenada con hashes — _Tecnología_
- [ ] **14.5** Copias cifradas y prueba de restauración trimestral — _Tecnología_
- [ ] **14.6** Billetera fría documentada: dirección propia, prueba de control, traslados como transferencia interna — _Tesorería_
- [ ] **14.7** Lista blanca de retiro en Binance y doble persona para mover la reserva — _Tesorería_
- [ ] **14.8** Contraseñas y llaves fuera de carpetas temporales, del chat y del repositorio: en el gestor de secretos o en el archivo estándar del usuario — _Tecnología_

## Paso 15. Reportes, pruebas y producción (0/5)

_Entrar a producción con datos reales verificados._

- [ ] **15.1** Balance y resultados por activo y red; posición diaria; mayor con enlace a la evidencia — _Tecnología_
- [~] **15.2** Probar casos difíciles: comisiones, reversos, duplicados, tokens falsos, reorganizaciones — _Tecnología_
- [~] **15.3** Intentar alterar un asiento en pruebas y confirmar que el verificador lo detecta — _Tecnología_
- [ ] **15.4** Un mes en paralelo con la contabilidad actual — _Contador_
- [ ] **15.5** Revisión del contador y del revisor fiscal; acta de aprobación — _Contador_

## Anexo D. Archivos de Excel (0/3)

_Generados desde el libro y sellados; nunca la fuente de verdad._

- [ ] **D.1** Plantilla con las ocho hojas y fórmulas protegidas — _Tecnología_
- [ ] **D.2** Generación y sellado diario (hash SHA-256 en la hoja de control y en la raíz del día) — _Tecnología_
- [ ] **D.3** Saldos iniciales de lotes anteriores con su soporte — _Contador_

## Parte II. Constitución como proveedor de liquidez (1/9)

_Orden recomendado de entregables (sección E.7). Lo redacta un abogado._

- [ ] **E.1** Acuerdo de proyecto entre los socios, antes de construir (ya hay código escrito) — _Abogado_
- [ ] **E.2** Acuerdo entre socios de la nueva SAS — _Abogado_
- [ ] **E.3** Estatutos con objeto social específico e inscripción de la SAS — _Abogado y Cámara de Comercio_
- [ ] **E.4** RUT, cuenta bancaria, ICA y facturación — _Contador_
- [ ] **E.5** Cesión de lo construido hacia la SAS y traspaso de las cuentas del proyecto. Sin contrato de licencia con DEVMINUS — _Abogado_
- [ ] **E.6** Manual SAGRILAFT, oficial de cumplimiento y registro ante la UIAF — _Cumplimiento_
- [ ] **E.7** Separación de DEVMINUS: no reutilizar su código, agentes ni cuentas; cuentas propias del proyecto (correo, GitHub, Supabase, dominio) — _Socios_
- [ ] **E.8** Revisar contratos de trabajo o de servicios de los socios que reclamen lo que cada uno crea — _Abogado_
- [x] **E.9** Regla vigente: sin SAS no se pasa dinero de clientes por cuentas personales de Binance ni del banco — _Todos_

## Análisis de resultados

Cada vez que se complete un paso o un grupo de pasos con un efecto real, se agrega aquí un resultado numerado. Cada resultado responde las mismas cinco preguntas, para que se vea qué se puede demostrar con el libro y no solo qué tareas se hicieron.

### Ejemplo de cómo leer un resultado

- **Qué se logró:** El anclaje diario publica la raíz de Merkle del día en Bitcoin con OpenTimestamps.
- **Evidencia:** Fila en anchors con estado confirmado y el sello de OpenTimestamps verificable por cualquiera.
- **Qué habilita:** Un auditor o un banco puede comprobar que un asiento existía así en esa fecha, sin ver datos de clientes.
- **Qué falta o qué riesgo queda:** La pantalla de verificación para auditores (paso 6.5) todavía no existe.
- **Pasos del checklist:** 6.1, 6.2 y 6.4.

### Resultado 1. Bitácora inalterable y encadenada, probada

- **Qué se logró:** La bitácora de acciones ( audit_log ) encadena cada registro con el hash del anterior, no se puede editar ni borrar, y una función recorre la cadena y señala el primer registro alterado.
- **Evidencia:** Pruebas locales del 5 de octubre: cadena íntegra, edición y borrado rechazados, alteración detectada.
- **Qué habilita:** Cumplir la parte de "bitácora de accesos y acciones, también encadenada con hashes" del paso 14, y usar el mismo patrón en el libro.
- **Qué falta o qué riesgo queda:** Falta registrar en ella los accesos reales cuando exista la aplicación.
- **Pasos del checklist:** 14.4

### Resultado 2. Núcleo del libro v1.8 escrito, pendiente de pruebas

- **Qué se logró:** Migración con activos genéricos (COP, USD, USDT, BTC, ETH en unidades mínimas, 1 ETH = 10^18 wei), plan de cuentas por entidad, asientos solo por una función que valida el cuadre y los sella con hash, reversos, verificador de la cadena, raíz de Merkle diaria, tasas con fuente, eventos crudos con su hash, wallets solo con direcciones públicas y conciliación.
- **Evidencia:** supabase/migrations/20261014000001_libro_v17.sql y 40 pruebas nuevas escritas en supabase/tests/esquema.test.sql .
- **Qué habilita:** Cuando pasen las pruebas: conectar las fuentes (fase 3) sobre un libro que rechaza por diseño asientos descuadrados y modificaciones.
- **Qué falta o qué riesgo queda:** Sin probar. Se perdió el acceso a la base de pruebas local y no se pudo correr. Hasta entonces no se puede afirmar que funcione. Tampoco está aplicada en Supabase.
- **Pasos del checklist:** 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 5.1, 5.2, 5.3, 5.4, 6.1, 6.4, 10.3, 11.1

### Resultado 3. Alcance y principios del libro definidos

- **Qué se logró:** Activos y redes fijados (USDT en TRC-20 y ERC-20, BTC, ETH, USD y COP), COP como moneda funcional guardando la cantidad original, y los principios del libro: solo inserción, partida doble, evidencia y separación de fondos.
- **Evidencia:** Tabla assets , columna native_amount y los disparadores de la migración 20261014000001_libro_v17.sql .
- **Qué habilita:** Diseñar el plan de cuentas y las reglas contables sobre principios que el código ya hace cumplir.
- **Qué falta o qué riesgo queda:** Falta el documento de alcance aprobado por gerencia y contador (1.6) y el método de costo (1.5).
- **Pasos del checklist:** 1.1, 1.3, 1.4

### Resultado 4. Sin duplicados de transacciones on-chain, probado

- **Qué se logró:** Una misma transacción no se registra dos veces: la base exige unicidad por red, hash e índice.
- **Evidencia:** Prueba "cadena: la misma transacción no se procesa dos veces", aprobada el 5 de octubre de 2026.
- **Qué habilita:** Construir el detector de depósitos de forma idempotente: reintentos y reconexiones no duplican dinero.
- **Qué falta o qué riesgo queda:** Falta el detector y el manejo de reorganizaciones de cadena (7.5).
- **Pasos del checklist:** 7.4

### Resultado 5. Libro contable v1.8 sincronizado con el proyecto

- **Qué se logró:** La v1.8 reemplazó a la v1.8 como único documento del libro en el proyecto. Se actualizaron los dos checklists, el plan y el CLAUDE.md con sus dos cambios: el paso 13 ampliado (clientes del exterior que pagan como persona natural, qué cubre y qué no el KYC de Binance, siete controles por pago) y una Parte II distinta (sin contrato de licencia con DEVMINUS: el proyecto es de los socios y de la SAS).
- **Evidencia:** Un solo archivo del libro en Libro de contabilidad blockchain/ ; la v1.8 queda en el historial de git. Pasos nuevos o corregidos: 0.13, 1.1, 1.4, 1.9 a 1.11, 3.8, 3.9, 6.4 y 7.28 del plan, y 13.6 a 13.9, E.1, E.5 y E.7 a E.9 de este checklist.
- **Qué habilita:** Trabajar con un solo texto vigente, y ver qué pasos del plan cambian de sentido: ya no hay contrato SAS–DEVMINUS, y el software puede ir en el objeto social.
- **Qué falta o qué riesgo queda:** 1. El acuerdo de proyecto entre los socios se firma antes de construir, y ya hay código escrito. 2. El proyecto de Supabase está en la misma organización que proyectos de Hellominus y de DEVMINUS, y el repositorio está en una cuenta personal: la v1.8 pide cuentas propias (7.28). 3. El control 1 (aceptar pagos solo de cuentas verificadas a nombre del cliente) no calza con un pagador que paga desde cualquier billetera (0.13). 4. Según la v1.8, DEVMINUS todavía no está constituida legalmente, así que hoy no hay empresa a la cual cederle nada: por eso el acuerdo es entre los socios. El modelo de datos de la migración no cambia.
- **Pasos del checklist:** Pasos pendientes: 13.6 a 13.9, E.1, E.5 y E.7 a E.9 (en este checklist) y 0.13, 1.1, 1.9, 1.10, 3.8, 6.4 y 7.28 (en el del proveedor).

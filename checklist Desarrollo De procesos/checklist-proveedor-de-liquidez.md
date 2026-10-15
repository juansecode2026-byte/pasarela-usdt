# Checklist: construir el proveedor de liquidez USDT

> Versión en Markdown de `checklist-proveedor-de-liquidez.html`, generada con `scripts/sincronizar-md.py`. No editar a mano: se regenera desde el HTML. La guía de cada paso (sitio y pasos) y la marcación interactiva están solo en el HTML.

Versión en checklist de Docs/plan-paso-a-paso-proveedor-de-liquidez.md . Une las dos mitades: la empresa (fases 0 a 6 y 8) y el sistema (fase 7). Marca cada paso cuando quede hecho.

Actualizado: 14 de octubre de 2026 · Nombre del proveedor: provisional · Lo legal y tributario está sin validar por abogado y contador.

**Avance registrado:** 11 hechos y 2 en curso, de 94 pasos.

Leyenda: `[x]` hecho · `[~]` en curso · `[ ]` pendiente. Cada paso trae su responsable.

## Fase 0. Decisiones previas (sin código) (5/13)

_Bloquean lo demás. Socios, abogado y contador._

- [ ] **0.1** Nombre definitivo del proveedor — _Socios_
- [ ] **0.2** Socios, porcentajes y roles de la SAS nueva (desempate si es 50/50) — _Socios y abogado_
- [ ] **0.3** Modelo legal: proveedor directo, orquestador o cobro propio — _Abogado y contador_
- [ ] **0.4** Rol: principal (balance propio) o agente (por cuenta del cliente) — _Contador_
- [ ] **0.5** Datos exigidos a los pagadores finales (personas) — _Abogado_
- [x] **0.6** Activos iniciales: solo USDT (contra pesos). BTC, ETH y USD quedan para después — _Juan_
- [x] **0.7** Cuándo se confirma la reserva: cuando el pago es válido en la red (CONFIRMED). El proveedor asume la volatilidad — _Juan_
- [ ] **0.8** Política de reembolso — _Socios y abogado_
- [ ] **0.9** Red inicial (TRON o Polygon) — _Socios_
- [ ] **0.10** Clientes directos: Hellominus y DEVMINUS. Confirmar si Zuhay (CRM de ventas de la landing de Hellominus, su socio) también es cliente de la API — _Socios_
- [x] **0.11** Pagos entran al proveedor; dispersión a la empresa cliente desde Bancolombia — _Juan_
- [x] **0.12** El proveedor es una empresa independiente, separada de DEVMINUS — _Juan_
- [x] **0.13** El pagador debe haber hecho el KYC en un exchange (Binance u otro que cumpla los criterios del proveedor) y pagar desde su cuenta, a su nombre (control 1 del libro v1.8). El KYC propio del proveedor sigue siendo necesario — _Juan_

## Fase 1. Constituir la sociedad (1/11)

_2 a 4 semanas. Socios, abogado societario, Cámara de Comercio._

- [ ] **1.1** Acuerdo de proyecto entre los socios: el proyecto es de ambos y se cederá a la SAS cuando exista. Se firma antes de construir, y ya hay código escrito — _Abogado_
- [ ] **1.2** Verificar el nombre en el RUES y reservar dominio y correo propios — _Socios_
- [ ] **1.3** Acuerdo entre socios: participación, roles, aportes, permanencia, decisiones, dividendos, exclusividad — _Abogado_
- [ ] **1.4** Estatutos con objeto social específico de activos virtuales; decidir antes si incluye software o consultoría, o si eso se hace desde otra empresa — _Abogado_
- [ ] **1.5** Inscripción en la Cámara de Comercio (matrícula mercantil) — _Abogado_
- [ ] **1.6** Registro de beneficiarios finales y composición accionaria — _Abogado_
- [ ] **1.7** Contador con experiencia en cripto; revisor fiscal si se superan topes — _Socios_
- [ ] **1.8** Correo corporativo con dominio propio, distinto del de DEVMINUS, creado cuando exista el nombre. No usar un correo gratuito para bancos, Binance, DIAN ni UIAF — _Socios_
- [ ] **1.9** Separar el proyecto de DEVMINUS: no reutilizar su código, agentes, módulos ni cuentas; cuentas propias de correo, GitHub, Supabase y dominio, que se transfieren a la SAS al constituirla — _Socios_
- [ ] **1.10** Revisar los contratos de trabajo o de servicios de cada socio que puedan reclamar lo que crea (lo creado dentro de un contrato suele ser del empleador) — _Abogado_
- [x] **1.11** Regla vigente: mientras no exista la SAS, no pasar dinero de clientes por una cuenta personal de Binance ni por una cuenta bancaria personal — _Todos_

## Fase 2. DIAN (0/6)

_1 a 2 semanas. Contador._

- [ ] **2.1** RUT y NIT con la actividad económica (CIIU) correcta — _Contador_
- [ ] **2.2** Responsabilidad 67 (CARF) en el RUT antes de operar — _Contador_
- [ ] **2.3** Firma electrónica — _Contador_
- [ ] **2.4** Facturación electrónica habilitada — _Contador_
- [ ] **2.5** Inscripción en el ICA del municipio — _Contador_
- [ ] **2.6** Política de IVA y tratamiento del spread por escrito — _Contador_

## Fase 3. Cumplimiento (SAGRILAFT) (0/10)

_4 a 8 semanas. Oficial de cumplimiento._

- [ ] **3.1** Oficial de cumplimiento y suplente — _Socios_
- [ ] **3.2** Manual SAGRILAFT aprobado: matriz de riesgo, señales de alerta, procedimiento ROS — _Oficial de cumplimiento_
- [ ] **3.3** Onboarding KYB de clientes (cámara, RUT, beneficiarios, estados financieros, listas, PEP) — _Oficial de cumplimiento_
- [ ] **3.4** Procedimiento de identificación de pagadores finales — _Oficial de cumplimiento_
- [ ] **3.5** Herramienta de análisis on-chain contratada (Chainalysis, Elliptic o TRM Labs) — _Oficial de cumplimiento_
- [ ] **3.6** Política de Travel Rule — _Oficial de cumplimiento_
- [ ] **3.7** Inscripción en SIREL (UIAF) y prueba de formatos — _Oficial de cumplimiento_
- [ ] **3.8** Controles mínimos por pago en el manual SAGRILAFT (siete puntos del paso 13 del libro v1.8); el abogado define el KYC simplificado y sus datos mínimos — _Oficial de cumplimiento_
- [ ] **3.9** Revisar los términos de Binance para cuentas de negocio antes de operar: puede cerrar la cuenta si la actividad no corresponde al perfil — _Tesorería_
- [ ] **3.10** Lista de exchanges aceptados y sus criterios (KYC verificable, regulados), revisada cada cierto tiempo. Por ahora Binance; otros se agregan con el abogado y el oficial de cumplimiento — _Oficial de cumplimiento_

## Fase 4. Bancos y régimen cambiario (0/5)

_4 a 12 semanas. Riesgo real: los bancos cierran cuentas cripto con poco aviso._

- [ ] **4.1** Dossier bancario completo — _Gerencia_
- [ ] **4.2** Cuenta operativa en Bancolombia (la que dispersa) — _Gerencia_
- [ ] **4.3** Segunda cuenta en otro banco (antes de 6 meses) — _Gerencia_
- [ ] **4.4** Cuentas separadas: fondos de clientes y fondos propios — _Gerencia_
- [ ] **4.5** Canal para la pata en dólares, con asesor cambiario — _Gerencia_

## Fase 5. Liquidez y tesorería (0/6)

_3 a 6 semanas. Requiere la sociedad constituida._

- [ ] **5.1** Cuenta institucional en Binance (KYB propio) — _Tesorería_
- [ ] **5.2** Segundo proveedor de liquidez con contrato escrito — _Tesorería_
- [ ] **5.3** Capital de trabajo en COP y USDT para 1 a 2 días de volumen — _Socios_
- [ ] **5.4** Límites de riesgo escritos (exposición, pérdida diaria, tamaño por operación) — _Tesorería_
- [ ] **5.5** Custodia multifirma o MPC; nunca una sola persona con las llaves — _Tesorería_
- [ ] **5.6** Billetera fría de reserva con prueba de control documentada — _Tesorería_

## Fase 6. Contratos (0/5)

_2 a 4 semanas. Abogado._

- [ ] **6.1** Acuerdo marco con cada cliente (Hellominus, DEVMINUS, Zuhay si aplica) — _Abogado_
- [ ] **6.2** Anexo de cumplimiento (KYB y monitoreo) — _Abogado_
- [ ] **6.3** Política de tarifas y spreads, con impuestos dentro del precio — _Socios y contador_
- [ ] **6.4** Cesión de lo construido por los socios hacia la SAS y traspaso de las cuentas del proyecto. Sin contrato de licencia con DEVMINUS; si DEVMINUS presta un servicio, contrato a precio de mercado entre vinculados — _Abogado_
- [ ] **6.5** Términos de redes soportadas y de datos personales (Ley 1581) — _Abogado_

## Fase 7. Tecnología (lo que construimos) (3/16)

_En paralelo a las fases 1 a 6. Supabase a Pro antes del primer dato real._

- [x] **7.1** Repositorio privado y proyecto de Supabase — _Equipo técnico_
- [x] **7.2** Contrato de la API (borrador 2) — _Equipo técnico_
- [x] **7.3** Esquema base: clientes, llaves, órdenes, cadena, bitácora (29 pruebas) — _Equipo técnico_
- [~] **7.4** Libro contable v1.8: activos genéricos, hash por asiento, anclaje, tasas, eventos crudos, conciliación — _Equipo técnico_
- [ ] **7.5** Máquina de estados de la orden, con pruebas — _Equipo técnico_
- [ ] **7.6** Vinculación de clientes (KYB, límites, cuenta bancaria) — _Equipo técnico_
- [ ] **7.7** API de órdenes con idempotencia y llave por cliente — _Equipo técnico_
- [ ] **7.8** Captura on-chain: direcciones por orden, depósitos, confirmaciones, reorganizaciones — _Equipo técnico_
- [ ] **7.9** Análisis de la billetera de origen y revisión de cumplimiento — _Equipo técnico_
- [ ] **7.10** Cotización y conversión por el adaptador de Binance, con control de deslizamiento — _Equipo técnico_
- [ ] **7.11** Dispersión desde Bancolombia (manual con doble aprobación al principio) — _Equipo técnico_
- [ ] **7.12** Conciliación diaria en tres vías: cadena, libro y banco — _Equipo técnico_
- [ ] **7.13** Reportes: UIAF mensual, CARF anual en XML, expediente por operación — _Equipo técnico_
- [ ] **7.14** Webhooks firmados y cliente liviano para Hellominus y DEVMINUS — _Equipo técnico_
- [ ] **7.15** Seguridad: custodia fuera del libro, secretos, roles, copias de seguridad — _Equipo técnico_
- [ ] **7.16** Pruebas del ciclo completo en redes de prueba — _Equipo técnico_

## Fase 7 · Infraestructura y bloqueos técnicos (2/15)

_Situaciones que salieron en el camino. Bloquean pasos de la fase 7._

- [ ] **7.17** Restablecer la base de pruebas local: se perdió su contraseña (estaba en una carpeta temporal). Guardar la nueva en %APPDATA%\postgresql\pgpass.conf, fuera del repositorio — _Juan y equipo técnico_
- [ ] **7.18** Correr las 40 pruebas nuevas del libro v1.8 (bloqueado por 7.17) — _Equipo técnico_
- [ ] **7.19** Aplicar el libro v1.8 en Supabase después de que pasen sus pruebas — _Equipo técnico_
- [ ] **7.20** Probar el comportamiento de la base en Supabase: las escrituras de prueba fueron bloqueadas 5 veces por el sistema de permisos — _Equipo técnico_
- [ ] **7.21** Supabase a plan Pro antes del primer dato real (el gratuito se pausa y no tiene copias automáticas) — _Socios_
- [ ] **7.22** Contraseña de la base de Supabase: la define Juan en el panel, nunca en el chat ni en el repositorio — _Juan_
- [ ] **7.23** Protección de ramas en GitHub (requiere GitHub Pro u organización) — _Socios_
- [ ] **7.24** Renombrar el repositorio cuando haya nombre definitivo del proveedor — _Equipo técnico_
- [ ] **7.25** Decidir si se restaura el proyecto de Supabase pausado (crm-productividad-hello-minus) — _Juan_
- [x] **7.26** Contexto desde .md: cada HTML tiene su .md gemelo; se lee el .md y se regenera al actualizar el HTML (scripts/sincronizar-md.py) — _Equipo técnico_
- [x] **7.27** Sincronización automática HTML y .md: gancho de Claude Code al editar un HTML y gancho de git antes de cada commit — _Equipo técnico_
- [ ] **7.28** Cuentas propias del proyecto, separadas de DEVMINUS: hoy Supabase está en la misma organización que proyectos de Hellominus y de DEVMINUS, y GitHub es una cuenta personal. Crear organización propia y transferirlas a la SAS al constituirla — _Socios y equipo técnico_
- [~] **7.29** Aviso al cliente: el proveedor le envía un correo inmediato a Hellominus (decidido); webhook firmado y consulta como respaldo (recomendación) — _Socios y equipo técnico_
- [ ] **7.30** Correo de confirmación: dominio de la empresa con SPF, DKIM y DMARC, plantilla con los datos del pago y prueba de entrega — _Equipo técnico_
- [ ] **7.31** Registrar cada pago confirmado en el libro con hash, fecha y hora exacta, montos, direcciones, orden y análisis de riesgo — _Equipo técnico_

## Fase 8. Lanzamiento controlado (0/7)

_Todos._

- [ ] **8.1** Piloto con 2 o 3 clientes conocidos y límites bajos el primer mes — _Todos_
- [ ] **8.2** Primera semana con montos bajos y límites progresivos — _Tesorería_
- [ ] **8.3** Reportes UIAF desde el primer mes, aunque no haya operaciones — _Oficial de cumplimiento_
- [ ] **8.4** Expediente de prueba revisado con contador y oficial de cumplimiento — _Contador_
- [ ] **8.5** Un mes en paralelo con la contabilidad actual — _Contador_
- [ ] **8.6** Revisión mensual de la matriz de riesgo y los límites — _Oficial de cumplimiento_
- [ ] **8.7** Seguimiento del proyecto de ley PSAV (PL 510 de 2025) — _Abogado_

## Análisis de resultados

Cada vez que se complete un paso o un grupo de pasos con un efecto real, se agrega aquí un resultado numerado. Cada resultado responde siempre las mismas cinco preguntas, para que se lea la lógica de lo alcanzado y no solo la lista de tareas.

### Ejemplo de cómo leer un resultado

- **Qué se logró:** La SAS quedó inscrita en la Cámara de Comercio con objeto social de activos virtuales.
- **Evidencia:** Certificado de existencia y representación legal con fecha.
- **Qué habilita:** Sacar el RUT con la responsabilidad 67 (fase 2) y abrir la cuenta en Bancolombia (fase 4).
- **Qué falta o qué riesgo queda:** El banco puede negar la cuenta: hay que presentarle el dossier y el manual SAGRILAFT.
- **Pasos del checklist:** 1.5 y 1.6.

### Resultado 1. Proyecto independiente con repositorio y base de datos propios

- **Qué se logró:** Estructura del laboratorio, repositorio privado en GitHub y proyecto propio de Supabase, separados de Hellominus.
- **Evidencia:** Repositorio juansecode2026-byte/pasarela-usdt y proyecto Supabase pasarela-usdt .
- **Qué habilita:** Construir el sistema sin exponer datos sensibles en el repositorio público de Hellominus.
- **Qué falta o qué riesgo queda:** Sin protección de ramas (pide GitHub Pro). Supabase en plan gratuito: pasar a Pro antes del primer dato real.
- **Pasos del checklist:** 7.1

### Resultado 2. Esquema base probado

- **Qué se logró:** Cuatro migraciones con clientes, llaves de API, órdenes, transacciones on-chain, análisis de riesgo, dispersiones, webhooks y bitácora encadenada por hash.
- **Evidencia:** 29 pruebas en PostgreSQL local, todas aprobadas, y una prueba de mutación que confirma que detectan una protección faltante (5 de octubre).
- **Qué habilita:** Construir la máquina de estados y la API de órdenes sobre una base que rechaza por diseño errores de dinero y mezcla entre clientes.
- **Qué falta o qué riesgo queda:** En Supabase solo se verificó que las tablas existen, no su comportamiento (las escrituras de prueba fueron bloqueadas).
- **Pasos del checklist:** 7.3

### Resultado 3. Enfoque y flujo de dinero definidos

- **Qué se logró:** El proyecto es un proveedor de liquidez independiente. Los pagos USDT entran directo al proveedor, que dispersa los pesos desde Bancolombia a la empresa cliente (Hellominus, DEVMINUS).
- **Evidencia:** DECISIONES.md y CLAUDE.md del 14 de octubre de 2026.
- **Qué habilita:** Reescribir el contrato de la API (hecho, borrador 2) y saber a quién se le verifica la cuenta bancaria: una empresa por cliente.
- **Qué falta o qué riesgo queda:** Es el modelo de mayor carga regulatoria (recibe dinero de personas). Debe validarlo un abogado y un contador antes de mover dinero real.
- **Pasos del checklist:** 0.6, 0.7, 0.11, 0.12, 0.13, 7.2

### Resultado 4. Libro contable v1.8 escrito, pendiente de pruebas

- **Qué se logró:** Migración del libro con activos genéricos (COP, USD, USDT, BTC, ETH), asientos encadenados por hash, reversos, raíz de Merkle diaria, tasas, eventos crudos y conciliación.
- **Evidencia:** Archivo supabase/migrations/20261014000001_libro_v17.sql y sus pruebas en supabase/tests/esquema.test.sql .
- **Qué habilita:** Cuando pase las pruebas: registrar cada movimiento con evidencia verificable por un auditor sin publicar datos de clientes.
- **Qué falta o qué riesgo queda:** Sin probar: se perdió el acceso a la base de pruebas local. Hasta correr las pruebas no se puede afirmar que funcione.
- **Pasos del checklist:** 7.4, 7.17, 7.18

### Resultado 5. Plan unificado y checklists para seguir el avance

- **Qué se logró:** Un plan paso a paso que une la empresa y la tecnología, y dos checklists con estado por paso y este análisis de resultados. Las situaciones que aparecen en el camino se agregan en su fase.
- **Evidencia:** Docs/plan-paso-a-paso-proveedor-de-liquidez.md y la carpeta checklist Desarrollo De procesos/ .
- **Qué habilita:** Ver en un solo lugar qué bloquea qué, repartir el trabajo entre socios, abogado, contador y equipo técnico, y medir el avance.
- **Qué falta o qué riesgo queda:** El estado solo es confiable si se actualiza en cada avance; las marcas del navegador no llegan al repositorio.
- **Pasos del checklist:** Todo el documento.

### Resultado 6. Contexto desde Markdown, sincronizado solo

- **Qué se logró:** Cada HTML del proyecto tiene un .md gemelo, generado con un script. El contexto se lee del .md y el HTML queda para lo interactivo. La regla quedó en CLAUDE.md .
- **Evidencia:** 7 pares HTML y .md generados por scripts/sincronizar-md.py . Los .md de los documentos pesan entre el 30 % y el 65 % de su HTML (los checklists, cerca del 30 %), y sin restos de etiquetas.
- **Qué habilita:** Retomar el trabajo en una sesión nueva leyendo menos, y mantener los checklists y sus resultados sincronizados con un solo comando.
- **Qué falta o qué riesgo queda:** La sincronización es automática en dos puntos: al editar un HTML con Claude Code (gancho en .claude/settings.json ) y antes de cada commit (gancho de git en scripts/git-hooks ). Un HTML que se modifique por fuera de ambos, por ejemplo a mano en un editor, queda con su .md viejo hasta el próximo commit o hasta correr python scripts/sincronizar-md.py . El gancho de git se activa una vez por clon con git config core.hooksPath scripts/git-hooks . Los documentos largos (el estándar y el libro, de unos 70.000 caracteres) conviene buscarlos por sección.
- **Pasos del checklist:** 7.26, 7.27

# Proveedor de liquidez USDT (nombre provisional)

Antes llamado "Pasarela de pago USDT". Desde el 14 de octubre de 2026 es un **proveedor de liquidez independiente**: recibe USDT de pagadores de cualquier parte del mundo, los convierte y entrega pesos a sus clientes, y deja cada operación documentada para UIAF y DIAN. El nombre definitivo está por definir.

## Cómo leer el contexto (regla del 14 de octubre de 2026)

**El foco es el `.md`.** Cada HTML del proyecto tiene un `.md` gemelo con el mismo nombre. Para tener contexto se lee el `.md`, que es más corto y gasta menos tokens. El HTML se lee solo cuando haga falta (una parte interactiva, una guía de un paso, algo que el `.md` omite), y se avisa por qué.

- **La sincronización es automática.** Al editar un HTML con Write o Edit, un gancho de Claude Code (`.claude/settings.json` y `scripts/hook-sincronizar-md.py`) regenera su `.md`. Antes de cada commit, un gancho de git (`scripts/git-hooks/pre-commit`) los regenera otra vez y los incluye. El gancho de git se activa una vez por clon con `git config core.hooksPath scripts/git-hooks`.
- **Cuando no es automática:** si un HTML se modifica por Bash, un script o a mano en un editor, hay que correr `python scripts/sincronizar-md.py` en ese mismo turno. `python scripts/sincronizar-md.py --revisar` avisa cuáles están desactualizados.
- **Al actualizar un checklist**, el `.md` correspondiente se regenera siempre: lleva los pasos con su estado y el análisis de resultados. La guía de cada paso (sitio web y pasos) vive solo en el HTML.
- Los `.md` generados no se editan a mano: se pisan. Si hay que cambiar algo, se cambia el HTML y se regenera.
- Los documentos que nacen en Markdown (el plan, el contrato, `DECISIONES.md`, `NOTAS.md`) se editan directamente.
- Para un documento largo, buscar la sección con Grep en vez de leerlo entero.

## Contexto y fuentes (locales)

Leer en este orden, siempre los `.md`:

1. `Docs/plan-paso-a-paso-proveedor-de-liquidez.md`: **el plan vigente**, por fases, con el estado de cada paso (empresa y tecnología). Es el archivo de traspaso.
2. `DECISIONES.md`: qué se aceptó, qué se reemplazó y qué sigue abierto.
3. `checklist Desarrollo De procesos/checklist-proveedor-de-liquidez.md` y `checklist-libro-contable-blockchain.md`: estado paso a paso y análisis de resultados.
4. `Docs/contrato-api-v1.md`: contrato de la API (borrador).
5. Libro y proveedor de liquidez (definen este proyecto), en `Libro de contabilidad blockchain/`: `libro-contable-blockchain_v1.8_2026-10-14.md` y `proveedor-liquidez_v1.0_2026-10-14.md`.
6. `Docs/pasarela-usdt-colombia-estandar.md`: estándar técnico anterior (flujo, máquina de estados, reglas, Binance, modelo de datos, API, cumplimiento). **Parcialmente superado** por el enfoque nuevo; sigue valiendo para la máquina de estados y las reglas de pagos. Todo lo regulatorio (UIAF, DIAN, Binance) está **sin verificar**: lo validan un abogado y un contador.

## Enfoque (decidido por Juan el 14 de octubre de 2026)

- Por legalidad y para hacer las cosas bien, este proyecto es **independiente**: se comporta como **proveedor de liquidez** que presta servicio a otras compañías. Tendrá su propia empresa y su propia base de datos.
- **Estructura de las empresas:** DEVMINUS es la empresa principal (confirmado por Juan: "el nombre de la empresa es DEVMINUS"; los documentos nuevos la llaman "Minus"). Dentro de DEVMINUS está **Hellominus**, y Hellominus tiene como socio a **Zuhay** (el CRM de ventas).
- **Reparto de los pagos:**
  - Pagos en Colombia, directo en pesos colombianos: los maneja la **pasarela en pesos** correspondiente (la construye Zuhay).
  - Pagos en USDT desde cualquier parte del mundo: los maneja **este proyecto**.
- **Primeros clientes:** Hellominus y DEVMINUS. **Zuhay** es el CRM de ventas de la landing de Hellominus: por ahí se generan todas las ventas, y Zuhay y Hellominus son socios. Si Zuhay es cliente directo de la API o solo origina las ventas está por confirmar. Después pueden sumarse otras compañías.
- **Cómo entran y salen los pagos (decidido por Juan el 14 de octubre de 2026):** los pagos en USDT entran **directo al proveedor de liquidez**, y el proveedor hace la **dispersión en pesos desde una cuenta de Bancolombia**. Hellominus y DEVMINUS reciben pagos en cripto, pero quien dispersa es el proveedor. Es el modelo de mayor carga regulatoria (recibe y paga fondos de terceros): pendiente de validar con abogado y contador. **La dispersión va a la empresa cliente** (Hellominus o DEVMINUS), que reparte a sus anfitriones por su cuenta: el proveedor no paga a anfitriones ni a otros terceros.
- **Riesgo y confirmación (decidido por Juan el 14 de octubre de 2026):** el proveedor **asume la volatilidad**; confirma la reserva cuando el pago es válido en la red, con un **correo inmediato** a Hellominus; ese pago se registra de inmediato en el libro contable con hash, fecha y hora exacta; y el pagador debe haber hecho el KYC en un exchange (Binance u otro que cumpla los criterios del proveedor) y pagar desde su cuenta, a su nombre.
- Hellominus ya **no es el dueño ni el comercio** de este sistema: es un cliente más. Cada cliente es un proyecto (`project_id`) con su entidad legal (`legal_entity_id`).

**Reemplazado por este enfoque** (decisiones del 4 de octubre): "el dinero llega a la cuenta de Hellominus", "Hellominus es el `merchant`", "Hellominus es el primer proyecto y primera entidad legal de la pasarela" y "Hellominus construye la pasarela". El esquema de datos ya es multi-cliente, pero el contrato de la API v1 y varios textos hay que revisarlos contra la documentación nueva.

## Documentación nueva (en `Libro de contabilidad blockchain/`)

Cuatro documentos del 14 de octubre de 2026, copiados desde Descargas. Mandan sobre el estándar anterior donde se contradigan.

- En `Libro de contabilidad blockchain/`: `libro-contable-blockchain_v1.8` y `proveedor-liquidez_v1.0`. **Son los que definen este proyecto**: la ruta de 8 fases del proveedor de liquidez y, en la Parte II del libro, la constitución de la SAS independiente.
- En `productos Consultoría Pasarelas de pago Agentizadas (IA)/`: `plan-comercial_v2.0` y `niveles-cripto_v1.0`. Es material comercial de DEVMINUS (los tres niveles y sus precios): un producto de consultoría, **no** parte de lo que construye este proyecto.
- El modelo que describen es de **contraparte (RFQ)**: el cliente pide precio, recibe una cotización firme de 10 a 30 segundos, acepta y se liquida. No es el flujo "una dirección de depósito por orden" del estándar anterior. Cómo encaja el pago de un pagador final del mundo en ese modelo está abierto (`DECISIONES.md`).

## Checklists (en `checklist Desarrollo De procesos/`)

HTML para ir marcando el avance: `checklist-proveedor-de-liquidez.html` (el plan por fases) y `checklist-libro-contable-blockchain.html` (los 15 pasos del libro). Cada uno cierra con **Análisis de resultados**: un resultado numerado por cada avance real, con cinco campos fijos (qué se logró, evidencia, qué habilita, qué falta o qué riesgo queda, pasos del checklist). Cuando un paso cambie de estado, se actualiza en el arreglo `FASES` del archivo y se agrega su resultado. Los documentos originales no se mueven.

Cada paso tiene una **guía plegada** en el arreglo `GUIAS` del mismo HTML, con campos `e` (en simple), `s` (para qué sirve), `a` (antes necesitas), `d` (dónde), `u` (enlace), `p` (qué hacer), `x` (ejemplo que explica el concepto y qué significa cumplir el paso), `v` (evidencia que se guarda), `l` (listo cuando) y `o` (ojo con). Un paso nuevo en `FASES` necesita su entrada en `GUIAS`. Lo regulatorio de las guías (DIAN, UIAF, Supersociedades) es orientativo: lo confirma el contador o el abogado.

## Alcance

- Proyecto aparte: servicio y base de datos propios (Supabase propio), repositorio **privado**.
- Los clientes lo consumen solo por **API con llave por proyecto y webhooks firmados**. Es lo único que se comparte entre proyectos.
- Un pagador paga en USDT dentro de la aplicación del cliente (QR, dirección, monto, cuenta regresiva).

## Reglas de este proyecto

- **No construir el módulo de pagos antes de cerrar el modelo legal y el reparto del dinero** (Fase 0). Mientras tanto, solo el primer tramo independiente: entidad legal y proyecto, vinculación, bitácora encadenada por hash y expediente por operación.
- **Separación de DEVMINUS (libro v1.8, Parte II):** el proyecto es de los dos socios y, cuando exista, de la SAS del proveedor. No hay contrato de licencia con DEVMINUS. No se reutiliza código, agentes, módulos ni cuentas de DEVMINUS; el proyecto usa cuentas propias (correo, GitHub, Supabase, dominio) que se transfieren a la SAS al constituirla.
- **Mientras no exista la SAS**, no se pasa dinero de clientes por una cuenta personal de Binance ni por una cuenta bancaria personal.
- **Solo USDT al inicio** (decidido el 14 de octubre de 2026): BTC, ETH y dólares no se operan todavía, aunque el libro contable los soporte.
- Dinero siempre en enteros (centavos de COP, 6 decimales de USDT). Nunca flotantes.
- La tabla de transiciones de la orden no se modifica sin pruebas.
- Idempotencia por red y hash de transacción.
- Una revisión de cumplimiento no se explica al cliente.
- Claves de billeteras, llaves del exchange y datos bancarios: cifrado a nivel de aplicación, nunca en el repo ni en el chat. API de Binance sin permiso de retiros y con lista de IP.
- RLS desde el primer día. Datos personales bajo la Ley 1581 de 2012.
- Nada se sube ni se hace push sin que Juan lo pida. Repositorio: `github.com/juansecode2026-byte/pasarela-usdt` (privado). La protección de ramas no está activa (requiere GitHub Pro u organización): hasta entonces, nunca push directo a `main`; se trabaja en ramas.
- Este proyecto es su propia raíz: no leer archivos de Hellominus ni de Zuhay; se sincroniza por el contrato de la API.

## Estructura

Copia de la plantilla del laboratorio (ver `CLAUDE.md` del laboratorio). Carpetas vacías por decisión; el registro está en `DECISIONES.md`.

## Código determinístico vs. agentes

`scripts/` sin llamadas a Claude; `agentes-sdk/` con ellas. Un servicio que debe ser endpoint o proceso permanente (vigilar la cadena, webhooks) vive donde lo despliega su plataforma, y aquí se anota dónde y por qué.

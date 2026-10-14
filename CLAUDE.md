# Proveedor de liquidez USDT (nombre provisional)

Antes llamado "Pasarela de pago USDT". Desde el 14 de octubre de 2026 es un **proveedor de liquidez independiente**: recibe USDT de pagadores de cualquier parte del mundo, los convierte y entrega pesos a sus clientes, y deja cada operación documentada para UIAF y DIAN. El nombre definitivo está por definir.

## Contexto y fuentes (en `Docs/`, locales)

- `Docs/resumen-proyecto-hellominus.md`: contexto de Hellominus, arquitectura con Zuhay, decisiones tomadas, brechas y el paso a paso por fases (sección 7). Es el archivo de traspaso.
- `Docs/pasarela-usdt-colombia-estandar.html`: estándar técnico (flujo, máquina de estados, reglas, Binance, modelo de datos, API, cumplimiento, fases). Todo lo regulatorio (UIAF, DIAN, Binance) está **sin verificar**: lo validan un abogado y un contador.

## Enfoque (decidido por Juan el 14 de octubre de 2026)

- Por legalidad y para hacer las cosas bien, este proyecto es **independiente**: se comporta como **proveedor de liquidez** que presta servicio a otras compañías. Tendrá su propia empresa y su propia base de datos.
- **Estructura de las empresas:** DEVMINUS es la empresa principal. Dentro de DEVMINUS está **Hellominus**, y Hellominus tiene como socio a **Zuhay** (el CRM de ventas).
- **Reparto de los pagos:**
  - Pagos en Colombia, directo en pesos colombianos: los maneja la **pasarela en pesos** correspondiente (la construye Zuhay).
  - Pagos en USDT desde cualquier parte del mundo: los maneja **este proyecto**.
- **Primeros clientes:** Hellominus y Zuhay. Después pueden sumarse otras compañías.
- Hellominus ya **no es el dueño ni el comercio** de este sistema: es un cliente más. Cada cliente es un proyecto (`project_id`) con su entidad legal (`legal_entity_id`).

**Reemplazado por este enfoque** (decisiones del 4 de octubre): "el dinero llega a la cuenta de Hellominus", "Hellominus es el `merchant`", "Hellominus es el primer proyecto y primera entidad legal de la pasarela" y "Hellominus construye la pasarela". El esquema de datos ya es multi-cliente, pero el contrato de la API v1 y varios textos hay que revisarlos contra la documentación nueva.

## Documentación nueva (en `Libro de contabilidad blockchain/`)

Cuatro documentos del 14 de octubre de 2026, copiados desde Descargas. Mandan sobre el estándar anterior donde se contradigan.

- En `Libro de contabilidad blockchain/`: `libro-contable-blockchain_v1.7` y `proveedor-liquidez_v1.0`. **Son los que definen este proyecto**: la ruta de 8 fases del proveedor de liquidez y, en la Parte II del libro, la constitución de la SAS independiente.
- En `productos Consultoría Pasarelas de pago Agentizadas (IA)/`: `plan-comercial_v2.0` y `niveles-cripto_v1.0`. Es material comercial de Minus (los tres niveles y sus precios): un producto de consultoría, **no** parte de lo que construye este proyecto.
- El modelo que describen es de **contraparte (RFQ)**: el cliente pide precio, recibe una cotización firme de 10 a 30 segundos, acepta y se liquida. No es el flujo "una dirección de depósito por orden" del estándar anterior. Cómo encaja el pago de un pagador final del mundo en ese modelo está abierto (`DECISIONES.md`).

## Alcance

- Proyecto aparte: servicio y base de datos propios (Supabase propio), repositorio **privado**.
- Los clientes lo consumen solo por **API con llave por proyecto y webhooks firmados**. Es lo único que se comparte entre proyectos.
- Un pagador paga en USDT dentro de la aplicación del cliente (QR, dirección, monto, cuenta regresiva).

## Reglas de este proyecto

- **No construir el módulo de pagos antes de cerrar el modelo legal y el reparto del dinero** (Fase 0). Mientras tanto, solo el primer tramo independiente: entidad legal y proyecto, vinculación, bitácora encadenada por hash y expediente por operación.
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

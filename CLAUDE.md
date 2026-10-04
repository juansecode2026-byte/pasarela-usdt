# Pasarela de pago USDT (Colombia)

Servicio reutilizable multi-proyecto: el comercio cobra en pesos, el cliente paga en USDT, la plataforma convierte y dispersa a una cuenta bancaria, y cada operación queda documentada para UIAF y DIAN.

## Contexto y fuentes (en `Docs/`, locales)

- `Docs/resumen-proyecto-hellominus.md`: contexto de Hellominus, arquitectura con Zuhay, decisiones tomadas, brechas y el paso a paso por fases (sección 7). Es el archivo de traspaso.
- `Docs/pasarela-usdt-colombia-estandar.html`: estándar técnico (flujo, máquina de estados, reglas, Binance, modelo de datos, API, cumplimiento, fases). Todo lo regulatorio (UIAF, DIAN, Binance) está **sin verificar**: lo validan un abogado y un contador.

## Alcance

- Proyecto aparte: servicio y base de datos propios (Supabase propio), repositorio **privado**.
- Hellominus es el primer proyecto y la primera entidad legal (`project_id`, `legal_entity_id`). Zuhay es el segundo.
- Hellominus y Zuhay lo consumen solo por **API con llave por proyecto y webhooks firmados**. Es lo único que se comparte entre proyectos.
- El viajero paga dentro de Hellominus (QR, dirección, monto, cuenta regresiva).

## Reglas de este proyecto

- **No construir el módulo de pagos antes de cerrar el modelo legal y el reparto del dinero** (Fase 0). Mientras tanto, solo el primer tramo independiente: entidad legal y proyecto, vinculación, bitácora encadenada por hash y expediente por operación.
- Dinero siempre en enteros (centavos de COP, 6 decimales de USDT). Nunca flotantes.
- La tabla de transiciones de la orden no se modifica sin pruebas.
- Idempotencia por red y hash de transacción.
- Una revisión de cumplimiento no se explica al cliente.
- Claves de billeteras, llaves del exchange y datos bancarios: cifrado a nivel de aplicación, nunca en el repo ni en el chat. API de Binance sin permiso de retiros y con lista de IP.
- RLS desde el primer día. Datos personales bajo la Ley 1581 de 2012.
- Nada se sube ni se hace push sin que Juan lo pida.
- Este proyecto es su propia raíz: no leer archivos de Hellominus ni de Zuhay; se sincroniza por el contrato de la API.

## Estructura

Copia de la plantilla del laboratorio (ver `CLAUDE.md` del laboratorio). Carpetas vacías por decisión; el registro está en `DECISIONES.md`.

## Código determinístico vs. agentes

`scripts/` sin llamadas a Claude; `agentes-sdk/` con ellas. Un servicio que debe ser endpoint o proceso permanente (vigilar la cadena, webhooks) vive donde lo despliega su plataforma, y aquí se anota dónde y por qué.

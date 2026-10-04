# Hellominus: resumen del proyecto

Estado al 4 de octubre de 2026. Sirve para retomar el trabajo (otra sesión de Claude, otra persona o el proyecto de la pasarela) sin releer todo. Los datos que no verifiqué en el código están marcados como "por verificar".

## 1. Qué es

- Plataforma colombiana de estadías cortas, pensada sobre todo para **nómadas digitales** y abierta a todos (familias, personas mayores, viajeros de trabajo).
- Tres servicios: **hospedajes** por noches o meses, **planes de turismo** ligados a la estadía y **mercado** de productos locales con comisión.
- Los anfitriones tienen entre 15 y 40 propiedades cada uno.
- **Modelo**: Hellominus es la **vitrina** donde llegan los clientes. La transacción, la disponibilidad, las reservas y los pagos en pesos viven en **Zuhay**, el CRM de ventas del socio. Meta final: un SaaS entre las dos empresas.
- Diferenciales declarados en el README: anfitriones locales, precio claro, una persona que responde por WhatsApp. El README también dice "sin comisiones", lo cual contradice el mercado con comisión; hay que reconciliarlo.

## 2. Equipo y reglas de trabajo

- **Juan** (dicta por voz en español: interpretar palabras mal transcritas; ej. "nomás digitales" = nómadas digitales, "chupa base" = Supabase). **Gabriel** (GitHub `Monkeyotbz`, dueño del repo).
- Repositorio **público**: `github.com/Monkeyotbz/hellominus.com`. Rama principal `main`. Despliegue en **Vercel** (proyecto `hellominus-com` del equipo de Gabriel); cada rama genera una vista previa, protegida con inicio de sesión de Vercel.
- Interfaz y commits en **español**, commits en imperativo.
- **Nada se sube a `main` ni se hace push sin que Juan lo pida.** Se trabaja en ramas. El PR #3 (rama `juanse`) ya fue fusionado por Gabriel el 4 de octubre.
- Estilo de entrega: ofrecer opciones, no tocar originales, estética sobria y prolija, ortografía cuidada, datos de ejemplo siempre rotulados como tales.
- La carpeta `Docs/` es **local y está en `.gitignore`** porque el repo es público: estrategia, precios y datos de clientes no se suben.
- Estándares de código (skill `revisor-full-stack`): TypeScript, CSS Modules con tokens, Zustand de un solo dominio, `services/`, accesibilidad (foco visible, contraste AA, `prefers-reduced-motion`), RLS desde el primer día, ninguna clave secreta con prefijo `VITE_`.

## 3. Lo construido

### Stack y comandos
React 18, Vite 5, TypeScript, Tailwind (resto del sitio) y CSS Modules con tokens (portada), Zustand, React Router 6, Supabase. Comandos: `npm run dev` (puerto 5173), `npm run build`. `npm run lint` está roto de antes (error al cargar una regla de ESLint) y hay errores de tipos antiguos en `admin`, `ChatBot` y otros: no son del trabajo nuevo.

### Mapa de `src/`
- `home/`: portada nueva (un componente y un `.module.css` por sección), `data.ts` (datos de ejemplo), `store.ts` (Zustand: filtro de hospedajes y pestaña de planes/mercado), `services/homeService.ts` (lee hospedajes de Supabase con respaldo a los ejemplos), `hosts/` (página de anfitriones y su formulario), `tokens.css`.
- `site/`: layout, encabezado, pie y páginas del sitio (`hospedajes`, `tours`, `destinos`, `nosotros`, página de anfitrión por `slug`), `SettingsContext` (lee `site_settings`: WhatsApp, redes, anuncio).
- `account/` (viajero), `panel/` (anfitrión), `admin/` (equipo, incluye `TenantsAdmin`), `pages/` (login, registro, recuperar contraseña), `contexts/AuthContext.tsx`, `lib/` (`supabase.ts`, `queries.ts`, `i18n.ts`, `locale.tsx`, `contact.ts`), `types/supabase.ts`.
- `backend/`: un Express antiguo que no se despliega (no usarlo).

### Rutas
`/` portada, `/anfitriones` (crea el espacio del anfitrión, queda en revisión), `/hospedajes`, `/hospedajes/:slug`, `/tours`, `/tours/:slug`, `/destinos`, `/nosotros`, `/anfitrion/:slug` (página pública del anfitrión), `/cuenta/*` (viajes y perfil), `/panel/*` (anfitrión), `/admin/*` (equipo, incluye `/admin/espacios` para aprobar o suspender), `/login`, `/registro`, `/recuperar-contrasena`, `/restablecer-contrasena`. Login por rol: el equipo va a `/admin`, el anfitrión a `/panel`, el viajero a `/cuenta`.

### Portada (orden de secciones)
Encabezado de ancho completo con menú, buscador, logo y "Reservar" (segunda fila con Colombia, Estadías, Planes y mercado, Marketplace, Para nómadas, Blog); hero con video y barra de búsqueda (destino, fechas, huéspedes) y línea de confianza; cifras; hospedajes con filtros (ciudades y "para trabajar"); novedad destacada; cómo funciona; reseñas; destino del mes con video; "Completa tu estadía" (planes y mercado en pestañas con "Agregar"); banda de nómadas; cierre; preguntas frecuentes; blog; historia; franja de anfitriones; pie en columnas con boletín y redes. Botón flotante de WhatsApp, oculto mientras no haya número propio.
- Identidad: crema (`#F6F3EC`) y verde hoja (`#2F4B37`), Newsreader (títulos), Figtree (interfaz), Caveat (firma a mano), botones rectos, bandas con tonos alternados. La idea se tomó de Aman (estructura de encabezado y pie), Four Seasons (buscador sobre la foto) y 23 Living (blog), adaptadas, no copiadas.
- Textos, cifras, precios, reseñas y artículos son **de ejemplo** y están rotulados en pantalla. El buscador filtra datos de ejemplo; no consulta disponibilidad real.

### Base de datos (Supabase)
- Proyecto **`hellominus-web`**, referencia `vututvrdmtzjmoufuili`, región us-east-1, **plan gratuito** (máximo 2 proyectos activos por cuenta; se pausa por inactividad; la cuenta ya tiene otros proyectos activos).
- Migraciones en `supabase/migrations/` (001 a 013), todas con seguridad por filas:
  - 001 fundación (extensiones, helpers de políticas, idiomas), 002 perfiles y roles (`user`, `editor`, `admin`), 003 catálogo (destinos, hospedajes, tours, eventos, características e imágenes), 004 inmobiliario, 005 blog y testimonios, 006 leads y boletín, 007 reservas (`bookings`, eventos y documentos), 008 `site_settings`, 009 Storage (buckets `catalog`, `avatars`, `booking-docs`), 010 arreglo del trigger de rol.
  - **011** campos de nómadas en hospedajes (`wifi_mbps`, `min_nights`, `work_ready`). **012** datos de marca de Hellominus en `site_settings` (WhatsApp vacío, sin barra de anuncio). **013** multi-anfitrión: `tenants`, `tenant_members`, `products`, `product_images`, `tenant_id` en catálogo y reservas, referencias `HM-`, bandeja `integration_events` para Zuhay, funciones `create_tenant` y `set_tenant_status`.
- `supabase/seed-demo.sql`: catálogo de muestra (3 destinos, 6 hospedajes, 7 planes) con fotos libres en Storage.
- **Estado real de la base (por verificar)**: se aplicaron solo las migraciones 001 a 010 (con un archivo único que ya no existe) y la base está **sin datos**. Faltan 011, 012, 013 y el nuevo seed. El sitio lee con la clave `anon`; el formulario de anfitriones y el boletín guardaban bien contra esa base.
- Filas de prueba por borrar en el panel de Supabase: lead "PRUEBA borrar" y suscripción `prueba-esquema@example.com`.

### Variables de entorno
`.env` está ignorado por git. `.env.example` documenta `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `VITE_WHATSAPP_NUMBER` y `VITE_CONTACT_EMAIL`. En el `.env` local de Juan, la URL y la clave `anon` son reales; hay variables antiguas de candyCRM con valores de relleno que ya no se usan. **Vercel** debe tener las mismas dos variables de Supabase apuntando a `hellominus-web` (por verificar). Nunca poner la clave `service_role` ni la contraseña de la base en el chat, en el repo ni en variables `VITE_`.

## 4. Historia reciente (para orientarse en git)

- 1 al 2 de octubre: Juan construyó en la rama `juanse` la portada, la página de anfitriones, el catálogo propio y los datos de muestra; abrió el PR #3.
- 4 de octubre: Gabriel fusionó el PR y sumó tres commits: limpieza de todo lo heredado de "Turismo Colombia" (504 archivos, se borró `public/` y el catálogo viejo), marketplace multi-anfitrión con paneles y la nueva identidad en todo el sitio (88 archivos, migraciones 011 a 013), y protección de documentos internos.
- El historial de diseño vive en artefactos de claude.ai (privados): "Portada Completa" (`claude.ai/artifact/EMxvYbH8iFNE9Cji8U3YxR`, la referencia vigente), "Capturas Portada" (`KQssaJFJawKjKwbmkScaNA`), propuestas "Ordenar Secciones" (`RoxuSMPScmB3KSMeqQZPhz`) y "Confianza" (`HbKH6J1Tq1bHN3P7JXmr19`).

## 5. Arquitectura acordada con Zuhay

- **Hellominus guarda**: catálogo publicado, espacios de anfitriones y su aprobación, blog, boletín, leads, configuración del sitio y un **espejo de solo lectura** de las reservas (`bookings`).
- **Zuhay es la fuente de verdad de**: disponibilidad, precios por fecha, reservas, pagos en pesos (tarjeta, cuenta de ahorros), clientes y pagos a anfitriones. Zuhay escribe en `bookings` con la clave de servicio.
- **Conexión**: Hellominus consulta disponibilidad y cotización a Zuhay **desde el servidor**; envía la solicitud de reserva y recibe estados y pagos por webhook; avisa cambios de catálogo por `integration_events`. Las claves de Zuhay solo viven en el servidor.
- Se descartó construir un motor de disponibilidad propio (tablas de tarifas y bloqueos, restricción anti-cruce, importador iCal): lo resuelve Zuhay. candyCRM ya no se usa.
- El cuestionario para el equipo de Zuhay está en `Docs/lo-que-necesitamos-saber-de-zuhay.html` (24 preguntas en 5 bloques) y falta agregarle el bloque de pagos externos, cripto y SaaS.
- Por definir con el socio: quién es el maestro del catálogo, el identificador externo por propiedad, el modelo SaaS (marca, soporte, reparto de ingresos) y el contrato de la API.

## 6. Pasarela de pago con USDT

### Reparto y estado
- Zuhay construye la pasarela en pesos. **Hellominus configura la pasarela cripto (USDT)**. Todo es para las dos empresas. Juan quiere enfocarse en la cripto.
- Referencia: `Docs/pasarela-usdt-colombia-estandar.html`. Documento largo (más de 60.000 caracteres) que define un servicio reutilizable multi-proyecto; todo lo regulatorio (UIAF, DIAN, Binance) está **sin verificar** y debe validarlo un abogado y un contador.

### Qué define el estándar
- **Flujo**: alta del comercio (KYB y cuenta bancaria) → orden en pesos con cotización bloqueada (unos 15 min) y dirección de depósito única → pago del cliente → análisis de la billetera de origen y confirmaciones → conversión USDT a pesos en Binance → dispersión al comercio → webhook y asientos contables → conciliación diaria y reportes UIAF (mensual) y DIAN (anual).
- **Estados de la orden**: CREATED, AWAITING_PAYMENT, PAYMENT_DETECTED, CONFIRMING, CONFIRMED, CONVERTING, CONVERTED, SETTLING, SETTLED, más UNDERPAID, HELD_COMPLIANCE, REJECTED, REFUND_PENDING, REFUNDED, FAILED_CONVERSION, FAILED_PAYOUT, EXPIRED y CANCELLED.
- **Reglas**: dinero siempre en enteros (centavos de COP, 6 decimales de USDT), idempotencia por red y hash de transacción, tolerancias de pago de menos y de más, pago tardío se devuelve, una revisión de cumplimiento no se explica al cliente.
- **API**: `POST /v1/orders` con clave de idempotencia y llave por proyecto; webhooks firmados `order.*` con reintentos.
- **Piezas**: núcleo (órdenes, cadena, filtro de riesgo, cotizaciones, conversión, dispersiones, libro contable, cumplimiento, webhooks) más adaptadores intercambiables (red, liquidez, banco, KYC) y configuración por proyecto. Tablas con `project_id` y `legal_entity_id`.
- **Binance**: es un adaptador de liquidez; el retiro de pesos hay que asumirlo manual con doble aprobación; se dispersa desde el banco de la entidad operadora; riesgos de contraparte, deslizamiento y cierre de cuenta.
- **Modelos legales**: A proveedor directo (registro y reportes UIAF y DIAN, carga alta), B orquestador sobre un proveedor ya registrado, C cobro propio (la entidad vendedora recibe USDT por sus propias ventas).

### Decisiones tomadas
- Se construye como **proyecto aparte**: servicio y base de datos propios, **repositorio privado**, carpeta nueva copiada de `PLANTILLA/` y sesión de Claude separada. Hellominus lo consume por API y webhooks; el viajero paga **dentro de Hellominus** (QR, dirección, monto y cuenta regresiva). Hace falta un servidor que no se detenga para vigilar la cadena y un tercer proyecto de Supabase (plan Pro o pausar otro).
- Hellominus es el **primer proyecto y primera entidad legal** del sistema.
- **No construir el módulo de pagos antes de cerrar el modelo legal y el reparto del dinero.** Para el MVP se recomienda el modelo C o B. El plan completo y las razones del repositorio aparte están en la sección 7.

### Brechas del estándar frente a un marketplace de reservas
1. No hay reembolso por cancelación de una reserva ya liquidada (solo errores de pago).
2. No hay custodia del dinero hasta el check-in (el pago al anfitrión suele ser después de la llegada).
3. No hay reparto entre varias partes (anfitrión, Zuhay, Hellominus).
4. La retención de fechas en Zuhay debe durar más que la orden (confirmaciones de red).
5. Hay que decidir cuándo se confirma la reserva (pago válido en la cadena o pesos recibidos) y quién asume el riesgo de precio y el capital de trabajo.
6. Claves de billeteras y barrido a Binance son seguridad crítica.

### Decisiones abiertas
Quién figura como vendedor frente al viajero; si cada anfitrión cobra directo o todo entra a una cuenta y luego se reparte; qué entidad tiene la cuenta de Binance y del banco; proveedor de liquidez y de análisis de cadena; tratamiento tributario y facturación; si Zuhay puede registrar pagos externos (idempotente) y manejar cancelaciones de reservas pagadas con cripto.

### Primer tramo propuesto (independiente del modelo legal)
Entidad legal y proyecto (Hellominus primero), **vinculación** (alta y aprobación de quien cobra con estados, riesgo, límites, documentos cifrados y cuenta bancaria), **bitácora encadenada por hash** y **expediente por operación**. Los reportes UIAF y DIAN y el contador del proyecto, después de decidir el modelo. Datos personales bajo la Ley 1581 de 2012: cifrado, acceso mínimo y registro de quién ve qué.

## 7. Pasarela USDT: por qué un repositorio nuevo y paso a paso

### Por qué un repositorio nuevo (privado) y no una carpeta dentro de Hellominus

1. **Datos sensibles.** Guardará documentos de identidad, cuentas bancarias, resultados de análisis de billeteras y expedientes para la UIAF y la DIAN (Ley 1581 de 2012). El repositorio de Hellominus es **público**: ahí no puede vivir esa lógica ni su configuración (límites, umbrales, reglas).
2. **Acceso restringido y control de cambios.** El código que mueve dinero debe tener pocas personas con permiso, ramas protegidas, revisión obligatoria y pruebas obligatorias sobre la tabla de transiciones. El repositorio de Hellominus es de otra cuenta (Gabriel) y de más gente.
3. **Base de datos propia.** Con sus propias claves de cifrado, respaldos, retención mínima de 5 años y una bitácora que no se puede alterar. No se mezcla con el catálogo público de Hellominus.
4. **Despliegue y ciclo de vida distintos.** Necesita procesos que no se detienen (vigilar la cadena, conversiones y conciliación), que no caben en Vercel. Sus versiones deben poder revertirse sin tocar el sitio.
5. **Contener el daño.** Si se compromete la aplicación web pública, no deben quedar expuestas las claves de las billeteras ni las llaves del exchange. Los dos sistemas hablan solo por una API con llave y avisos firmados.
6. **Sirve a las dos empresas.** El objetivo es un SaaS entre Hellominus y Zuhay. Si viviera dentro de Hellominus, Zuhay dependería de un repositorio ajeno, y cada empresa necesita su propio proyecto y entidad legal dentro del mismo núcleo (`project_id`, `legal_entity_id`).
7. **Reutilización.** El estándar se diseñó como núcleo más adaptadores (red, liquidez, banco, KYC) y se empaqueta como paquete y plugin para sumar proyectos nuevos sin copiar código.
8. **Regla del laboratorio.** Cada proyecto es su propia raíz, copiada de `PLANTILLA/`, con su `CLAUDE.md`, `DECISIONES.md` y sesión de Claude aparte. Las sesiones no leen archivos de otro proyecto; se sincronizan por el **contrato de la API** y el archivo de traspaso.

### Paso a paso

**Fase 0. Decisiones previas (sin código; todo esto bloquea lo demás)**
1. Cerrar el **modelo legal** (A proveedor directo, B orquestador, C cobro propio) con un abogado y un contador. Recomendación para el MVP: C o B.
2. Definir quién figura como **vendedor** frente al viajero y qué entidad tiene la cuenta bancaria y la de exchange.
3. Definir el **reparto del dinero** (anfitrión, Zuhay, Hellominus), el momento de pago al anfitrión (¿tras el check-in?) y la **política de reembolso** de reservas canceladas.
4. Decidir **cuándo se confirma la reserva**: al detectar un pago válido en la cadena o al recibir los pesos.
5. Elegir **proveedor de liquidez** (Binance u otro), **análisis de billeteras**, **red** (TRON o Polygon) y **banco**; iniciar el KYB de la entidad.
6. Obtener las respuestas de Zuhay (`lo-que-necesitamos-saber-de-zuhay`) y el acuerdo del SaaS (marca, soporte, ingresos).

**Fase 1. Crear el proyecto**
7. Crear la carpeta desde `PLANTILLA/` (por ejemplo `pasarela-usdt`) y un **repositorio privado** en GitHub, con ramas protegidas y revisión de secretos.
8. Escribir su `CLAUDE.md` con el contexto de este resumen (el archivo de traspaso) y su `DECISIONES.md` con lo decidido en la Fase 0.
9. Crear su **proyecto de Supabase propio** (plan Pro, o pausar otro del plan gratuito) y elegir dónde corre el servicio permanente. Separar entornos de pruebas y producción, y guardar secretos en un gestor, nunca en el repositorio.

**Fase 2. Contrato y modelo de datos**
10. Redactar el **contrato de la API** (órdenes, comercios, liquidaciones y avisos firmados) y compartirlo con Hellominus y Zuhay. Es lo único que comparten los proyectos.
11. Escribir el esquema SQL (entidades legales, proyectos, comercios, órdenes, historial de estados, transacciones en cadena, análisis AML, cotizaciones, conversiones, dispersiones, libro contable, eventos de cumplimiento y bitácora) con seguridad por filas y cifrado a nivel de aplicación en datos bancarios y documentos.
12. Crear la configuración del primer proyecto, **hellominus**: redes, comisión, tolerancias, umbrales de revisión y entidad legal.

**Fase 3. Núcleo y vinculación (primer tramo, independiente del modelo legal)**
13. Máquina de estados de la orden **con pruebas** (la tabla de transiciones no se modifica sin pruebas).
14. Libro contable de doble partida con la restricción de que débitos y créditos cuadren, y bitácora encadenada por hash.
15. **Vinculación** de quien cobra: alta con KYB o KYC, validación de la cuenta bancaria, nivel de riesgo, límites y pantalla de revisión; **expediente por operación** (esqueleto).
16. API de órdenes con claves de idempotencia y llave por proyecto.

**Fase 4. Cadena**
17. Adaptador de la red elegida, primero en red de pruebas; dirección única por orden y custodia de claves.
18. Detector de depósitos idempotente (por red, hash y registro), con confirmaciones, reorganizaciones de cadena y cuarentena para pagos sin orden.
19. Análisis de la billetera de origen: si se marca, la orden pasa a revisión de cumplimiento sin avisar el motivo al cliente.

**Fase 5. Dinero**
20. Cotizaciones con tasa bloqueada (unos 15 minutos), clasificación del monto recibido (exacto, de menos, de más) y reglas de pago tardío y reembolso.
21. Conversión mediante el adaptador del exchange en modo de pruebas, con trabajos de conversión que se pueden reintentar y control de deslizamiento.
22. Dispersión bancaria (manual con doble aprobación al principio) y **conciliación diaria en tres vías**: cadena, libro y banco.

**Fase 6. Integración con Hellominus y Zuhay**
23. En **Hellominus**: un cliente liviano en el servidor que crea la orden y recibe los avisos firmados, y el paso de pago en pantalla (QR, dirección, monto, cuenta regresiva) con estado de la reserva. Mapea los avisos a `bookings.payment_status`.
24. En **Zuhay**: que pueda **registrar un pago externo** (idempotente, con la referencia de la reserva `HM-…`), manejar cancelaciones de reservas pagadas con cripto y retener la disponibilidad más tiempo que la orden.
25. Resolver las brechas del estándar: reembolso posterior a la liquidación, custodia hasta el check-in y reparto entre varias partes.

**Fase 7. Cumplimiento y declaración**
26. Casos en revisión, reporte de operaciones sospechosas y exportación del expediente (PDF y JSON con hash).
27. El **contador del proyecto**: libros por proyecto, clasificación de ingresos según el país del pagador, borradores de IVA, exógena y reportes. Nunca presenta nada por sí solo; lo revisa y firma un contador público.
28. Reportes UIAF y DIAN **según el modelo legal elegido**, con el calendario y las alertas (se confirman contra los anexos técnicos vigentes).

**Fase 8. Pruebas y salida**
29. Probar el ciclo completo en pruebas: pago exacto, de menos, de más, tardío, billetera marcada, falla de conversión, falla de dispersión y reorganización de cadena.
30. Revisar un expediente de prueba con el contador y el oficial de cumplimiento; revisión de seguridad y rotación de claves.
31. Salir a producción con **montos bajos durante una semana**, límites progresivos, monitoreo, alertas y manual de operación diaria.

**Fase 9. Estándar reutilizable**
32. Extraer configuración y adaptadores, empaquetar el núcleo y migrar un segundo proyecto (Zuhay) como prueba de reutilización.

### En Hellominus, mientras tanto (sin esperar a la pasarela)
- Aplicar migraciones 011 a 013 y el seed, configurar Vercel y WhatsApp, y completar el cuestionario de Zuhay.
- Preparar el espacio del paso de pago en la reserva y la tabla `bookings` como espejo de estados de pago.
- No construir el módulo de pagos dentro de este repositorio.

## 8. Pendiente, en orden

1. Aplicar en Supabase las migraciones 011, 012 y 013 y el nuevo `seed-demo.sql`, en ese orden y una sola vez cada una (013 falla si se repite). Borrar las filas de prueba.
2. Configurar en Vercel `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY` (proyecto `hellominus-web`), número de WhatsApp propio y, para cuentas, las URL en Authentication de Supabase. Crear un usuario administrador (rol `admin` en `profiles`).
3. Contestar el cuestionario de Zuhay y escribir el contrato de la API (consultas de disponibilidad y precio, solicitud de reserva, pago externo, webhooks, identificador externo).
4. Ficha de cada hospedaje, flujo de reserva con Zuhay, políticas reales (cancelación, términos, privacidad), cookies.
5. Fotos de alta resolución (las del proyecto son de unos 736 px), catálogo real, reseñas reales (no sembrar opiniones inventadas), probar en celular real.
6. Reparar ESLint y los errores de tipos antiguos; pruebas automáticas del flujo de reserva y pago.
7. Páginas hoy ancladas sin destino: Blog completo y Marketplace; revisar el README, que menciona carpetas ya borradas (`catalog/`).
8. Proyecto de la pasarela USDT: ver la sección 7 (por qué un repositorio nuevo y el paso a paso).

## 9. Archivos de referencia (todos en `Docs/`, locales)

- `pasarela-usdt-colombia-estandar.html`: estándar de la pasarela USDT.
- `lo-que-necesitamos-saber-de-zuhay.html`: cuestionario de integración.
- `tener en cuenta para la construcción de la landing.md`: seis criterios (objetivo único, mensaje en 5 segundos, CTA repetido, camino lógico, prueba de confianza, móvil y rapidez).
- `pendiente a revisar.html`: copia del artefacto "Casa Cabecera".
- `resumen-proyecto-hellominus.html` y este `.md`.

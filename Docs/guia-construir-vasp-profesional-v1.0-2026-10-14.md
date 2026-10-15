# Guía para construir un VASP profesional

> Versión en Markdown de `guia-construir-vasp-profesional-v1.0-2026-10-14.html`, generada con `scripts/sincronizar-md.py`. No editar a mano: se regenera desde el HTML. El HTML tiene las partes interactivas.

Proceso paso a paso para montar un Proveedor de Servicios de Activos Virtuales (PSAV): desde decidir si realmente lo necesitas, hasta operar con licencia, cumplimiento y tecnología de nivel institucional.

Versión 1.0
14 de octubre de 2026

No es asesoría legal ni fiscal. Los requisitos cambian por país y por año; valida cada fase con un abogado especializado en activos virtuales antes de invertir.

## 1. Qué es un VASP y cuándo aplica

### 1.1 Definición y actividades cubiertas

El estándar internacional del GAFI/FATF (Recomendación 15) llama VASP a toda persona o empresa que, como negocio y a nombre de terceros, realiza alguna de estas actividades con activos virtuales:

- Intercambio entre activos virtuales y moneda fiat, o entre distintos activos virtuales.
- Transferencia de activos virtuales por cuenta de clientes.
- Custodia o administración de activos virtuales o de las llaves que los controlan.
- Participación o provisión de servicios financieros ligados a la oferta o venta de un activo virtual.

La clave es **habitualidad + profesionalidad + terceros**: no se trata de usar cripto, sino de prestar servicios sobre cripto a otras personas.

### 1.2 ¿Recibir USDT para tu proyecto te hace VASP?

Normalmente no. Cobrar por tus propios productos o aceptar aportes para tu proyecto es recibir pagos, no prestar un servicio de activos virtuales. Te conviertes en VASP si empiezas a convertir, custodiar o mover cripto *de otros* como servicio (por ejemplo, una pasarela que cobra a comercios y les liquida, o una billetera con saldos de clientes).

### 1.3 Tres caminos posibles

| Camino | Qué implica | Cuándo conviene |
| --- | --- | --- |
| A. Integrador sobre un VASP licenciado | Usas la infraestructura y licencia de un tercero (procesador de pagos cripto, Binance Pay Merchant, custodio regulado) y tú construyes producto y experiencia encima. | Para validar mercado, bajo capital y rápido. Es el camino más lógico para empezar. |
| B. VASP con licencia propia | Tu empresa obtiene licencia o registro, cumple AML/CFT completo y asume custodia, riesgo y supervisión. | Cuando el volumen y el control del flujo justifican el costo fijo regulatorio. |
| C. Híbrido | Empiezas como integrador (A) y construyes el cumplimiento y la estructura en paralelo para migrar a (B). | Cuando ya hay tracción pero la regulación local aún no está definida. |

[↑ Volver al índice](#inicio)

## 2. Contexto: estándar global y situación en Colombia

El FATF extendió a los VASP las reglas de prevención de lavado de activos en 2019, incluida la llamada Travel Rule (compartir datos de originador y beneficiario en cada transferencia). En julio de 2026 publicó su séptima revisión anual de implementación de la Recomendación 15, que muestra avances en normas pero un licenciamiento efectivo todavía desigual entre países.

En Colombia, hasta donde alcanzan los análisis publicados a mediados de 2026, aún no existe una estructura que permita expedir licencias a PSAV. El Proyecto de Ley 510 de 2025 Cámara busca regularlos y ha avanzado en debates, pero conviene verificar su estado exacto antes de decidir. Mientras tanto, el cumplimiento se apoya en normas generales: obligaciones antilavado ante la UIAF, tratamiento tributario de la DIAN y conceptos de la Superintendencia Financiera y el Banco de la República.

Qué significa esto en la práctica

Operar en Colombia sin marco de licencia no te exime de cumplir. Lo prudente es construir *ya* el programa de cumplimiento como si la licencia existiera: así cuando llegue la regulación solo ajustas, no reconstruyes. Y considera una jurisdicción con licencia operativa si buscas autorización formal hoy.

[↑ Volver al índice](#inicio)

## 3. Paso a paso: de la idea a la operación

Las fases se solapan en la práctica, pero este orden evita gastar en tecnología antes de saber qué licencia necesitas.

### Fase 0Modelo de negocio y alcance

Decidir exactamente qué servicios prestarás, a quién y en qué países.

#### Pasos

1. Lista los servicios: ¿cobro, conversión cripto↔fiat, custodia, transferencias, intercambio?
2. Define el cliente: personas, comercios o empresas (B2B). B2B reduce volumen de KYC y riesgo.
3. Define activos permitidos (empieza solo con USDT/USDC) y redes (TRC20, ERC20, etc.).
4. Define los países de clientes y los países prohibidos.
5. Decide si custodias fondos de clientes o solo orquestas el pago (no-custodial).

**Entregable:** documento de alcance de una o dos páginas con servicios, clientes, activos, países y modelo custodial o no.

### Fase 1Jurisdicción

Elegir dónde se licencia y opera la entidad.

#### Pasos

1. Compara jurisdicciones por: existencia de licencia operativa, tiempos, capital mínimo, exigencia de presencia local (oficina, directores, oficial de cumplimiento) y reputación frente a bancos.
2. Verifica si el regulador exige que los clientes estén en esa jurisdicción o si permite servir a otros países.
3. Revisa el régimen tributario de la entidad y de los dividendos hacia los socios.
4. Consulta a un abogado local para confirmar el estado actual; los regímenes cambian rápido.

**Entregable:** matriz comparativa de 2–3 jurisdicciones y decisión justificada.

### Fase 2Estructura societaria

Crear la entidad que será titular de la licencia, los fondos y los contratos.

#### Pasos

1. Constituir la sociedad en la jurisdicción elegida (a menudo se separa la entidad regulada de la que desarrolla tecnología).
2. Definir socios, beneficiarios finales y directores; documentar origen de fondos de los fundadores.
3. Capitalizar según el mínimo exigido y el colchón operativo.
4. Firmar acuerdos entre socios, de propiedad intelectual y de servicios intragrupo.

**Entregable:** certificado de constitución, registro de accionistas y directores, estructura societaria en diagrama.

### Fase 3Licencia o registro

Obtener autorización formal del regulador.

#### Pasos

1. Preparar el paquete de solicitud: plan de negocio, proyecciones, organigrama, perfiles de directores, políticas AML/CFT, descripción tecnológica y de custodia.
2. Pasar la evaluación de idoneidad (*fit & proper*) de directores y accionistas relevantes.
3. Describir cómo cumplirás la Travel Rule y qué proveedor usarás; muchos reguladores lo exigen desde la solicitud.
4. Responder preguntas del regulador y ajustar documentos.
5. Recibir licencia y cumplir condiciones previas al inicio.

**Entregable:** licencia o registro vigente, con condiciones y calendario de reportes.

### Fase 4Programa de cumplimiento (AML/CFT)

Es el corazón de un VASP: sin esto no hay banco, licencia ni negocio sostenible.

#### Componentes

- **Evaluación de riesgos** de la empresa: clientes, productos, geografías, canales.
- **Oficial de cumplimiento** con independencia y recursos reales.
- **KYC/KYB**: verificación de identidad, beneficiario final, origen de fondos, listas sancionatorias y PEP.
- **Monitoreo de transacciones** con analítica on-chain (reglas, alertas, escalamiento).
- **Reportes** de operaciones sospechosas a la autoridad competente (en Colombia, la UIAF) en los plazos exigidos.
- **Travel Rule**: recolectar, verificar y transmitir datos de originador y beneficiario; puede apoyarse en un proveedor especializado.
- **Sanciones**: bloqueo de direcciones y contrapartes sancionadas.
- **Conservación de registros** por el periodo legal y capacitación periódica del personal.

**Entregable:** manual AML/CFT, matriz de riesgo, procedimientos KYC, plan de capacitación, proveedor de screening contratado.

### Fase 5Tecnología y seguridad

Construir una plataforma que proteja fondos y deje trazabilidad completa.

#### Pasos

1. **Arquitectura de custodia:** separar billeteras caliente y fría, multifirma o MPC, límites por operación, aprobaciones de varios roles.
2. **Libro mayor interno** con doble entrada y conciliación diaria contra saldos on-chain.
3. **Seguridad de aplicación:** gestión de llaves en HSM o KMS, secretos fuera del código, control de acceso por roles, registros inalterables.
4. **Pruebas:** pruebas de penetración externas y auditoría de código antes del lanzamiento.
5. **Resiliencia:** respaldos, plan de recuperación ante desastres y monitoreo 24/7.
6. **Integraciones:** analítica on-chain, KYC, Travel Rule, bancos y exchanges de liquidez.

**Entregable:** arquitectura documentada, informe de pentest, política de custodia y plan de continuidad.

### Fase 6Banca, liquidez y rampas fiat

Poder entrar y salir de pesos u otras monedas sin que te cierren la cuenta.

#### Pasos

1. Preparar un dossier para bancos: licencia, manual AML, estructura, perfil de clientes y volúmenes esperados.
2. Abrir cuentas con más de un banco; la dependencia de uno solo es riesgo operativo.
3. Contratar proveedores de liquidez (exchanges o market makers) con acuerdos escritos.
4. Separar fondos de clientes de fondos propios.

**Entregable:** cuentas operativas, contratos de liquidez, política de segregación de fondos.

### Fase 7Gobierno, seguros y políticas

Dar estructura de empresa regulada, no de startup improvisada.

#### Pasos

1. Comité de riesgos y cumplimiento con actas periódicas.
2. Políticas: seguridad de la información, gestión de incidentes, conflictos de interés, proveedores críticos, protección de datos, reclamos de clientes.
3. Términos y condiciones, aviso de riesgos y política de privacidad claros.
4. Seguro cuando esté disponible: ciberriesgo, crimen y responsabilidad profesional.
5. Auditoría independiente (financiera y de cumplimiento) con calendario fijo.

**Entregable:** carpeta de gobierno corporativo y calendario anual de revisiones.

### Fase 8Lanzamiento por etapas y operación continua

Salir al mercado limitando el riesgo mientras se aprende.

#### Pasos

1. **Piloto cerrado** con pocos clientes verificados, montos bajos y un solo activo.
2. Revisar alertas, falsos positivos y fricciones de KYC; corregir procedimientos.
3. **Apertura gradual** aumentando límites y países según resultados.
4. Operación continua: reportes regulatorios, revisión anual de riesgos, actualización de listas y reentrenamiento del personal.
5. Monitorear cambios regulatorios y del FATF; ajustar políticas.

**Entregable:** informe de piloto, plan de escalamiento y tablero de indicadores (alertas, reportes, incidentes, conciliaciones).

Orden recomendado

No construyas la plataforma completa antes de tener claros jurisdicción y licencia (fases 1 y 3). La tecnología depende de lo que el regulador exija en custodia, reportes y Travel Rule.

[↑ Volver al índice](#inicio)

## 4. Equipo mínimo y roles

| Rol | Responsabilidad |
| --- | --- |
| Representante legal / director | Responde ante el regulador y firma las políticas. |
| Oficial de cumplimiento | Dirige el programa AML/CFT, reporta operaciones sospechosas y capacita. |
| Responsable de riesgos | Evalúa riesgos operativos, de custodia y de contrapartes. |
| Líder técnico / seguridad | Arquitectura, custodia de llaves, pruebas y respuesta a incidentes. |
| Analista de cumplimiento | Revisa alertas, KYC y casos escalados. |
| Asesor legal externo | Licencias, contratos, cambios regulatorios. |
| Contador y auditor | Contabilidad de activos virtuales, tributación y auditoría independiente. |

En etapa temprana varios roles pueden recaer en pocas personas, pero el regulador suele exigir que el oficial de cumplimiento tenga independencia de las áreas comerciales.

[↑ Volver al índice](#inicio)

## 5. Checklist maestro

- Alcance de servicios, clientes, activos y países documentado.
- Jurisdicción elegida con concepto legal escrito.
- Entidad constituida, capitalizada y con beneficiarios finales identificados.
- Solicitud de licencia presentada y aprobada.
- Manual AML/CFT, matriz de riesgos y oficial de cumplimiento designado.
- Proveedores de KYC, analítica on-chain y Travel Rule contratados.
- Arquitectura de custodia con multifirma o MPC y límites operativos.
- Pentest externo y auditoría de código realizados.
- Cuentas bancarias y proveedores de liquidez operativos.
- Políticas de gobierno, términos y avisos de riesgo publicados.
- Seguros y auditoría independiente programados.
- Piloto cerrado ejecutado y lecciones incorporadas.

[↑ Volver al índice](#inicio)

## 6. Errores comunes

- **Construir antes de licenciar.** Se gasta en tecnología que luego no cumple lo que exige el regulador.
- **Subestimar cumplimiento.** Es el área con más costo recurrente y la que más cierra bancos y licencias.
- **Mezclar fondos** propios y de clientes, o personales y de la empresa.
- **Depender de un solo banco o un solo proveedor de liquidez.**
- **Ignorar la red del activo.** Un envío por la red equivocada es irrecuperable.
- **No documentar decisiones.** Ante una inspección, lo no documentado no existe.
- **Prometer lo que no se puede cumplir** en marketing (rendimientos, "sin riesgo", "regulado" sin serlo).

[↑ Volver al índice](#inicio)

## 7. Control de versiones

| Versión | Fecha | Cambios |
| --- | --- | --- |
| 1.0 | 14 oct 2026 | Versión inicial: definición de VASP, caminos posibles, contexto FATF y Colombia, proceso en 9 fases (0–8), equipo, checklist y errores comunes. |

[↑ Volver al índice](#inicio)

## 8. Fuentes consultadas

- [Asuntos Legales — Regulación cripto: el anacronismo regional que envuelve a Colombia](https://www.asuntoslegales.com.co/analisis/jorge-mendoza-duque-3770901/regulacion-cripto-el-anacronismo-regional-que-envuelve-a-colombia-4362438)
- [Forvis Mazars — Colombia da pasos firmes hacia la regulación de criptomonedas](https://www.forvismazars.com/co/es/acerca-de-nosotros/noticias-publicaciones-y-media/nuestras-noticias-y-publicaciones/governace-compliance-and-risk-management/regulacion-de-criptomonedas)
- [Holland & Knight — Proyecto de ley en Colombia busca regular los activos virtuales](https://www.hklaw.com/en/insights/publications/2025/02/proyecto-de-ley-en-colombia-busca-regular-los-activos-virtuales)
- [CoinSwitch — Séptima revisión del FATF sobre la Recomendación 15](https://coinswitch.co/building-blocks/what-does-fatfs-7th-update-on-r15-implementation-mean-for-the-public-and-private-sectors/)
- [Elliptic — What is the Travel Rule?](https://www.elliptic.co/blockchain-basics/what-is-the-travel-rule)

[↑ Volver al índice](#inicio)

Este documento es una guía de referencia general. No sustituye asesoría legal, fiscal, contable ni de cumplimiento profesional; los requisitos exactos dependen de la jurisdicción y cambian con frecuencia. Verifica el estado vigente de la regulación antes de tomar decisiones.

# Checklist: guía para construir un VASP profesional

> Versión en Markdown de `checklist-guia-vasp-profesional.html`, generada con `scripts/sincronizar-md.py`. No editar a mano: se regenera desde el HTML. La guía de cada paso (sitio y pasos) y la marcación interactiva están solo en el HTML.

Versión en checklist de Docs/guia-construir-vasp-profesional-v1.0-2026-10-14 : proceso en 9 fases para montar un proveedor de servicios de activos virtuales, desde decidir si lo necesitas hasta operar con cumplimiento y tecnología institucional, más el equipo mínimo. Cada guía indica qué pasos del plan cubre.

Actualizado: 14 de octubre de 2026 · Es una guía general: no es asesoría legal ni fiscal y los requisitos cambian por país y por año.

**Avance registrado:** 1 hechos y 6 en curso, de 53 pasos.

Leyenda: `[x]` hecho · `[~]` en curso · `[ ]` pendiente. Cada paso trae su responsable.

## Fase 0. Modelo de negocio y alcance (1/5)

_Decidir qué servicios se prestan, a quién y en qué países. Entregable: documento de alcance de una o dos páginas._

- [x] **V0.1** Listar los servicios que se prestarán: cobro, conversión de cripto a pesos, custodia, transferencias, intercambio — _Socios_
- [~] **V0.2** Definir el cliente: personas, comercios o empresas (B2B) — _Socios_
- [~] **V0.3** Definir los activos permitidos (empezar solo con USDT) y las redes — _Socios_
- [ ] **V0.4** Definir los países de los pagadores y los países prohibidos — _Socios y abogado_
- [~] **V0.5** Decidir si se custodian fondos de clientes o solo se orquesta el pago, y dejar el documento de alcance escrito — _Socios_

## Fase 1. Jurisdicción (0/4)

_Dónde se licencia y opera la entidad. Hoy los documentos del proyecto asumen una SAS colombiana, y en Colombia no hay licencia disponible._

- [ ] **V1.1** Comparar jurisdicciones: licencia operativa, tiempos, capital mínimo, presencia local exigida y reputación frente a bancos — _Socios y abogado_
- [ ] **V1.2** Verificar si el regulador exige que los clientes estén en esa jurisdicción o permite servir a otros países — _Abogado_
- [ ] **V1.3** Revisar el régimen tributario de la entidad y de los dividendos hacia los socios — _Contador_
- [ ] **V1.4** Consultar a un abogado local el estado actual y dejar una matriz de 2 o 3 jurisdicciones con la decisión justificada — _Abogado_

## Fase 2. Estructura societaria (0/4)

_La entidad que será titular de la licencia, los fondos y los contratos. Equivale a la fase 1 del plan._

- [ ] **V2.1** Constituir la sociedad en la jurisdicción elegida; separar la entidad regulada de la que desarrolla tecnología si conviene — _Abogado_
- [ ] **V2.2** Definir socios, beneficiarios finales y directores, y documentar el origen de fondos de los fundadores — _Abogado_
- [ ] **V2.3** Capitalizar según el mínimo exigido y el colchón operativo — _Socios_
- [ ] **V2.4** Firmar los acuerdos entre socios, de propiedad intelectual y de servicios entre empresas; dejar el certificado, el registro de accionistas y el diagrama de estructura — _Abogado_

## Fase 3. Licencia o registro (0/5)

_En Colombia no hay hoy una estructura que expida licencias a PSAV (proyecto de ley 510 de 2025). Se prepara todo como si existiera._

- [ ] **V3.1** Preparar el paquete de solicitud: plan de negocio, proyecciones, organigrama, perfiles de directores, políticas AML, descripción tecnológica y de custodia — _Socios y abogado_
- [ ] **V3.2** Pasar la evaluación de idoneidad (fit and proper) de directores y accionistas relevantes — _Abogado_
- [ ] **V3.3** Describir cómo se cumplirá la Travel Rule y con qué proveedor — _Oficial de cumplimiento_
- [ ] **V3.4** Responder las preguntas del regulador y ajustar los documentos — _Abogado_
- [ ] **V3.5** Recibir la licencia o registro y cumplir sus condiciones previas — _Socios_

## Fase 4. Programa de cumplimiento (AML/CFT) (0/8)

_Es el corazón de un VASP: sin esto no hay banco, licencia ni negocio sostenible. Equivale a la fase 3 del plan._

- [ ] **V4.1** Evaluación de riesgos de la empresa: clientes, productos, geografías y canales — _Oficial de cumplimiento_
- [ ] **V4.2** Oficial de cumplimiento con independencia y recursos reales — _Socios_
- [ ] **V4.3** KYC y KYB: identidad, beneficiario final, origen de fondos, listas sancionatorias y personas expuestas políticamente — _Oficial de cumplimiento_
- [ ] **V4.4** Monitoreo de transacciones con analítica on-chain: reglas, alertas y escalamiento — _Oficial de cumplimiento_
- [ ] **V4.5** Reporte de operaciones sospechosas a la UIAF en los plazos exigidos — _Oficial de cumplimiento_
- [ ] **V4.6** Travel Rule: recolectar, verificar y transmitir datos de originador y beneficiario — _Oficial de cumplimiento_
- [ ] **V4.7** Sanciones: bloqueo de direcciones y contrapartes sancionadas — _Oficial de cumplimiento_
- [ ] **V4.8** Conservación de registros por el período legal y capacitación periódica; dejar el manual AML/CFT, la matriz de riesgo y el plan de capacitación — _Oficial de cumplimiento_

## Fase 5. Tecnología y seguridad (0/6)

_Una plataforma que protege los fondos y deja trazabilidad completa. Equivale a la fase 7 del plan._

- [ ] **V5.1** Arquitectura de custodia: billeteras caliente y fría, multifirma o MPC, límites por operación y aprobaciones de varios roles — _Equipo técnico_
- [~] **V5.2** Libro mayor interno con doble entrada y conciliación diaria contra los saldos on-chain — _Equipo técnico_
- [~] **V5.3** Seguridad de aplicación: llaves en HSM o KMS, secretos fuera del código, control de acceso por roles y registros inalterables — _Equipo técnico_
- [ ] **V5.4** Pruebas: pruebas de penetración externas y auditoría de código antes del lanzamiento — _Equipo técnico_
- [ ] **V5.5** Resiliencia: respaldos, plan de recuperación ante desastres y monitoreo permanente — _Equipo técnico_
- [ ] **V5.6** Integraciones: análisis on-chain, KYC, Travel Rule, bancos y exchanges de liquidez; dejar la arquitectura documentada y el plan de continuidad — _Equipo técnico_

## Fase 6. Banca, liquidez y rampas fiat (0/4)

_Entrar y salir de pesos sin que cierren la cuenta. Equivale a las fases 4 y 5 del plan._

- [ ] **V6.1** Preparar el dossier para bancos: licencia, manual AML, estructura, perfil de clientes y volúmenes esperados — _Gerencia_
- [ ] **V6.2** Abrir cuentas con más de un banco — _Gerencia_
- [ ] **V6.3** Contratar proveedores de liquidez (exchanges o market makers) con acuerdos escritos — _Tesorería_
- [ ] **V6.4** Separar los fondos de clientes de los fondos propios y dejar la política de segregación — _Gerencia_

## Fase 7. Gobierno, seguros y políticas (0/5)

_Dar estructura de empresa regulada y no de startup improvisada._

- [ ] **V7.1** Comité de riesgos y cumplimiento con actas periódicas — _Socios_
- [ ] **V7.2** Políticas: seguridad de la información, gestión de incidentes, conflictos de interés, proveedores críticos, protección de datos y reclamos de clientes — _Oficial de cumplimiento y abogado_
- [ ] **V7.3** Términos y condiciones, aviso de riesgos y política de privacidad claros — _Abogado_
- [ ] **V7.4** Seguro cuando esté disponible: ciberriesgo, crimen y responsabilidad profesional — _Gerencia_
- [ ] **V7.5** Auditoría independiente (financiera y de cumplimiento) con calendario fijo — _Contador_

## Fase 8. Lanzamiento por etapas y operación continua (0/5)

_Salir al mercado limitando el riesgo mientras se aprende. Equivale a la fase 8 del plan._

- [ ] **V8.1** Piloto cerrado con pocos clientes verificados, montos bajos y un solo activo — _Todos_
- [ ] **V8.2** Revisar alertas, falsos positivos y fricciones de KYC, y corregir procedimientos — _Oficial de cumplimiento_
- [ ] **V8.3** Apertura gradual: aumentar límites y países según los resultados — _Socios_
- [ ] **V8.4** Operación continua: reportes regulatorios, revisión anual de riesgos, actualización de listas y reentrenamiento del personal — _Oficial de cumplimiento_
- [ ] **V8.5** Monitorear cambios regulatorios y del FATF; dejar el informe de piloto, el plan de escalamiento y el tablero de indicadores — _Abogado_

## Equipo mínimo y roles (0/7)

_En etapa temprana varios roles pueden recaer en pocas personas, pero el oficial de cumplimiento debe tener independencia de las áreas comerciales._

- [ ] **V9.1** Representante legal o director: responde ante el regulador y firma las políticas — _Socios_
- [ ] **V9.2** Oficial de cumplimiento: dirige el programa AML/CFT, reporta operaciones sospechosas y capacita — _Socios_
- [ ] **V9.3** Responsable de riesgos: evalúa riesgos operativos, de custodia y de contrapartes — _Socios_
- [~] **V9.4** Líder técnico y de seguridad: arquitectura, custodia de llaves, pruebas y respuesta a incidentes — _Equipo técnico_
- [ ] **V9.5** Analista de cumplimiento: revisa alertas, KYC y casos escalados — _Oficial de cumplimiento_
- [ ] **V9.6** Asesor legal externo: licencias, contratos y cambios regulatorios — _Socios_
- [ ] **V9.7** Contador y auditor: contabilidad de activos virtuales, tributación y auditoría independiente — _Socios_

## Análisis de resultados

Cada vez que se complete un paso o un grupo de pasos con un efecto real, se agrega aquí un resultado numerado. Cada resultado responde las mismas cinco preguntas, para que se vea qué se logró y no solo qué tareas se hicieron.

### Ejemplo de cómo leer un resultado

- **Qué se logró:** Se aprobó el documento de alcance de dos páginas: servicios, clientes, activo USDT, red y países permitidos.
- **Evidencia:** El documento firmado por los socios y guardado en el repositorio.
- **Qué habilita:** Comparar jurisdicciones y preparar el paquete de solicitud (fases 1 y 3).
- **Qué falta o qué riesgo queda:** Los países prohibidos todavía no están definidos.
- **Pasos del checklist:** V0.1 a V0.5.

### Resultado 1. Guía VASP incorporada y comparada con el proyecto

- **Qué se logró:** La guía se copió a Docs/ , se generó su .md y se convirtió en este checklist de 53 pasos, con el estado de cada uno frente a lo que ya tiene el proyecto: 1 hecho, 6 en curso y 46 pendientes.
- **Evidencia:** Docs/guia-construir-vasp-profesional-v1.0-2026-10-14.html y su .md , y este checklist con sus guías.
- **Qué habilita:** Ver qué le falta al proyecto para parecerse a un VASP profesional. En cada guía se indica qué pasos del plan cubre.
- **Qué falta o qué riesgo queda:** 1. Según la guía, convertir y mover cripto de otros como servicio hace de la empresa un VASP: este proyecto lo es (equivale al modelo A del estándar). 2. La guía pide comparar jurisdicciones antes de licenciar, y los documentos del proyecto asumen una SAS colombiana, donde no hay licencia disponible hoy. 3. Pasos que el plan no tenía y se agregaron: países permitidos y prohibidos (0.15), comparación de jurisdicciones (0.16), gobierno con comité, políticas, seguros y auditoría independiente (6.7), prueba de penetración externa y auditoría de código (7.32), y plan de recuperación con monitoreo permanente (7.33). 4. La guía es general y no es asesoría legal.
- **Pasos del checklist:** Todo el documento.

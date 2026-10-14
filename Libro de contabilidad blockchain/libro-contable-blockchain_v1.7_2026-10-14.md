# Libro Contable Blockchain

> Versión en Markdown de `libro-contable-blockchain_v1.7_2026-10-14.html`, generada con `scripts/sincronizar-md.py`. No editar a mano: se regenera desde el HTML. El HTML tiene las partes interactivas.

Minus · Guía de construcción

# Libro contable con blockchain: paso a paso para la trazabilidad de transacciones cripto y fiat

Cómo construir un libro contable de partida doble, inalterable y verificable con blockchain, que registre y concilie cada movimiento en USDT, Bitcoin, Ethereum, USD y COP, y que alimente los reportes a la UIAF y la DIAN.

USDT · TRC-20 / ERC-20
Bitcoin
Ethereum
USD
COP

Versión
:   v1.7

Fecha
:   14 oct 2026

Pasos
:   15

Plazo estimado
:   10–14 semanas

A · Fundamentos

## Qué vamos a construir

Un libro contable de partida doble donde cada asiento queda encadenado al anterior con una huella criptográfica (hash). Una vez al día, la huella del libro completo se publica en una blockchain pública. Así cualquier auditor, banco o autoridad puede verificar que el libro no fue modificado, sin que se publique ningún dato de clientes.

### Inalterable

Ningún asiento se edita ni se borra. Los errores se corrigen con un asiento de reverso.

### Verificable

La huella diaria anclada en blockchain prueba que el libro no cambió desde esa fecha.

### Trazable

Cada asiento enlaza con su transacción on-chain, su movimiento bancario y su cliente.

### Privado

Los datos contables y de clientes viven en tu base de datos. A la blockchain solo sale una huella.

**Decisión de diseño clave**

No se registra la contabilidad completa dentro de una blockchain pública. Sería costoso, lento y expondría datos de clientes, lo que choca con la protección de datos y la reserva comercial. El modelo correcto es: libro privado + cadena de hashes + anclaje público.

B · Fundamentos

## Arquitectura en capas

1 · Fuentes

Blockchains (Bitcoin, Ethereum, Tron), Binance OTC, bancos (COP y USD), TRM del Banco de la República.

↓

2 · Captura

Conectores que leen transacciones confirmadas y las guardan crudas, sin modificar, como evidencia.

↓

3 · Motor contable

Reglas que convierten cada evento en un asiento de partida doble, valorado en COP.

↓

4 · Libro inalterable

Asientos solo de inserción, cada uno con el hash del anterior.

↓

5 · Anclaje

Raíz de Merkle diaria publicada en Bitcoin y/o Ethereum.

↓

6 · Control y reportes

Conciliación, alertas, reportes UIAF, CARF y exógena, panel para gerencia y auditoría.

| Componente | Opción sugerida | Por qué |
| --- | --- | --- |
| Base de datos | PostgreSQL (Supabase) | Transacciones ACID, permisos por fila, funciones en servidor y ya está en el stack. |
| Procesos de captura | Funciones programadas (edge functions o workers) | Consultan cada red y fuente en intervalos fijos. |
| Acceso a blockchains | Proveedor de nodos (por ejemplo Alchemy, Infura, QuickNode, TronGrid) o nodo propio | Lectura confiable sin operar infraestructura al inicio. |
| Anclaje en Bitcoin | OpenTimestamps | Estándar abierto para sellar hashes en Bitcoin sin pagar una transacción por cada sello. |
| Anclaje en Ethereum | Transacción diaria con la raíz en el campo de datos, o un contrato simple de registro | Verificación inmediata en cualquier explorador. |

C · Fundamentos

## Herramientas necesarias para la trazabilidad en la blockchain

Trazabilidad significa poder seguir cada transacción de wallet a wallet y probar de dónde vino y hacia dónde fue. Para lograrlo se necesitan cuatro tipos de herramientas: exploradores para ver y verificar, APIs y nodos para leer de forma automática, analítica para medir el riesgo de cada wallet, y sellado para probar que el registro no cambió.

### 1. Mapa de herramientas por función

| Función | Herramientas | Uso en el libro | Cuándo |
| --- | --- | --- | --- |
| Verificar una transacción a mano | Etherscan, Tronscan, mempool.space, Blockchair | Segunda fuente y evidencia visual de cada operación. | Desde el inicio |
| Leer transacciones de forma automática | API de Etherscan, TronGrid, API Esplora (Blockstream o mempool.space), proveedores de nodos | Alimentan la tabla de eventos crudos. | Desde el inicio |
| Leer el exchange | API de Binance con llave de solo lectura | Depósitos, retiros, operaciones OTC y comisiones. | Desde el inicio |
| Tasas de cambio | TRM oficial y una API de precios de cripto | Tabla de tasas con fuente y fecha. | Desde el inicio |
| Base de datos y automatización | PostgreSQL (Supabase), funciones programadas | Libro, cadena de hashes y conectores. | Desde el inicio |
| Sellar y anclar | SHA-256, OpenTimestamps, transacción en Ethereum | Anclaje diario de la raíz de Merkle. | Desde el inicio |
| Generar los archivos de Excel | openpyxl (Python) o SheetJS (JavaScript) | Archivos de control de lotes y ventas. | Desde el inicio |
| Medir riesgo de wallets | Chainalysis, Elliptic o TRM Labs | Puntaje de riesgo, sanciones y seguimiento de fondos. | Antes de operar con clientes |
| Custodia de fondos | Safe, Fireblocks, BitGo, billeteras de hardware | Sistema aparte del libro. | Antes de operar con clientes |
| Nodos propios | Bitcoin Core, cliente de Ethereum | Independencia de terceros. | Con volumen |

### 2. Exploradores de blockchain: ver y verificar

Un explorador es una página pública donde se pega el hash de una transacción y se ve su estado, origen, destino, monto y comisión. Sirven para verificar a mano y para guardar evidencia.

### Ethereum · Etherscan

- Transferencias de ETH y de tokens ERC-20, incluido USDT en Ethereum.
- Eventos `Transfer`, gas pagado, bloque y confirmaciones.
- Etiquetas de direcciones conocidas, como exchanges.
- Tiene API para consulta automática.

### Tron · Tronscan

- Transferencias de USDT en TRC-20, la red más usada para USDT.
- Muestra el contrato del token y el costo en energía o TRX.
- Consulta de saldo e historial por wallet.
- La API de Tron se consume con TronGrid.

### Bitcoin · mempool.space o Blockstream

- Entradas y salidas de cada transacción (modelo UTXO).
- Comisión de minería y confirmaciones.
- Ambos ofrecen API pública basada en Esplora.

### Varias redes · Blockchair

- Consulta de varias blockchains desde un solo sitio.
- Útil como tercera fuente cuando dos explorers no coinciden.

Los exploradores públicos son para verificar. La captura oficial que alimenta el libro debe venir de una API o un nodo contratado, no de copiar datos a mano.

### 3. APIs y nodos: leer automáticamente

- **Ethereum y tokens ERC-20:** API de Etherscan con clave propia, o un proveedor de nodos como Alchemy, Infura o QuickNode.
- **Tron y USDT TRC-20:** TronGrid.
- **Bitcoin:** API Esplora de Blockstream o mempool.space.
- **Avisos en tiempo real:** webhooks o suscripciones a eventos de los proveedores de nodos, para enterarse de un depósito al confirmarse.
- **Nodo propio:** Bitcoin Core y un cliente de Ethereum cuando el volumen justifique no depender de terceros.

Los planes, límites de consulta y precios cambian con frecuencia. Validarlos con cada proveedor antes de contratar.

### 4. Analítica on-chain: medir el riesgo de cada wallet

Chainalysis, Elliptic y TRM Labs son proveedores comerciales que puntúan el riesgo de una dirección y siguen los fondos varios saltos hacia atrás. Se elige uno.

| Qué permite | Cómo se usa en el libro |
| --- | --- |
| Puntaje de riesgo de una wallet | Se consulta cuando un cliente registra una wallet y antes de aceptar cada depósito grande. |
| Exposición a sanciones, mezcladores y mercados ilícitos | Una alerta bloquea la contabilización automática y envía el caso al oficial de cumplimiento. |
| Seguimiento de fondos hacia atrás | Permite documentar el origen de los fondos de un cliente nuevo. |
| Monitoreo continuo de wallets | Avisa si una wallet ya registrada cambia de perfil de riesgo. |

### 5. Exchange, banco y tasas

- **Binance:** API con llave de solo lectura para depósitos, retiros, operaciones y comisiones. Nunca con permiso de retiro.
- **Bancos:** extractos por API si el banco la ofrece, o archivo diario estandarizado.
- **TRM:** la oficial, que publican la Superintendencia Financiera y el Banco de la República.
- **Precios de cripto:** una fuente única definida, por ejemplo el precio de ejecución en Binance o un índice con API. Cada tasa se guarda con su fuente y su hora.

### 6. Sellado y anclaje

- **SHA-256:** la huella de cada asiento y de cada archivo de Excel.
- **OpenTimestamps:** sella la raíz de Merkle del día en Bitcoin.
- **Transacción en Ethereum:** publica la misma raíz en el campo de datos, para verificarla en Etherscan.

### 7. Desarrollo y automatización

- **Base de datos:** PostgreSQL en Supabase, con permisos de solo inserción en las tablas del libro.
- **Librerías de lectura:** ethers.js o web3.py para Ethereum, TronWeb para Tron y bitcoinjs-lib para Bitcoin.
- **Procesos programados:** funciones que consultan cada red y fuente a intervalos fijos.
- **Excel:** openpyxl o SheetJS para generar y sellar los archivos de control.

### 8. Custodia: un sistema aparte

Las herramientas de custodia mueven fondos. El libro solo lee. Se mantienen separados.

- **Safe:** billetera multifirma para Ethereum y redes compatibles.
- **Fireblocks o BitGo:** custodia institucional con MPC y políticas de aprobación.
- **Billeteras de hardware:** opción para tesorería pequeña, siempre con más de una persona involucrada.

Ninguna llave privada ni frase semilla se pega nunca en una herramienta de consulta, en el libro ni en el Excel. Para leer una wallet basta con su dirección pública.

### 9. Cómo se traza una transacción de wallet a wallet

1. **Tomar el hash** de la transacción que llegó al sistema.
2. **Abrirlo en el explorador** de la red que corresponde: Etherscan, Tronscan o mempool.space.
3. **Confirmar el estado:** que esté confirmada y que haya pasado el número de confirmaciones definido.
4. **Identificar origen y destino** y clasificarlos: wallet propia, wallet de cliente, exchange u otra.
5. **Validar el token:** que el contrato sea el oficial. Los contratos de USDT se verifican contra la lista oficial de Tether antes de configurarlos.
6. **Revisar el riesgo** de la wallet de origen con la herramienta de analítica.
7. **Seguir hacia atrás** si el origen es dudoso, hasta llegar a un exchange identificado o a un origen documentado.
8. **Guardar la evidencia:** hash, enlace al explorador, respuesta de la API, bloque, hora y confirmaciones.
9. **Enlazar con el libro:** el ID del asiento, el lote de compra o la venta en el archivo de Excel.

### 10. Evidencia que se guarda por transacción

| Dato | Para qué |
| --- | --- |
| Hash de la transacción y red | Identificar la operación sin ambigüedad. |
| Bloque, hora y confirmaciones | Probar cuándo ocurrió y que estaba confirmada. |
| Dirección de origen y de destino | Trazabilidad de wallet a wallet. |
| Contrato del token | Demostrar que no era un token falso. |
| Respuesta cruda de la API | Evidencia que no depende de una captura de pantalla. |
| Enlace al explorador | Verificación rápida por un auditor. |
| Puntaje de riesgo y fecha de consulta | Demostrar la debida diligencia. |

### 11. Criterios para elegir cada herramienta

- Cubre las redes que usamos: Bitcoin, Ethereum y Tron.
- Tiene API estable y permite exportar los datos.
- El costo se sostiene con el volumen esperado.
- No obliga a entregar datos de clientes más allá de direcciones públicas.
- Deja historial de consultas que sirva en una auditoría.

### 12. Orden de adopción

| Etapa | Herramientas |
| --- | --- |
| Desde el inicio | Exploradores, APIs de lectura, API de Binance, TRM, Supabase, SHA-256, OpenTimestamps y generación de Excel. |
| Antes de operar con clientes | Analítica on-chain comercial y custodia multifirma o MPC. |
| Con volumen | Nodos propios, monitoreo continuo y segundo proveedor de datos. |

### 13. Construir ahora, activar al ingresar dinero

Casi todo el sistema se puede construir y conectar hoy con planes gratuitos y redes de prueba, sin dinero real. Cuando entre el primer dinero, las herramientas no se activan solas: cada una cae en uno de tres tipos, y cada tipo se activa de forma distinta.

| Tipo | Herramientas | Qué hay que hacer para activarla | Tiempo |
| --- | --- | --- | --- |
| Funcionan desde hoy | Exploradores, TRM, SHA-256, OpenTimestamps, librerías, API de Binance, APIs de Bitcoin | Nada. Se usan igual en pruebas y en producción. | Inmediato |
| Se activan cambiando de plan | Supabase, API de Etherscan, TronGrid, Alchemy o Infura, CoinGecko | Subir de plan en el panel del proveedor y cambiar la llave en la configuración. | Minutos |
| Requieren contrato y empresa | Chainalysis, Elliptic o TRM Labs; Fireblocks o BitGo; cuenta institucional de Binance OTC | Cotizar, pasar la revisión KYB del proveedor sobre tu empresa y firmar contrato. Requiere la sociedad constituida. | Semanas |

### Probar sin dinero real

Se usan las redes de prueba: Sepolia en Ethereum, Nile o Shasta en Tron, y testnet o signet en Bitcoin. Funcionan igual que las reales y su cripto no tiene valor.

### Conectores intercambiables

Cada herramienta de pago se conecta a través de un adaptador. En pruebas responde un simulador. Al contratar, se cambia por el proveedor real en la configuración, sin reescribir el sistema.

**Lo que hay que adelantar**

Las herramientas del tercer tipo son las que más tardan. Conviene cotizarlas en paralelo a la construcción, para que estén firmadas cuando llegue el primer cliente. Y Supabase debe pasar al plan Pro antes de guardar el primer dato real, porque el plan gratuito no tiene backups automáticos.

### 14. Ficha de cada herramienta: costo, proceso, área y función

Cada ficha indica en qué proceso del libro participa la herramienta, qué área la usa, para qué sirve, qué pasa si no se usa, cuándo se activa y cómo llegar a ella.

Entrar siempre por estos enlaces o escribiendo la dirección a mano. Hay sitios falsos que imitan exchanges y billeteras para robar llaves y fondos.

Gratis sin costo
Plan gratuito gratis con límites, luego pago
Pago requiere plan o contrato

#### Exploradores: verificación manual

### Etherscan (web)

Gratis

Cómo llegar[etherscan.io](https://etherscan.io)Pegar el hash o la dirección en el buscador. No requiere cuenta.

Proceso
:   Verificación y auditoría (pasos 13 y 15)

Área
:   Cumplimiento, auditoría

Para qué
:   Ver a mano una transacción de ETH o de USDT en Ethereum y guardar el enlace como evidencia.

Si no se usa
:   Nadie puede comprobar una operación sin depender de los datos del propio sistema.

Se activa
:   Desde hoy

### Tronscan

Gratis

Cómo llegar[tronscan.org](https://tronscan.org)Pegar el hash o la dirección en el buscador. No requiere cuenta.

Proceso
:   Verificación y auditoría (pasos 13 y 15)

Área
:   Cumplimiento, tesorería

Para qué
:   Verificar depósitos y retiros de USDT en TRC-20 y confirmar el contrato del token.

Si no se usa
:   La red con más volumen de USDT queda sin verificación manual, con más riesgo de aceptar tokens falsos.

Se activa
:   Desde hoy

### mempool.space y Blockstream

Gratis

Cómo llegar[mempool.space](https://mempool.space) [Documentación API](https://mempool.space/docs/api) [blockstream.info](https://blockstream.info)La web y la API pública no requieren cuenta.

Web y API pública sin llave. Blockstream permite unas 50 solicitudes por segundo; mempool.space aplica un límite que no publica.

Proceso
:   Captura on-chain de Bitcoin (paso 7) y verificación

Área
:   Tecnología, cumplimiento

Para qué
:   Leer y verificar transacciones de BTC, sus comisiones y confirmaciones.

Si no se usa
:   Los movimientos de Bitcoin no entran al libro de forma automática.

Se activa
:   Desde hoy

### Blockchair

Gratis

Cómo llegar[blockchair.com](https://blockchair.com)Pegar el hash o la dirección en el buscador.

La consulta web es gratis. Su API no la verifiqué.

Proceso
:   Verificación y auditoría

Área
:   Auditoría

Para qué
:   Tercera fuente para desempatar cuando dos exploradores no coinciden.

Si no se usa
:   Impacto bajo. Es un respaldo, no una pieza central.

Se activa
:   Cuando se necesite

#### Captura automática de blockchain

### API de Etherscan

Plan gratuito

Cómo llegar[etherscan.io/apis](https://etherscan.io/apis) [Documentación](https://docs.etherscan.io)Crear una cuenta gratuita, entrar a API Keys y generar una llave.

Gratis: 3 llamadas por segundo y hasta 100.000 al día, con Ethereum incluido. De pago: planes Lite a Pro Plus, hasta 1,5 millones al día.

Proceso
:   Captura on-chain (paso 7)

Área
:   Tecnología

Para qué
:   Leer de forma automática las transferencias de ETH y USDT ERC-20 de nuestras wallets.

Si no se usa
:   Hay que digitar transacciones a mano, con errores y sin trazabilidad automática.

Se activa
:   Desde hoy. Se sube de plan si se superan los límites.

### TronGrid

Plan gratuito

Cómo llegar[trongrid.io](https://www.trongrid.io) [chainstack.com](https://chainstack.com)Crear una cuenta y generar la llave de API en el panel.

Gratis: 100.000 solicitudes al día, 15 por segundo y 3 llaves. Planes mayores a la medida. Alternativa: Chainstack, con 3 millones al mes gratis y plan Growth de 49 USD al mes.

Proceso
:   Captura on-chain (paso 7)

Área
:   Tecnología

Para qué
:   Leer de forma automática los movimientos de USDT en TRC-20.

Si no se usa
:   Probablemente la mayor parte del volumen de USDT quedaría sin captura automática.

Se activa
:   Desde hoy

### Alchemy o Infura

Plan gratuito

Cómo llegar[alchemy.com](https://www.alchemy.com) [infura.io](https://www.infura.io)Crear una cuenta y una app para obtener la llave.

Alchemy: 30 millones de compute units al mes. Infura: 3 millones de créditos al día. Después, pago por uso o planes.

Proceso
:   Captura on-chain y avisos en tiempo real (paso 7)

Área
:   Tecnología

Para qué
:   Respaldo de Etherscan y avisos inmediatos (webhooks) cuando llega un depósito.

Si no se usa
:   Si Etherscan falla, se detiene la captura de Ethereum, y los depósitos se detectan con retraso.

Se activa
:   Opcional al inicio. Recomendable antes de operar con clientes.

### Nodos propios

Pago

Cómo llegar[bitcoincore.org](https://bitcoincore.org) [Clientes de Ethereum](https://ethereum.org/en/developers/docs/nodes-and-clients/)Se instalan en un servidor propio o en la nube.

Bitcoin Core y los clientes de Ethereum son gratuitos. Lo que cuesta es el servidor y su mantenimiento.

Proceso
:   Captura on-chain (paso 7)

Área
:   Tecnología

Para qué
:   Leer la blockchain sin depender de terceros.

Si no se usa
:   Se depende de proveedores externos. Aceptable al inicio.

Se activa
:   Con volumen

#### Exchange y tasas

### API de Binance

Gratis

Cómo llegar[developers.binance.com](https://developers.binance.com)En la cuenta de Binance, entrar a Gestión de API y crear una llave solo de lectura.

No tiene costo por uso, solo límites de consumo. Las comisiones de cada operación son aparte.

Proceso
:   Captura de exchange (paso 8) y valoración (paso 10)

Área
:   Tesorería, contabilidad

Para qué
:   Traer depósitos, retiros, operaciones OTC, comisiones y el precio de ejecución.

Si no se usa
:   Las operaciones en Binance se cargan a mano y la conciliación con el exchange se vuelve manual.

Se activa
:   Desde hoy, con llave de solo lectura. La cuenta institucional OTC requiere la empresa.

### TRM oficial

Gratis

Cómo llegar[banrep.gov.co](https://www.banrep.gov.co/es/estadisticas/trm) [superfinanciera.gov.co](https://www.superfinanciera.gov.co)Publicación diaria. No requiere cuenta.

Proceso
:   Valoración y tasas (paso 10)

Área
:   Contabilidad

Para qué
:   Convertir a pesos todo lo que está en dólares con la tasa oficial del día.

Si no se usa
:   La valoración en COP queda sin una fuente oficial que la sustente ante la DIAN.

Se activa
:   Desde hoy

### CoinGecko API

Plan gratuito

Cómo llegar[coingecko.com/en/api](https://www.coingecko.com/en/api)Crear una cuenta y generar la llave del plan gratuito.

Gratis: 10.000 llamadas al mes y 100 por minuto. El uso comercial parece requerir plan de pago, desde unos 35 USD al mes.

Proceso
:   Valoración y tasas (paso 10)

Área
:   Contabilidad

Para qué
:   Precio de referencia independiente para BTC y ETH.

Si no se usa
:   Se usa el precio de Binance. Es opcional.

Se activa
:   Si el contador pide una fuente independiente

#### Base de datos, sellado y Excel

### Supabase

Plan gratuito

Cómo llegar[supabase.com](https://supabase.com) [Precios](https://supabase.com/pricing) [Documentación](https://supabase.com/docs)Crear una cuenta y un proyecto nuevo.

Free: 500 MB, se pausa tras 1 semana sin uso y no tiene backups automáticos. Pro: desde 25 USD al mes, 8 GB y backups diarios por 7 días.

Proceso
:   Registro contable (pasos 3 a 5) y todo el sistema

Área
:   Tecnología, contabilidad

Para qué
:   Guardar el libro, la cadena de hashes, los eventos y las tasas.

Si no se usa
:   No hay libro. Es la pieza central del sistema.

Se activa
:   Free para construir. Pro antes del primer dato real.

### SHA-256

Gratis

Cómo llegar[Python hashlib](https://docs.python.org/3/library/hashlib.html) [Node.js crypto](https://nodejs.org/api/crypto.html)Viene incluido en Python y Node.js. No requiere cuenta.

Proceso
:   Cadena de hashes (paso 5)

Área
:   Tecnología, auditoría

Para qué
:   Crear la huella de cada asiento y de cada archivo de Excel.

Si no se usa
:   Un asiento podría modificarse sin que nadie lo detecte.

Se activa
:   Desde hoy

### OpenTimestamps

Gratis

Cómo llegar[opentimestamps.org](https://opentimestamps.org)Herramienta abierta. No requiere cuenta.

Proceso
:   Anclaje en blockchain (paso 6)

Área
:   Auditoría

Para qué
:   Sellar en Bitcoin la raíz de Merkle del día.

Si no se usa
:   No existe una prueba externa de que el libro no cambió.

Se activa
:   Desde hoy

### Anclaje en Ethereum

Pago

Cómo llegar[Gas en ethereum.org](https://ethereum.org/en/developers/docs/gas/) [Costo actual del gas](https://etherscan.io/gastracker)Se envía desde una wallet de la empresa con un poco de ETH para el gas.

El gas de una transacción al día. Varía según la congestión de la red.

Proceso
:   Anclaje en blockchain (paso 6)

Área
:   Auditoría

Para qué
:   Segundo anclaje, verificable al instante en Etherscan.

Si no se usa
:   Queda solo el anclaje en Bitcoin, que es suficiente. Es opcional.

Se activa
:   Cuando se quiera un segundo respaldo

### Librerías de cada red

Gratis

Cómo llegar[ethers.js](https://docs.ethers.org) [web3.py](https://web3py.readthedocs.io) [TronWeb](https://github.com/tronprotocol/tronweb) [bitcoinjs-lib](https://github.com/bitcoinjs/bitcoinjs-lib)Se instalan con npm o pip.

ethers.js, web3.py, TronWeb y bitcoinjs-lib. Código abierto.

Proceso
:   Captura on-chain y conectores (pasos 7 y 8)

Área
:   Tecnología

Para qué
:   Leer e interpretar transacciones de cada red desde el código.

Si no se usa
:   Habría que programar cada protocolo desde cero.

Se activa
:   Desde hoy

### openpyxl o SheetJS

Gratis

Cómo llegar[openpyxl](https://openpyxl.readthedocs.io) [SheetJS](https://docs.sheetjs.com)Se instalan con pip o npm.

Código abierto. SheetJS en su edición comunitaria.

Proceso
:   Impuestos y archivos de Excel (paso 12 y sección D)

Área
:   Contabilidad

Para qué
:   Generar cada día el Excel de lotes y ventas de forma automática.

Si no se usa
:   El Excel se arma a mano, con errores y sin sello.

Se activa
:   Desde hoy

#### Cumplimiento

### Chainalysis, Elliptic o TRM Labs

Pago

Cómo llegar[chainalysis.com](https://www.chainalysis.com) [elliptic.co](https://www.elliptic.co) [trmlabs.com](https://www.trmlabs.com)Solicitar demo o cotización desde el sitio de cada uno.

Sin precio público. Rangos citados: Chainalysis de 10.000 a más de 200.000 USD al año; TRM Labs de 50.000 a 500.000 USD al año; Elliptic no verificado. Contratos de 1 a 3 años. Chainalysis ofrece pruebas de 14 a 30 días.

Proceso
:   Cumplimiento y trazabilidad (paso 13)

Área
:   Cumplimiento

Para qué
:   Puntuar el riesgo de cada wallet, detectar sanciones y seguir el origen de los fondos.

Si no se usa
:   No se puede demostrar la debida diligencia sobre las wallets. Hay riesgo de recibir fondos ilícitos y de perder las cuentas bancarias.

Se activa
:   Antes del primer cliente. Cotizar en paralelo a la construcción.

#### Custodia

### Safe

Gratis

Cómo llegar[app.safe.global](https://app.safe.global) [safe.global](https://safe.global)Conectar las wallets de los firmantes y crear la cuenta multifirma.

Los contratos y la app son gratis. Solo se paga el gas de la red. No confirmé soporte para Tron.

Proceso
:   Custodia y seguridad (paso 14)

Área
:   Tesorería

Para qué
:   Que mover fondos en Ethereum requiera la firma de varias personas.

Si no se usa
:   Una sola llave controla los fondos, con riesgo de robo o error.

Se activa
:   Antes de mover fondos reales

### Billeteras de hardware

Pago

Cómo llegar[ledger.com](https://www.ledger.com) [trezor.io](https://trezor.io)Comprar solo en la tienda oficial del fabricante.

Pago único por dispositivo. Precio no verificado.

Proceso
:   Custodia y seguridad (paso 14)

Área
:   Tesorería

Para qué
:   Guardar las llaves fuera de internet para la tesorería pequeña.

Si no se usa
:   Las llaves quedan en dispositivos conectados, más expuestas.

Se activa
:   Antes de mover fondos reales

### Fireblocks o BitGo

Pago

Cómo llegar[fireblocks.com](https://www.fireblocks.com) [bitgo.com](https://www.bitgo.com)Contactar a ventas desde el sitio de cada uno.

Fireblocks: plan Essentials reportado en 999 USD al mes, con compromiso de hasta 6 meses. BitGo: precio a la medida, con mínimos reportados de 1 millón de USD.

Proceso
:   Custodia y seguridad (paso 14)

Área
:   Tesorería

Para qué
:   Custodia institucional con MPC y políticas de aprobación.

Si no se usa
:   Se cubre con Safe y billeteras de hardware mientras el volumen sea bajo.

Se activa
:   Con volumen

### 15. Presupuesto de herramientas por etapa

| Etapa | Qué se usa | Costo aproximado |
| --- | --- | --- |
| Construir y probar | Planes gratuitos, redes de prueba y Supabase Free | Cerca de 0 USD |
| Piloto con fondos propios | Supabase Pro, Safe y billetera de hardware | Desde 25 USD al mes, más el gas y el costo único del hardware |
| Operar con clientes | Lo anterior más analítica on-chain y planes de pago si se superan los límites | Decenas de miles de USD al año, sobre todo por la analítica |
| Con volumen | Lo anterior más custodia institucional y nodos propios | Desde unos 999 USD al mes en custodia, más infraestructura |

Precios consultados el 14 de octubre de 2026 en páginas oficiales y comparadores de precios. Cambian con frecuencia: un rastreador de precios registró que Alchemy recortó cerca de un 70 % su plan gratuito en 2025. Confirmar cada precio en la página del proveedor antes de contratar.

Fuentes: [Etherscan, límites](https://docs.etherscan.io/resources/rate-limits.md) · [Etherscan, redes](https://docs.etherscan.io/supported-chains) · [Chainstack, proveedores Tron](https://chainstack.com/best-tron-rpc-providers-2026/) · [Alchemy](https://support.alchemy.com/articles/5827006872-what-is-included-in-the-free-tier) · [Infura](https://docs.infura.io/get-started/pricing/) · [Supabase](https://supabase.com/pricing) · [CoinGecko](https://costbench.com/software/blockchain-data-api/coingecko-api/free-plan/) · [Chainalysis](https://costbench.com/software/crypto-compliance/chainalysis) · [TRM Labs](https://www.costbench.com/software/crypto-compliance/trm-labs/) · [Fireblocks y BitGo](https://costbench.com/compare/bitgo-vs-fireblocks/) · [APIs de Bitcoin](https://www.spark.money/tools/bitcoin-block-explorer-api-comparison) · [Binance](https://developers.binance.com/docs/binance-spot-api-docs/websocket-api/rate-limits) · [Safe](https://eco.com/support/en/articles/15254042-safe-wallet-deep-dive-2026-multisig-and-smart-accounts)

**Entregable**Lista de herramientas elegidas, con proveedor, plan contratado, responsable y fecha de revisión.

Fase 1 · Diseño

## Diseño del libro

1

### Definir alcance y principios

Objetivo: dejar por escrito qué registra el libro y qué reglas no se rompen nunca.

#### Tareas

- Listar activos y redes: USDT (TRC-20 y ERC-20), BTC, ETH, USD y COP.
- Listar fuentes: wallets propias, wallets de clientes bajo custodia, cuentas en Binance, cuentas bancarias.
- Fijar la moneda funcional: COP. Todo asiento se valora en COP, guardando también la cantidad original.
- Principios: solo inserción, partida doble cuadrada, cada asiento con evidencia, separación de fondos de clientes y fondos propios.
- Definir con el contador el método de costo (promedio ponderado o PEPS/FIFO) por activo.

**Entregable**Documento de alcance y principios aprobado por gerencia y contador.

2

### Diseñar el plan de cuentas

Objetivo: que cada wallet, cuenta bancaria y tipo de ingreso tenga su cuenta contable, alineada al PUC y a NIIF.

#### Estructura sugerida (códigos finales con el contador)

| Grupo | Cuentas | Detalle por |
| --- | --- | --- |
| Activo · Bancos | Bancos COP, Bancos USD | Cada cuenta bancaria |
| Activo · Criptoactivos propios | USDT, BTC, ETH | Cada wallet y red |
| Activo · Saldos en exchange | Binance por activo | Cada subcuenta |
| Activo · Fondos de clientes | Cripto y fiat de clientes en custodia | Cada cliente |
| Pasivo · Obligaciones con clientes | Contrapartida de los fondos de clientes | Cada cliente |
| Ingresos | Spread, comisiones, diferencia en cambio | Tipo de servicio |
| Gastos | Comisiones de red (gas), comisiones de exchange y bancarias, GMF | Red o entidad |

Para la DIAN los criptoactivos son intangibles. Si se compran para revender en el giro del negocio, el contador puede clasificarlos como inventario. Esta decisión cambia la cuenta y el tratamiento en renta.

**Entregable**Plan de cuentas cargado en la base de datos.

3

### Diseñar el modelo de datos

Objetivo: separar la evidencia cruda, los asientos contables y la cadena de verificación.

| Tabla | Contenido |
| --- | --- |
| `accounts` | Plan de cuentas. |
| `wallets` | Dirección, red, activo, dueño (propia o cliente) y cuenta contable asociada. |
| `counterparties` | Clientes y proveedores con su estado KYB y nivel de riesgo. |
| `raw_events` | Evidencia cruda: transacción on-chain, movimiento bancario o operación de exchange, tal como llegó. |
| `journal_entries` | Cabecera del asiento: fecha, descripción, evento origen, hash previo y hash propio. |
| `journal_lines` | Líneas débito/crédito: cuenta, activo, cantidad nativa, valor en COP, tasa usada. |
| `fx_rates` | Precios y TRM con fuente y marca de tiempo. |
| `anchors` | Raíz de Merkle diaria, red de anclaje, ID de la transacción y prueba. |
| `reconciliations` | Resultado diario de conciliación por cuenta, con diferencias. |

**Entregable**Esquema de base de datos y migraciones versionadas.

Fase 2 · Núcleo del libro

## Núcleo inalterable

4

### Implementar la partida doble inalterable

Objetivo: que la base de datos misma impida asientos descuadrados, ediciones o borrados.

#### Tareas

- Validación en servidor: la suma de débitos en COP es igual a la suma de créditos en COP en cada asiento.
- Permisos: las tablas del libro solo aceptan inserción. Ningún rol puede actualizar ni borrar.
- Correcciones: solo con asiento de reverso que referencia al original.
- Cantidades en unidades mínimas enteras (satoshis para BTC, wei para ETH, 6 decimales para USDT) para evitar errores de redondeo.

#### Ejemplo de asiento: cliente paga 1.000 USDT por TRC-20

| Cuenta | Cantidad | Débito COP | Crédito COP |
| --- | --- | --- | --- |
| Criptoactivos · USDT · wallet TRC-20 principal | 1.000 USDT | 4.000.000 |  |
| Clientes · Empresa ABC |  |  | 4.000.000 |

Valores ilustrativos: 1 USDT = 1 USD y TRM de ejemplo de 4.000 COP.

**Entregable**Libro que rechaza por diseño asientos descuadrados y modificaciones.

5

### Encadenar los asientos con hashes

Objetivo: que cualquier modificación de un asiento antiguo rompa la cadena y sea detectable.

#### Cómo funciona

- Cada asiento se serializa siempre igual (mismo orden de campos, mismo formato).
- Su hash es SHA-256 del hash del asiento anterior más su propio contenido.
- El primer asiento (génesis) usa un valor fijo documentado.
- Un proceso de verificación recorre la cadena y recalcula todos los hashes.

```
// Lógica del encadenamiento (pseudocódigo)
payload   = serializar(asiento)        // orden y formato fijos
hash_n    = SHA256(hash_(n-1) + payload)
guardar(asiento, prev_hash = hash_(n-1), hash = hash_n)

// Verificación
para cada asiento en orden:
  si SHA256(prev_hash + payload) != hash → ALERTA: libro alterado
```

**Entregable**Cadena de hashes activa y verificador ejecutable por auditoría.

6

### Anclar el libro en una blockchain pública

Objetivo: una prueba externa e independiente de que el libro existía así en una fecha determinada.

#### Proceso diario

1. Al cierre del día, tomar los hashes de todos los asientos del día.
2. Calcular la raíz de Merkle: una sola huella que resume todos los asientos.
3. Publicar la raíz en Bitcoin con OpenTimestamps y, opcionalmente, en Ethereum o una red de bajo costo compatible.
4. Guardar en `anchors` la raíz, la red, el ID de la transacción y la prueba.
5. Para verificar un asiento: se entrega el asiento, su ruta de Merkle y el ID de la transacción de anclaje.

Solo sale una huella de 32 bytes por día. No se puede reconstruir ningún dato a partir de ella, y aun así prueba que nada cambió.

**Entregable**Anclaje diario automático y pantalla de verificación para auditores.

Fase 3 · Conexiones

## Conectar las fuentes

7

### Capturar transacciones on-chain por red

Objetivo: leer cada movimiento de las wallets, solo cuando esté confirmado, y guardarlo como evidencia.

### Bitcoin

- Modelo UTXO: una transacción puede tener varias entradas y salidas.
- Monitorear con claves públicas extendidas (xpub) en modo solo lectura.
- Registrar la comisión de minería como gasto.
- Umbral de confirmaciones configurable (referencia común: 3 a 6).

### Ethereum

- Modelo de cuentas: leer transferencias de ETH y eventos `Transfer` de tokens ERC-20.
- Registrar el gas pagado en ETH como gasto.
- Esperar a que el bloque esté finalizado antes de contabilizar.

### USDT

- Existe en varias redes: tratar TRC-20 y ERC-20 como subcuentas distintas.
- Validar el contrato oficial del token para no registrar tokens falsos.
- En Tron, la comisión se paga con energía o TRX: registrar el costo.

### Reglas comunes

- Guardar hash de la transacción, bloque, hora, origen, destino y monto.
- Evitar duplicados con clave única por red + hash + índice.
- Detectar reorganizaciones de cadena y reversar si aplica.

Las herramientas de cada red (Etherscan, Tronscan, mempool.space, TronGrid y otras) están en la sección [C · Herramientas necesarias para la trazabilidad en la blockchain](#herramientas).

**Entregable**Conectores por red funcionando en modo solo lectura.

8

### Capturar bancos y exchange

Objetivo: que la pata fiat y las operaciones en Binance entren al libro con la misma disciplina que lo on-chain.

- **Binance:** API con llave de solo lectura para depósitos, retiros, operaciones OTC y comisiones.
- **Bancos COP:** extractos por API si el banco la ofrece, o archivo diario estandarizado.
- **Bancos USD:** igual que COP, más el vínculo con la declaración de cambio cuando aplique.
- Cada movimiento queda en `raw_events` con su documento de soporte.

**Entregable**Movimientos de Binance y bancos cargados a diario.

9

### Definir reglas contables automáticas

Objetivo: que cada tipo de evento genere su asiento sin intervención manual.

| Evento | Débito | Crédito |
| --- | --- | --- |
| Cobro a cliente en USDT | Criptoactivos USDT | Clientes |
| Conversión USDT → COP | Bancos COP | Criptoactivos USDT; diferencia a ingreso o gasto |
| Compra de BTC con USDT | Criptoactivos BTC | Criptoactivos USDT |
| Comisión de red (gas) | Gastos comisiones de red | Criptoactivos de la red |
| Depósito de cliente en custodia | Fondos de clientes | Obligaciones con clientes |
| Spread en operación OTC | Bancos o cripto recibido | Ingreso por spread |

Los eventos que no coinciden con ninguna regla van a una bandeja de revisión manual. No se contabilizan solos.

**Entregable**Catálogo de reglas aprobado por el contador y probado con casos reales.

10

### Valoración y tasas de cambio

Objetivo: valorar todo en COP con una fuente única, trazable y repetible.

- **USD → COP:** TRM oficial del día.
- **Cripto → USD:** una fuente de precio definida (por ejemplo, el precio de ejecución en Binance, o un índice), con marca de tiempo.
- Guardar en cada línea del asiento la tasa usada y su fuente.
- Calcular costo y utilidad realizada con el método definido en el paso 1.
- Valoración al cierre de mes y a 31 de diciembre para estados financieros y exógena.

**Entregable**Tabla de tasas con histórico y cálculo de utilidad realizada.

Fase 4 · Control

## Control, cumplimiento y salida a producción

11

### Conciliación diaria

Objetivo: que el saldo del libro cuadre con el saldo real en cada fuente, todos los días.

| Se compara | Contra | Si no cuadra |
| --- | --- | --- |
| Saldo contable de cada wallet | Saldo on-chain de la dirección | Alerta y bloqueo del cierre del día |
| Saldo contable en Binance | Saldo reportado por la API | Alerta a tesorería |
| Saldo contable de bancos | Extracto bancario | Alerta a contabilidad |
| Fondos de clientes | Obligaciones con clientes | Alerta crítica: posible uso de fondos de clientes |

**Entregable**Reporte diario de conciliación y alertas automáticas.

12

### Impuestos y costo fiscal de los criptoactivos

Objetivo: que el libro calcule solo la utilidad de cada venta, que es lo único sobre lo que se pagan impuestos, y la clasifique en el impuesto que le corresponde.

#### Regla base

El impuesto se calcula sobre la utilidad, no sobre el valor total de la venta. La utilidad es el precio de venta menos el costo fiscal, que es lo que costó adquirir esa cripto en pesos. Mientras no se venda, no hay impuesto: la valorización solo se reporta en el patrimonio.

#### Ejemplo: 1.000 USDT comprados a 4.000 y vendidos a 4.300

| Concepto | COP | Efecto tributario |
| --- | --- | --- |
| Compra: 1.000 USDT × 4.000 | 4.000.000 | Costo fiscal. No paga impuesto. |
| Venta: 1.000 USDT × 4.300 | 4.300.000 | Precio de venta. |
| Utilidad (venta − costo) | 300.000 | Base del impuesto. |

#### Qué impuesto cae sobre esa utilidad

| Quién vende | Impuesto | Tarifa | Sobre 300.000 |
| --- | --- | --- | --- |
| Persona natural, tenencia menor a 2 años | Renta (se suma a los ingresos del año) | Tabla progresiva, 0 % a 39 % | 300.000 × tarifa marginal |
| Persona natural, tenencia de 2 años o más | Ganancia ocasional | 15 % | 45.000 |
| Empresa, cripto como inventario | Renta | 35 % | 105.000 |
| Empresa, cripto como activo fijo con 2 años o más | Ganancia ocasional | 15 % | 45.000 |

Los dos impuestos son independientes y no se acumulan. Cada venta cae en uno solo, según el tiempo de tenencia y la clasificación del activo.

#### Eventos que generan impuesto

- Venta de cripto por pesos o dólares.
- Intercambio de una cripto por otra (por ejemplo USDT por BTC), que la DIAN trata como una enajenación. Validar con el contador.
- Pago de bienes o servicios con cripto.

#### Lo que el libro debe guardar para calcularlo

- **Lotes de compra.** Cada compra es un lote con fecha, cantidad, costo en COP y la tasa usada.
- **Método de costo.** El definido en el paso 1 (promedio ponderado o PEPS), aplicado igual todos los años.
- **Tiempo de tenencia por lote.** Para separar las ventas de menos de 2 años de las de 2 años o más.
- **Utilidad realizada por venta.** Una línea por operación, con el impuesto que le corresponde. Las pérdidas también se registran.
- **Costos de transacción.** Comisiones y gas asociados a cada compra o venta. Definir con el contador cómo entran en el costo.

Estos datos viven en un archivo de Excel generado desde el libro, con la fecha de cada transacción, el tipo de cripto, su trazabilidad, si se vendió y a qué tasa. Ver la sección [D · Archivos de Excel](#excel).

#### USDT recibidos de otros países

El país de origen no cambia la forma de declarar. Colombia grava a sus residentes sobre lo que reciben, venga de donde venga. Lo que decide el tratamiento es el motivo por el que llegan los USDT.

| Por qué llegan los USDT | Tratamiento |
| --- | --- |
| Pago de un cliente por un servicio o una venta | Ingreso ordinario. Se registra en COP al valor del día de llegada y todo el valor es ingreso. Si es una exportación de servicios, revisar con el contador la exención de IVA. |
| Un cliente le compra USDT (usted como proveedor de liquidez) | El ingreso es lo que recibe por la venta. Se resta el costo fiscal de esos USDT y el impuesto es sobre la utilidad. |
| Dinero de un tercero que usted solo canaliza | No es ingreso. Es un pasivo, "dinero de terceros", hasta que se entregue. Exige contrato y registro claros. |
| Traslado desde una cuenta propia en otro país | No es ingreso. Es una transferencia interna. Hay que justificar el origen de los fondos y probablemente declarar los activos en el exterior. |

#### Qué cambia cuando el dinero viene de fuera

- **Impuestos pagados en el exterior.** Si le retuvieron un impuesto afuera, en algunos casos se toma como descuento. Se revisa caso por caso.
- **Riesgo y cumplimiento.** Las operaciones con billeteras de otros países suben el riesgo para la UIAF y SAGRILAFT. Hay que conocer al cliente, revisar listas de sanciones y revisar la jurisdicción (paso 13).
- **Intercambio de información.** Los reportes de exchanges entre países pueden cruzarse. Lo que reporte un Binance de otro país sobre el cliente puede coincidir con lo que Binance Colombia reporte de usted.
- **Datos en el libro.** Cada ingreso guarda país, contraparte, motivo del pago, TRM o precio de referencia y hash de la transacción.

#### Caso: USDT desde Binance Argentina, vendidos por pesos en Colombia

No existe arancel ni impuesto por la transferencia entre países. El arancel solo grava mercancías físicas que pasan por aduana, y el USDT es un activo intangible. Recibir los USDT tampoco paga impuesto. Los impuestos aparecen al venderlos por pesos.

| Concepto | ¿Aplica? | Base de cálculo |
| --- | --- | --- |
| Arancel o impuesto por la transferencia entre países | No | — |
| Renta de la empresa | Sí, 35 % | Utilidad: precio de venta menos costo de los USDT y gastos |
| ICA (impuesto municipal) | Sí, muy probablemente | Ingreso bruto, no utilidad. La tarifa depende de la actividad registrada |
| IVA | No sobre la venta del USDT. Sí sobre una comisión o tarifa de servicio aparte | La comisión |
| GMF (4×1000) | Sí | Cada salida de pesos de una cuenta bancaria |
| Comisiones de Binance y de red | No son impuesto | Se registran como costo |

**Revisar el ICA antes de fijar tarifas**

En un negocio de liquidez hay mucho volumen y poco margen. Si el ICA se calcula sobre todo el valor vendido, puede pesar más que la renta. Algunos municipios permiten tomar como base solo el margen en ciertas actividades. Confirmarlo con el contador antes de definir los precios.

**Lo que no es impuesto pero sí se exige**

Cambiario: el USDT no es divisa, así que la transferencia entre países no lleva declaración de cambio. Si entran o salen dólares reales por un banco, sigue el régimen cambiario. Los impuestos de quien envía desde Argentina son asunto de esa persona y de su país. Para usted, la operación cuenta como de riesgo internacional.

#### Reportes que salen de este paso

| Reporte | Qué toma del libro | Cuándo |
| --- | --- | --- |
| Declaración de renta | Utilidad realizada del año por tipo de impuesto y saldo a 31 de diciembre en el patrimonio. | Anual |
| Exógena, formato 1012, concepto 1206 | Valor patrimonial de los criptoactivos a 31 de diciembre. | Anual |
| CARF | Transacciones de usuarios reportables. | Año 2026 se reporta hasta mayo de 2027 |
| IVA | Comisiones e intermediación (la venta de cripto en sí no lleva IVA). | Según periodo de IVA |
| ICA | Ingresos brutos de la actividad de compraventa de cripto, según el municipio. | Según calendario municipal |

**Estado de la norma**

La reforma que proponía cambiar el tratamiento de la cripto fue hundida en el Congreso, y la Corte Constitucional tumbó la emergencia económica con la que el Gobierno intentó reemplazarla. Sigue vigente el régimen anterior. Si el tratamiento cambia, se ajustan las reglas del módulo de impuestos y no la estructura del libro. Confirmar siempre con el contador antes de cada declaración.

**Entregable**Módulo de costo fiscal por lotes, utilidad realizada por venta y reporte anual de utilidad por tipo de impuesto.

13

### Trazabilidad y cumplimiento

Objetivo: que desde cualquier asiento se llegue al cliente, a la evidencia y al análisis de riesgo.

- Cada asiento enlaza con: evento crudo, transacción on-chain o bancaria, cliente y su expediente KYB.
- Puntaje de riesgo de cada wallet externa con una herramienta de análisis on-chain.
- Datos de origen y beneficiario para transferencias entre proveedores (Travel Rule).
- Exportadores: reporte mensual de clientes y transacciones a la UIAF, reporte anual CARF en XML a la DIAN y saldos a 31 de diciembre para exógena.
- Conservar evidencia al menos 5 años, como exige el CARF.

**Entregable**Ficha de trazabilidad por transacción y exportadores regulatorios.

14

### Seguridad y accesos

Objetivo: que el sistema contable nunca pueda mover fondos.

- El libro nunca guarda llaves privadas. Solo direcciones y claves públicas de solo lectura.
- Llaves de API de exchange y bancos con permiso de solo lectura.
- Roles separados: quien registra, quien aprueba ajustes, quien audita.
- Bitácora de accesos y acciones, también encadenada con hashes.
- Copias de seguridad cifradas y prueba de restauración trimestral.

La custodia de fondos (wallets multifirma o MPC) es un sistema separado del libro. Mezclarlos aumenta el riesgo de robo.

#### Billetera fría propia: cómo se reporta y cómo se documenta

Caso típico: Binance como custodia operativa y una billetera de hardware como reserva de seguridad. La billetera fría no se registra ante la DIAN, pero sí queda documentada en el libro.

| Pregunta | Respuesta |
| --- | --- |
| ¿Hay que dar la dirección a la DIAN? | No hay un registro de billeteras personales. Quien reporta es el proveedor de servicios (Binance), según la Res. 000240/2025. Un retiro hacia una billetera externa puede aparecer en ese reporte, por lo que la dirección puede llegar a la DIAN por esa vía. |
| ¿Hay que declarar lo que contiene? | Sí. Los criptoactivos en la billetera fría son patrimonio y se declaran a su costo fiscal, igual que los que están en Binance. En información exógena: formato 1012, concepto 1206. |
| ¿Mover fondos de Binance a la fría genera impuesto? | No. Es una transferencia interna entre cuentas propias, no una venta. El costo fiscal no cambia. La comisión de red se registra como gasto. |
| ¿Y si la DIAN, la UIAF o un banco preguntan? | Hay que poder demostrar que la dirección es propia y reconstruir cada traslado desde el libro. |

#### Qué debe quedar en el libro

- La dirección registrada como cuenta propia, tipo "custodia fría", con la red (TRC-20, ERC-20, Bitcoin).
- Prueba de control: mensaje firmado con esa billetera, factura de compra del dispositivo o captura de su configuración, con fecha, guardada como evidencia y con su hash.
- Cada traslado como asiento de transferencia interna, con hash de la transacción, fecha, cantidad y comisión de red.
- Conciliación periódica: saldo de la dirección en el explorador (Etherscan, Tronscan, mempool.space) contra el saldo del libro.

#### Reglas de operación entre Binance y la billetera fría

- Binance guarda el saldo operativo. La billetera fría guarda la reserva.
- Lista blanca de direcciones de retiro en Binance, con solo la dirección de la billetera fría.
- Mover la reserva exige dos personas: quien ejecuta y quien aprueba.
- Primero se envía una prueba pequeña y se confirma la llegada antes de mover el monto completo.
- La frase de recuperación nunca se guarda en el libro, en la nube ni en fotos.

Los detalles que exige la Res. 000240/2025 sobre transferencias a billeteras externas deben confirmarse con el contador antes de operar con clientes.

**Entregable**Matriz de roles y permisos, y política de llaves.

15

### Reportes, pruebas y salida a producción

Objetivo: entrar en producción con datos reales verificados y un panel útil para gerencia y auditoría.

#### Reportes

- Balance y estado de resultados por activo y por red.
- Posición diaria: saldos en cada wallet, exchange y banco.
- Libro mayor y auxiliares con enlace a la evidencia.
- Pantalla de verificación: el auditor elige un asiento y ve su hash, su ruta de Merkle y el anclaje en blockchain.

#### Pruebas antes de producción

- Operar un mes en paralelo con la contabilidad actual y comparar.
- Probar casos difíciles: comisiones, reversos, depósitos duplicados, tokens falsos, reorganizaciones de cadena.
- Intentar alterar un asiento en pruebas y confirmar que el verificador lo detecta.
- Revisión del contador y del revisor fiscal antes de apagar el sistema anterior.

**Entregable**Sistema en producción, manual de operación y acta de aprobación.

D · Anexo

## Archivos de Excel

El libro vive en la base de datos, pero el control de lotes, ventas y tasas debe poder abrirse en Excel. Es el archivo que revisa el contador para la declaración de renta y el que sigue un auditor para recorrer una operación de principio a fin. Esta sección define cómo se organiza.

**Regla de oro**

El Excel es una copia generada desde el libro, no el libro. Si alguien edita celdas a mano, el archivo deja de coincidir con la contabilidad. Por eso se genera automáticamente, se sella con un hash y se entrega en solo lectura.

### 1. Qué preguntas debe responder el archivo

### ¿Cuándo?

Fecha de cada compra y de cada venta.

### ¿Qué cripto?

Activo (USDT, BTC, ETH) y red (TRC-20, ERC-20, Bitcoin, Ethereum).

### ¿De dónde y hacia dónde?

Hash de la transacción, wallet, cliente o exchange y asiento contable.

### ¿Se vendió?

Estado de cada lote: disponible, parcial o vendido, y cuánto queda.

### ¿A qué tasa?

Precio unitario de compra y de venta, y la TRM o precio de referencia usado.

### ¿Cuánto ganó y qué impuesto?

Utilidad realizada, días de tenencia y tipo de impuesto.

### 2. Hojas del archivo

| Hoja | Para qué sirve | Quién la usa |
| --- | --- | --- |
| LOTES | Cada compra de cripto como un lote, con su costo y su estado. | Tesorería, contador |
| VENTAS | Cada venta, a qué tasa, y la utilidad que dejó. | Tesorería, contador |
| TRAZABILIDAD | Qué lote o lotes cubrieron cada venta. Une compras con ventas. | Auditoría, contador |
| INVENTARIO | Saldo por activo, red y wallet, comparado con el saldo on-chain. | Tesorería, cumplimiento |
| TASAS | TRM y precios de referencia por fecha, con su fuente. | Contador |
| RESUMEN | Utilidad por mes, activo y tipo de impuesto, y saldos a 31 de diciembre. | Gerencia, contador |
| CONTROL | Fecha de generación, hash del archivo, raíz de Merkle del día e ID del anclaje. | Auditoría |
| AJUSTES\_CONTADOR | Notas y ajustes del contador, sin tocar las hojas de origen. | Contador |

```
LOTES (compras) ──┐
                  ├──► TRAZABILIDAD ──► RESUMEN (impuestos, patrimonio)
VENTAS ───────────┘
TASAS ──► alimenta LOTES, VENTAS e INVENTARIO
CONTROL ──► sella el archivo con hash y anclaje
```

### 3. Hoja LOTES (compras)

| Columna | Contenido | Ejemplo |
| --- | --- | --- |
| ID lote | Identificador único que no se reutiliza. | L-0001 |
| Fecha de compra | Formato AAAA-MM-DD. | 2026-10-14 |
| Activo | USDT, BTC o ETH. | USDT |
| Red | TRC-20, ERC-20, Bitcoin o Ethereum. | TRC-20 |
| Cantidad comprada | Hasta 8 decimales. | 1.000 |
| Precio unitario (COP) | Lo que costó cada unidad. | 4.000 |
| Costo total (COP) | Cantidad por precio unitario. | 4.000.000 |
| Tasa usada | TRM o precio de referencia, con su fuente. | TRM 4.000 |
| Comisiones (COP) | Bancarias, de exchange o de red asociadas a la compra. | 0 |
| Costo fiscal (COP) | Costo total más comisiones, según lo defina el contador. | 4.000.000 |
| Clasificación | Inventario, activo fijo o inversión. | Inversión |
| Origen | De dónde vino: Binance OTC, banco o cliente. | Binance OTC |
| Hash o ID de operación | Hash on-chain o ID de la operación en el exchange o banco. | TX-a91f… |
| Wallet destino | Alias o dirección de la wallet que recibió. | WAL-TRX-01 |
| Cantidad disponible | Lo que queda sin vender (fórmula). | 1.000 |
| Estado | Disponible, parcial o vendido (fórmula). | Disponible |
| ID asiento | Asiento del libro que respalda la compra. | A-000123 |

### 4. Hoja VENTAS

| Columna | Contenido | Ejemplo |
| --- | --- | --- |
| ID venta | Identificador único. | V-0001 |
| Fecha de venta | Formato AAAA-MM-DD. | 2026-12-20 |
| Activo y red | Qué se vendió y por qué red. | USDT TRC-20 |
| Cantidad vendida | Unidades vendidas. | 1.000 |
| Precio unitario de venta (COP) | A qué tasa se vendió. | 4.300 |
| Tasa usada | TRM o precio de referencia del día de venta, con su fuente. | TRM 4.300 |
| Ingreso total (COP) | Cantidad por precio de venta. | 4.300.000 |
| Comisiones de venta (COP) | Bancarias, de exchange o de red asociadas a la venta. | 0 |
| Lote(s) usados | IDs de los lotes que cubrieron la venta. | L-0001 |
| Costo fiscal asignado (COP) | Suma tomada de la hoja TRAZABILIDAD. | 4.000.000 |
| Utilidad realizada (COP) | Ingreso menos comisiones menos costo asignado. Si es negativa, es pérdida. | 300.000 |
| Días de tenencia | Fecha de venta menos fecha de compra. | 67 |
| Tipo de impuesto | Renta, ganancia ocasional o mixto. | Renta |
| Tarifa aplicada e impuesto estimado | Referencia para provisionar. La liquidación final la hace el contador. | Según tarifa |
| Contraparte | Cliente o exchange que compró. | Cliente ABC |
| Hash o ID de operación | Evidencia de la venta. | TX-7c2e… |
| ID asiento | Asiento del libro que respalda la venta. | A-000241 |

### 5. Hoja TRAZABILIDAD (lote contra venta)

Una venta puede tomar cripto de varios lotes, y cada lote tiene su propia fecha de compra y su propio costo. Por eso esta hoja tiene una fila por cada porción de lote consumida.

| Columna | Contenido |
| --- | --- |
| ID venta y ID lote | Los dos extremos del vínculo. |
| Cantidad tomada | Cuántas unidades de ese lote se usaron en esa venta. |
| Costo unitario del lote | Costo fiscal por unidad de ese lote. |
| Fecha de compra y fecha de venta | Para calcular el tiempo de tenencia de esa porción. |
| Días de tenencia | De esa porción, no de la venta completa. |
| Utilidad de la porción | Precio de venta menos costo de esa porción. |
| Tipo de impuesto de la porción | Renta o ganancia ocasional, según su propio tiempo de tenencia. |

**Por qué importa**

Si una venta de 1.500 USDT toma 1.000 de un lote de hace 3 años y 500 de un lote de hace 2 meses, una parte paga ganancia ocasional y la otra paga renta. En la hoja VENTAS el tipo de impuesto aparece como "mixto" y el detalle está en TRAZABILIDAD.

**Método de costo y antigüedad**

Para medir el tiempo de tenencia hay que saber de qué lote sale cada unidad vendida. Con PEPS (primero en entrar, primero en salir) o con identificación específica eso es directo. Con promedio ponderado los lotes pierden su identidad, y el contador debe definir cómo se determina la antigüedad. Esta decisión se toma en el paso 1.

### 6. Fórmulas clave

| Campo | Fórmula en Excel (en español) |
| --- | --- |
| Costo total | `=Cantidad*PrecioUnitario` |
| Cantidad disponible | `=CantidadComprada-SUMAR.SI(TRAZABILIDAD!IDLote;IDLote;TRAZABILIDAD!CantidadTomada)` |
| Estado del lote | `=SI(Disponible=0;"Vendido";SI(Disponible<Comprada;"Parcial";"Disponible"))` |
| Días de tenencia | `=FechaVenta-FechaCompra` |
| Tipo de impuesto | `=SI(Clasificacion="Inventario";"Renta";SI(FechaVenta>=FECHA.MES(FechaCompra;24);"Ganancia ocasional";"Renta"))` |
| Utilidad realizada | `=Ingreso-Comisiones-CostoAsignado` |

El tipo de impuesto compara la fecha de venta con la fecha de compra más 24 meses. Si el activo está clasificado como inventario, siempre es renta, sin importar el tiempo.

### 7. Ejemplo con datos ilustrativos

#### Hoja LOTES

| ID lote | Fecha compra | Activo y red | Cantidad | Precio unit. | Costo fiscal | Clasificación | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- |
| L-0001 | 2026-10-14 | USDT TRC-20 | 1.000 | 4.000 | 4.000.000 | Inversión | Vendido |
| L-0002 | 2024-03-03 | USDT TRC-20 | 500 | 3.900 | 1.950.000 | Inversión | Vendido |

#### Hoja VENTAS

| ID venta | Fecha venta | Cantidad | Precio venta | Tasa usada | Ingreso | Lote | Costo asignado | Utilidad | Días | Tipo de impuesto |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V-0001 | 2026-12-20 | 1.000 | 4.300 | TRM 4.300 | 4.300.000 | L-0001 | 4.000.000 | 300.000 | 67 | Renta |
| V-0002 | 2026-12-20 | 500 | 4.300 | TRM 4.300 | 2.150.000 | L-0002 | 1.950.000 | 200.000 | 1.022 | Ganancia ocasional |

V-0001 se vendió a los 67 días y su utilidad de 300.000 va a renta. V-0002 se vendió después de más de 2 años y su utilidad de 200.000 paga ganancia ocasional al 15 %, es decir 30.000. Los datos son solo de ejemplo.

### 8. Reglas de uso y versionado

1. **Se genera solo.** Un proceso diario crea el archivo desde el libro. Nadie digita datos en LOTES, VENTAS ni TRAZABILIDAD.
2. **Una fila por transacción.** Sin celdas combinadas, fechas en formato AAAA-MM-DD y montos como número, sin texto ni símbolos.
3. **Precisión.** Excel guarda unos 15 dígitos significativos. En el archivo las cantidades se muestran con hasta 8 decimales para control, y la precisión completa queda en el libro.
4. **Nombre y versión.** Archivo diario: `control-cripto_AAAA-MM-DD_vN.xlsx`. Cierre de mes: `control-cripto_cierre_AAAA-MM_vN.xlsx`.
5. **Sellado.** El hash SHA-256 de cada archivo se guarda en la hoja CONTROL y en el libro, y entra en la raíz de Merkle del día que se ancla en blockchain. Así el contador puede probar que su archivo es el original.
6. **Correcciones.** Se hacen en el libro con un asiento de reverso y el archivo se regenera. El contador anota sus ajustes en AJUSTES\_CONTADOR, nunca sobre las hojas de origen.
7. **Acceso.** Los operadores ven el archivo en solo lectura, con las hojas bloqueadas.
8. **Saldos iniciales.** Los lotes comprados antes de que existiera el libro se cargan con su fecha y costo originales, y con su soporte.
9. **Conservación.** Mínimo 5 años, como exige el CARF. El contador define el plazo contable.

**Entregable**Plantilla de Excel con las ocho hojas, fórmulas protegidas y un proceso que la genera y sella cada día.

Parte II · Tema aparte

## Proceso legal para la constitución como proveedor de liquidez en Colombia

Esta parte no habla del libro contable sino de la empresa que lo va a usar. Va separada porque es un tema legal y societario, pero es parte del proyecto: el libro y los reportes de las secciones anteriores le sirven a esta empresa para demostrar cumplimiento.

**Aviso**

Este es un esquema de trabajo, no asesoría jurídica. Los estatutos, el acuerdo entre socios y el contrato con Minus los debe redactar un abogado societario, y los temas tributarios los confirma el contador. Úselo como brief para ahorrar horas de asesoría.

### E.1 Estructura: empresa independiente

La recomendación es constituir una SAS nueva para el proveedor de liquidez, separada de Minus. Minus le licencia la tecnología y cobra por ella.

| Criterio | Empresa independiente (recomendada) | Dentro de Minus |
| --- | --- | --- |
| Riesgo regulatorio | El riesgo de la UIAF, SAGRILAFT y la DIAN queda aislado. Un problema ahí no toca a Minus. | Todo el riesgo cae sobre el negocio de automatización. |
| Bancos | Pueden abrir cuenta a una empresa con un solo objeto social, más claro de evaluar. | Un banco que ve cripto dentro de una agencia de IA puede cerrar la cuenta de todo Minus. |
| Clientes de Minus | Los clientes inmobiliarios y de construcción no se mezclan con cripto. | El nombre de Minus queda ligado a la actividad cripto. |
| Contabilidad e impuestos | Libros, ICA e inventario cripto propios. | Mezcla ingresos de servicios con compraventa de activos y complica ICA y renta. |
| Venta o inversión | Se puede vender o recibir inversión en una sola de las dos. | Para vender una, hay que separarla primero. |
| Costo | Constitución, cuentas, contador y revisor fiscal duplicados. | Más barato al inicio. |

Dentro de Minus solo tendría sentido si no se van a mover fondos de clientes ni activos propios en volumen, es decir, si en la práctica solo se vende software de trazabilidad.

### E.2 Constitución paso a paso

La forma más común es una SAS (Ley 1258 de 2008), por documento privado inscrito en la Cámara de Comercio. Solo se necesita escritura pública si se aportan bienes que la exigen, como inmuebles.

| Paso | Qué se hace | Dónde |
| --- | --- | --- |
| 1 | Verificar que el nombre esté disponible. | RUES |
| 2 | Redactar los estatutos y el acuerdo entre socios (E.4). | Abogado societario |
| 3 | Inscribir la sociedad y obtener la matrícula mercantil. | Cámara de Comercio |
| 4 | Sacar el RUT y el NIT, y agregar las responsabilidades que correspondan a la actividad, como la 67 (Res. 000240/2025). Confirmar cuál aplica. | DIAN y contador |
| 5 | Abrir la cuenta bancaria. El objeto social y la explicación del negocio pesan mucho. | Banco |
| 6 | Inscribirse en el ICA del municipio, activar facturación electrónica y contratar contador. | Municipio, DIAN, contador |
| 7 | Montar el cumplimiento antes de operar: oficial de cumplimiento, manual SAGRILAFT y registro ante la UIAF (E.6). | Cumplimiento |

El revisor fiscal es obligatorio solo si se superan ciertos topes de activos o ingresos. Se revisa cada año con el contador.

### E.3 Objeto social

Conviene que sea específico, porque los bancos lo leen.

- Compraventa, intermediación y custodia de activos virtuales por cuenta propia.
- Provisión de liquidez a empresas y personas.
- Consultoría en operaciones con activos virtuales.
- Al final, cualquier otra actividad comercial lícita.

El desarrollo de software no va en este objeto. Eso lo hace Minus.

### E.4 Acuerdo entre los dos socios

Con dos socios, estos puntos deben quedar por escrito antes de constituir.

| Tema | Recomendación |
| --- | --- |
| Participación | Una división desigual, por ejemplo 51/49, evita bloqueos. Con 50/50 se necesita una regla de desempate. |
| Roles | Un representante legal principal y un suplente. Una persona lidera lo comercial y otra la tecnología. |
| Aportes | Quién aporta capital, quién aporta trabajo y qué pasa si alguien no aporta. |
| Permanencia | Acciones que se ganan en el tiempo (vesting) y cláusulas de salida si un socio se va. |
| Decisiones | Cuáles requieren acuerdo de ambos: endeudarse, vender, cambiar el objeto, admitir socios. |
| Dividendos | Cuánto se reparte y cuánto queda como reserva para cubrir el riesgo de operación. |
| Exclusividad | Que ninguno haga el mismo negocio por fuera. |
| Propiedad intelectual | Cesión firmada de todo lo construido hacia Minus. |

**Partes vinculadas**

Los mismos dos socios serán dueños de ambas empresas. El contrato entre ellas es una operación entre vinculados: debe pactarse a precio de mercado y quedar aprobado por escrito por los socios. Si no, la DIAN o un banco pueden cuestionar el precio.

### E.5 Contrato entre la nueva empresa y Minus

Un contrato marco con dos anexos.

### Anexo 1 · Licencia de uso

Modalidad SaaS. Minus conserva la propiedad del código y la SAS recibe el derecho de usarlo, con tarifa mensual.

### Anexo 2 · Desarrollo y mantenimiento

Lo que Minus construye o ajusta para la SAS, cobrado por proyecto o por horas.

#### Cláusulas que no deben faltar

| Cláusula | Qué dice |
| --- | --- |
| Objeto y alcance | Qué módulos se licencian: libro, agentes, trazabilidad, reportes. |
| Propiedad intelectual | El código es de Minus. Los datos del libro son siempre de la SAS. |
| Precio | A precio de mercado, con la forma de ajuste anual. Anotar cómo se justificó. |
| Nivel de servicio | Disponibilidad, tiempos de respuesta y soporte. |
| Seguridad | Minus nunca guarda llaves privadas ni mueve fondos (principio del paso 14). |
| Datos personales | Ley 1581: quién es responsable y quién es encargado del tratamiento. |
| Confidencialidad | En ambos sentidos. |
| Salida | Qué pasa al terminar: entrega de datos, exportación del libro y plazo de transición. |
| Responsabilidad | Límite de responsabilidad de Minus por errores del software. |
| Cumplimiento | Minus no actúa como operador. La responsabilidad ante la UIAF y la DIAN es de la SAS. |

**Impuestos del contrato**

La licencia y los servicios llevan IVA y retención en la fuente. La compraventa de cripto no lleva IVA, lo que puede limitar el descuento del IVA pagado a Minus. Confirmarlo con el contador antes de fijar la tarifa.

### E.6 Antes de operar con clientes

- **UIAF.** Registro y reportes mensuales de clientes y transacciones (Res. 314/2021).
- **SAGRILAFT.** Oficial de cumplimiento, manual y debida diligencia intensificada para activos virtuales (Supersociedades, Cap. X).
- **DIAN.** Responsabilidad en el RUT y reportes CARF (Res. 000240/2025).
- **Libro.** Los pasos 11 a 15 de la Parte I entregan los reportes que estas entidades piden.
- **Licencia.** En Colombia no existe una licencia específica para esta actividad. La protección es el cumplimiento demostrable.

### E.7 Orden recomendado y entregables

| Orden | Documento o acto | Quién |
| --- | --- | --- |
| 1 | Cesión de propiedad intelectual entre los socios hacia Minus | Abogado |
| 2 | Acuerdo entre socios de la nueva SAS | Abogado |
| 3 | Estatutos e inscripción de la SAS | Abogado y Cámara de Comercio |
| 4 | RUT, cuenta bancaria, ICA y facturación | Contador |
| 5 | Contrato marco con Minus y sus anexos | Abogado |
| 6 | Manual SAGRILAFT, oficial de cumplimiento y registro UIAF | Cumplimiento |

**Entregable**SAS constituida, acuerdo entre socios firmado, contrato con Minus y cumplimiento listo para operar.

F · Cierre

## Cronograma

| Fase | Pasos | Semanas | Responsable |
| --- | --- | --- | --- |
| 1 · Diseño | 1 a 3 | 1–3 | Producto + contador |
| 2 · Núcleo del libro | 4 a 6 | 3–6 | Backend / datos |
| 3 · Conexiones | 7 a 10 | 5–10 | Backend + contador |
| 4 · Control | 11 a 15 | 9–14 | Backend + cumplimiento |

Las fases 2 y 3 se solapan: los conectores se pueden construir mientras se termina el núcleo.

G · Control de versiones

| Versión | Fecha | Cambios |
| --- | --- | --- |
| v1.7 | 14 oct 2026 | Nueva Parte II, sección E: proceso legal para la constitución como proveedor de liquidez en Colombia (estructura independiente, constitución paso a paso, objeto social, acuerdo entre socios, contrato con Minus, cumplimiento y orden de entregables). Cronograma y Control de versiones pasan a F y G. |
| v1.6 | 14 oct 2026 | Paso 12 ampliado: USDT recibidos de otros países (tratamiento según el motivo del pago), caso Binance Argentina a Colombia sin arancel, renta, ICA, IVA y GMF, y fila de ICA en los reportes. |
| v1.5 | 14 oct 2026 | Paso 14 ampliado: reporte y documentación de la billetera fría propia (qué reporta Binance, qué se declara, transferencias internas, prueba de control, reglas Binance–fría). |
| v1.4 | 14 oct 2026 | Sección C ampliada: cómo construir ahora y activar al ingresar dinero, ficha de cada herramienta (costo, proceso, área, función, qué pasa si no se usa y cuándo se activa) presupuesto por etapa y enlace oficial con indicaciones de acceso en cada ficha. Nueva entrada C.1 en el índice. |
| v1.3 | 14 oct 2026 | Nueva sección C, Herramientas necesarias para la trazabilidad en la blockchain: exploradores (Etherscan, Tronscan, mempool.space), APIs y nodos, analítica de riesgo, custodia, sellado, procedimiento de trazado wallet a wallet y orden de adopción. Las secciones Excel, Cronograma y Versiones pasan a D, E y F. |
| v1.2 | 14 oct 2026 | Nueva sección C, Archivos de Excel: hojas, columnas de lotes y ventas, trazabilidad lote-venta, fórmulas, ejemplo y reglas de uso y versionado. |
| v1.1 | 14 oct 2026 | Nuevo paso 12: impuestos y costo fiscal de los criptoactivos (utilidad por lotes, renta vs ganancia ocasional, ejemplo con USDT y reportes). Los pasos 12 a 14 anteriores pasan a ser 13 a 15. |
| v1.0 | 14 oct 2026 | Versión inicial: arquitectura en capas y paso a paso de 14 pasos en 4 fases para libro contable con anclaje en blockchain y trazabilidad de USDT, BTC, ETH, USD y COP. |

El tratamiento contable y tributario (clasificación de criptoactivos, método de costo, reglas de asientos) debe validarse con el contador antes de producción. Los umbrales de confirmación por red son configurables.

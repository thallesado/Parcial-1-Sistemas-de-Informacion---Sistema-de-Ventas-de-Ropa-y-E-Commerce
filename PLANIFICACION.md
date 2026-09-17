# Planificación y modelado de Vesta

Documento base para orientar el desarrollo del proyecto de Sistemas de
Información 2 y preparar la defensa del 23 de septiembre de 2026.

## 1. Decisión de alcance

Vesta será un sistema integrado para una cadena de tiendas de ropa con ventas
presenciales y comercio electrónico. El problema central que resuelve es la
falta de información unificada sobre ventas, clientes e inventario por
sucursal, incluyendo la continuidad operativa cuando una caja pierde conexión.

La defensa debe demostrar un flujo completo y coherente, no una gran cantidad de
pantallas desconectadas. El MVP se limitará a:

1. Inicio de sesión con roles básicos.
2. Catálogo con productos y variantes/SKU.
3. Consulta de stock por sucursal.
4. Venta POS con cliente opcional, método de pago y comprobante demo.
5. Carrito y pedido e-commerce.
6. Actualización de inventario compartido entre POS y pedidos.
7. Transferencia simple de stock entre almacén y sucursal.
8. Reportes básicos de ventas e inventario.
9. Flujo offline demostrable: guardar una venta local, sincronizarla una vez
   recuperada la conexión e impedir duplicados mediante idempotencia.

El probador virtual y los reportes conversacionales serán módulos diferenciadores
fuera del camino crítico. Para la defensa pueden presentarse como prototipo
aislado o diseño validado, pero no deben retrasar ventas, inventario y
persistencia.

## 2. Inconsistencia tecnológica que debe resolverse

El código existente usa Flutter Web y Dart, mientras que el requisito académico
indica React para web, React Native para móvil, NestJS para backend y PostgreSQL.
Estas alternativas no deben mezclarse sin una decisión explícita.

La recomendación es:

- **Objetivo de arquitectura:** React Web/POS, React Native móvil, NestJS API y
  PostgreSQL.
- **Código actual:** conservarlo como prototipo visual de referencia, no
  presentarlo como la implementación final del stack obligatorio.
- **MVP de defensa:** priorizar React Web/POS y NestJS/PostgreSQL. React Native
  puede quedar como cliente futuro si el docente exige una demostración móvil,
  porque duplicar el desarrollo completo en seis días aumenta demasiado el
  riesgo.
- **Azure:** utilizar App Service para la API y Azure Database for PostgreSQL.
  Azure Storage solo es necesario para imágenes; Azure Monitor puede agregarse
  como observabilidad básica. Redis, CDN y servicios de IA quedan fuera del MVP.

Si el docente permite Flutter, la alternativa de menor riesgo es conectar el
frontend actual a NestJS y PostgreSQL. Esa decisión debe confirmarse antes de
reescribir la interfaz.

### Estado de implementación del backend

Ya se implementó el primer corte en `backend/`: NestJS, TypeORM, PostgreSQL,
esquema SQL reproducible, datos semilla, autenticación básica y CRUD de
categorías, productos, variantes, sucursales, clientes e inventario. También se
implementó la creación transaccional de ventas con bloqueo pesimista,
movimientos de inventario e idempotencia por `operationId`.

## 3. Actores

| Actor | Responsabilidad principal |
| --- | --- |
| Cliente | Consultar catálogo, comprar y consultar pedidos |
| Vendedor | Registrar ventas POS y asociar clientes |
| Encargado de inventario | Consultar, ajustar y transferir stock |
| Encargado de sucursal | Supervisar caja, stock y operación local |
| Administrador | Gestionar catálogo, usuarios, roles y parámetros |
| Gerente | Consultar reportes y tomar decisiones de reposición |
| Pasarela de pago | Confirmar o rechazar pagos; sistema externo |
| Servicio de sincronización | Procesar operaciones offline pendientes |

No se agrega un actor de almacén separado en el MVP: el encargado de inventario
puede operar tanto el almacén central como las sucursales según sus permisos.

## 4. Alcance y fuera de alcance

### Dentro del alcance del MVP

- Una organización con múltiples sucursales y un almacén central.
- Productos, categorías y variantes con SKU, talla y color.
- Stock separado por ubicación.
- Ventas POS y pedidos web que afectan el mismo saldo.
- Clientes registrados y cliente anónimo para POS.
- Usuarios con roles: administrador, vendedor, inventario y gerente.
- Transferencias, movimientos de stock y alertas de stock mínimo.
- Pago demo o integración sandbox.
- Reportes operativos con filtros por fechas y sucursal.
- Cola offline de ventas POS con UUID e idempotency key.

### Fuera del camino crítico

- Nómina, contratos y recursos humanos completos.
- Predicción avanzada de demanda.
- Recomendaciones personalizadas.
- Facturación fiscal real, si requiere integración externa no disponible.
- Chatbot con modelo generativo conectado a datos productivos.
- Probador virtual avanzado con detección corporal.
- Aplicación móvil completa, salvo que el docente la exija expresamente.

## 5. Reglas de negocio iniciales

1. Cada variante vendible tiene un SKU único.
2. El stock pertenece a una ubicación y a una variante, nunca al producto
   genérico.
3. Una venta confirmada disminuye el saldo disponible de su ubicación.
4. Un pedido web solo se confirma si existe stock reservado suficiente.
5. El POS puede vender como cliente anónimo, pero una cuenta registrada permite
   historial y beneficios posteriores.
6. Una transferencia debe tener origen, destino, estado, usuario solicitante,
   detalle de variantes y cantidades.
7. No se permite transferir desde una ubicación sin stock disponible.
8. Los movimientos de inventario son inmutables; una corrección se registra
   mediante un movimiento inverso o ajuste autorizado.
9. El saldo actual se mantiene en `inventory_balance`; el historial se conserva
   en `inventory_movement`.
10. Toda operación sincronizable tiene un `operation_id` único y una
    `idempotency_key`; repetirla no debe crear una segunda venta.
11. Una venta offline se acepta localmente con estado pendiente, pero el
    backend valida el stock al sincronizar.
12. Si dos ventas offline generan conflicto de stock, se conserva la primera
    operación aceptada por el backend y la segunda queda rechazada o pendiente
    de resolución; nunca se permite saldo negativo silencioso.
13. Los permisos se validan en backend, aunque el frontend oculte opciones no
    autorizadas.

## 6. Requerimientos funcionales del MVP

| ID | Requerimiento |
| --- | --- |
| RF-01 | El sistema debe autenticar usuarios y asignar permisos por rol. |
| RF-02 | El cliente debe buscar, filtrar y consultar variantes del catálogo. |
| RF-03 | El sistema debe mostrar disponibilidad por sucursal. |
| RF-04 | El cliente debe crear y modificar un carrito. |
| RF-05 | El cliente debe confirmar un pedido con dirección, envío y pago demo. |
| RF-06 | El vendedor debe crear ventas POS por SKU o código de barras. |
| RF-07 | El POS debe permitir cliente, cantidades y método de pago. |
| RF-08 | Las ventas y pedidos confirmados deben registrar movimientos y actualizar stock. |
| RF-09 | Inventario debe registrar entradas, salidas, ajustes y transferencias. |
| RF-10 | El sistema debe mostrar reportes básicos por periodo, sucursal y producto. |
| RF-11 | El POS debe guardar operaciones cuando no haya conexión. |
| RF-12 | El sistema debe sincronizar operaciones pendientes sin duplicarlas. |
| RF-13 | El sistema debe registrar auditoría de operaciones sensibles. |

## 7. Requerimientos no funcionales

- **Integridad:** ventas e inventario se actualizan en una transacción de
  PostgreSQL.
- **Seguridad:** contraseñas con hash, JWT de corta duración, autorización por
  rol, validación de DTO y consultas parametrizadas.
- **Disponibilidad:** el POS puede registrar ventas básicas sin conexión.
- **Rendimiento:** catálogo paginado; índices en SKU, sucursal, variante,
  estado y fechas de venta.
- **Trazabilidad:** cada venta, ajuste, transferencia y sincronización queda
  asociada a usuario, dispositivo y fecha.
- **Escalabilidad:** el ledger de movimientos puede particionarse por fecha si
  el volumen lo exige; no se introduce microservicios en el MVP.
- **Mantenibilidad:** NestJS modular por dominio, validación centralizada y
  pruebas de servicios críticos.

## 8. Casos de uso prioritarios

### CU-01 Comprar en línea

Cliente consulta una variante, la agrega al carrito, indica dirección y envío,
realiza el pago demo y confirma el pedido. El sistema reserva o descuenta stock,
registra el pedido y muestra su número y estado.

### CU-02 Registrar venta presencial

Vendedor inicia sesión, selecciona sucursal y caja, escanea variantes, asocia un
cliente opcional, cobra y confirma. El sistema registra venta, pago, detalle,
movimiento de salida y nuevo saldo.

### CU-03 Transferir inventario

Encargado solicita una transferencia desde almacén central a una sucursal. El
sistema valida cantidades, registra estados solicitada, enviada y recibida, y
actualiza los saldos en cada transición.

### CU-04 Sincronizar venta offline

El POS genera una operación local con UUID, la agrega a la cola y permite
continuar trabajando. Al recuperar conexión, envía la operación; el backend
responde idempotentemente y devuelve aceptada, duplicada o rechazada por
conflicto de stock.

### CU-05 Consultar reporte

Gerente selecciona fechas, sucursal, vendedor o producto y obtiene un reporte
paginado. El chatbot futuro deberá convertir lenguaje natural a filtros
estructurados validados, nunca a SQL generado libremente.

## 9. Modelo de datos recomendado

La decisión importante es separar el concepto comercial de sus canales: `sale`
representa una transacción confirmada, mientras `order` representa el pedido
web y su ciclo logístico. Ambos pueden tener una referencia a una entidad común
`commercial_transaction` si se necesita consolidar reportes, pero no conviene
forzar pedido y venta a ser la misma tabla mientras sus estados y procesos sean
distintos.

### Seguridad y organización

`user`, `role`, `user_role`, `employee`, `branch`, `warehouse`, `cash_register`,
`pos_device`.

### Catálogo

`category`, `brand`, `product`, `size`, `color`, `product_variant`,
`product_price`, `product_image`.

### Clientes y e-commerce

`customer`, `address`, `customer_address`, `cart`, `cart_item`, `favorite`.

### Inventario

`inventory_balance`, `inventory_movement`, `stock_transfer`,
`stock_transfer_item`, `stock_adjustment`.

### Ventas y pedidos

`sale`, `sale_item`, `order`, `order_item`, `order_status_history`.

### Pagos y logística

`payment`, `payment_method`, `receipt`, `shipment`, `shipment_status_history`.

### Offline y auditoría

`sync_operation`, `sync_attempt`, `audit_event`.

Relaciones esenciales:

```text
product 1--N product_variant
product_variant 1--N inventory_balance
warehouse/branch 1--N inventory_balance
sale 1--N sale_item
order 1--N order_item
sale/order N--1 customer (customer puede ser NULL en POS)
inventory_balance 1--N inventory_movement
stock_transfer 1--N stock_transfer_item
sync_operation 1--1 sale (cuando la operación offline es una venta)
```

Restricciones principales:

- `product_variant.sku` UNIQUE.
- `(location_id, variant_id)` UNIQUE en `inventory_balance`.
- `sale.external_operation_id` UNIQUE cuando proviene de offline.
- `order.order_number` UNIQUE.
- Cantidades y precios mayores que cero cuando corresponda.
- Índices en `(location_id, variant_id)`, `sku`, `(status, created_at)` y
  `(customer_id, created_at)`.

## 10. Arquitectura objetivo

```text
React Web / POS       React Native
        \                 /
             NestJS API
       Auth | Catalog | Sales
       Inventory | Reports | Sync
                    |
             PostgreSQL Azure
                    |
      Azure Storage / Monitor
```

El backend debe ser un monolito modular, no microservicios. Los módulos
NestJS iniciales serán `auth`, `catalog`, `inventory`, `sales`, `orders`,
`reports` y `sync`. El repositorio debe separar controller, service, repository,
DTO y entidad/mapeo de persistencia.

El flujo offline debe usar almacenamiento local del cliente, preferentemente
IndexedDB para POS Web o SQLite para React Native. La cola guarda payload,
UUID, idempotency key, estado, intentos y último error. El backend usa una
restricción UNIQUE y una transacción para hacer la operación idempotente.

## 11. Backlog y sprints de emergencia

### Sprint 0: diseño y decisión

- Confirmar stack permitido.
- Congelar alcance y reglas de negocio.
- Crear modelo lógico mínimo.
- Definir contrato de API y datos seed.

### Sprint 1: núcleo operativo

- NestJS, PostgreSQL y migraciones.
- Login/roles.
- Catálogo con variantes.
- Sucursales y saldo de inventario.
- Endpoint transaccional de venta POS.

### Sprint 2: e-commerce e integración

- Carrito y pedido.
- Pago demo.
- Transferencia de stock.
- Reportes básicos.
- Cliente web conectado a API.

### Sprint 3: offline, pruebas y defensa

- Cola offline y sincronización idempotente.
- Pruebas de conflicto de inventario.
- Despliegue en Azure.
- Evidencias, manual y guion de defensa.

Si el tiempo real no permite completar los tres sprints, se debe presentar un
MVP reducido con login, catálogo, variante, inventario, venta POS persistida,
un pedido web y una demostración offline controlada.

## 12. Definition of Done

Una historia se considera terminada cuando:

- Tiene criterios de aceptación verificables.
- La validación ocurre en backend y frontend cuando corresponde.
- Incluye prueba del servicio crítico.
- Persiste datos correctamente o documenta por qué es una simulación.
- Maneja error y estado de carga.
- Está integrada en la rama principal.
- Tiene evidencia para la defensa.

## 13. Plan mínimo de pruebas

| ID | Caso | Resultado esperado |
| --- | --- | --- |
| CT-01 | Login con rol válido | Acceso según permisos |
| CT-02 | SKU inexistente | No se agrega al carrito/venta |
| CT-03 | Venta con stock suficiente | Venta confirmada y saldo reducido |
| CT-04 | Venta sin stock | Operación rechazada sin saldo negativo |
| CT-05 | Pedido web confirmado | Pedido y movimiento registrados |
| CT-06 | Transferencia válida | Sale del origen y llega al destino según estados |
| CT-07 | Reenvío de venta offline | Misma venta, no duplicado |
| CT-08 | Dos ventas offline por última unidad | Una aceptada y otra resuelta como conflicto |
| CT-09 | Usuario sin permiso | Backend responde no autorizado |
| CT-10 | Reporte por fecha y sucursal | Resultados correctos y paginados |

## 14. Decisiones que requieren confirmación

1. ¿El docente exige estrictamente React o acepta mantener Flutter?
2. ¿La defensa exige una aplicación móvil funcional o basta con arquitectura
   preparada?
3. ¿Se cuenta con suscripción y recursos disponibles en Azure?
4. ¿El pago será completamente simulado o existe sandbox disponible?
5. ¿Se requiere comprobante fiscal real o basta recibo interno?

Hasta responder estas preguntas no conviene reescribir el frontend ni diseñar
todo el modelo físico: son decisiones que pueden cambiar el esfuerzo del MVP.

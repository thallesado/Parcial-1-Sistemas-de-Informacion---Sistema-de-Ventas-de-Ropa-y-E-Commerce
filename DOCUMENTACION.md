# Documentación del proyecto Vesta

## 1. Identificación y propósito

Vesta es un prototipo académico para la materia Sistemas de Información 2.
Representa una marca de moda con dos perspectivas relacionadas:

- **Experiencia comercial:** catálogo web, búsqueda, filtros, favoritos,
  comparación, detalle de producto, bolsa y navegación responsive.
- **Sistema interno:** panel de operaciones, inventario por sucursal, punto de
  venta y explorador conceptual del modelo de datos.

El objetivo actual es demostrar la experiencia de usuario, los procesos que el
sistema debería soportar y una propuesta de arquitectura de información. No es
todavía un sistema productivo: los datos se cargan en memoria y no existe una
API, autenticación, persistencia ni integración con servicios externos.

## 2. Estado general

| Área | Estado actual |
| --- | --- |
| Frontend Flutter Web | Implementado como prototipo navegable y responsive |
| Catálogo y productos | Implementados con datos demo en memoria |
| Estado de sesión y navegación | Simulados localmente con `ChangeNotifier` |
| Panel administrativo | Implementado como vista demostrativa con métricas fijas y datos del catálogo |
| Punto de venta | Flujo de venta simulado, sin cobro ni descuento real de inventario |
| Modelo de datos | Definido de forma conceptual e interactiva dentro del frontend |
| Backend | Solo estructura de carpetas y README |
| Base de datos | No creada ni conectada |
| Pruebas automatizadas | No hay pruebas de aplicación; solo está creada la carpeta `backend/tests` |

## 3. Tecnologías y organización

### Frontend

- Flutter para web.
- Dart SDK `>=3.3.0 <4.0.0`.
- Material 3 y `flutter_lints`.
- Recursos estáticos en `frontend/assets/images/`.
- No se utilizan dependencias externas de negocio ni cliente HTTP en el estado
  actual.

El punto de entrada es [frontend/lib/main.dart](frontend/lib/main.dart). Allí
se crea `VestaApp`, se inicializa `ShopController` y se monta el tema y el
`StoreShell` principal.

### Backend

La carpeta `backend/` contiene las capas previstas para una API:

```text
backend/src/
├── config/
├── controllers/
├── middlewares/
├── models/
├── repositories/
├── routes/
├── services/
└── utils/
```

Actualmente esas carpetas contienen únicamente archivos `.gitkeep`. No se ha
seleccionado todavía un framework de servidor, motor de base de datos ni
estrategia de autenticación.

## 4. Arquitectura actual del frontend

La aplicación está organizada por responsabilidades y funcionalidades:

- `config/`: colores y temas claro/oscuro.
- `controllers/`: estado global de la demo y operaciones de catálogo.
- `models/`: entidad `Product` y sus propiedades derivadas como stock total,
  stock bajo y porcentaje de descuento.
- `services/`: fuentes de datos demo, principalmente `CatalogService`.
- `middlewares/`: punto de extensión para autorización futura.
- `routes/`: nombres de rutas previstos.
- `utils/`: breakpoints y reglas responsive.
- `features/`: pantallas y widgets agrupados por dominio.

El flujo principal es:

```text
main.dart
  -> VestaApp
  -> ShopController + ShopScope
  -> StoreShell
  -> pantalla según DemoSection
```

`ShopController` mantiene en memoria la sección actual, categoría, consulta,
sucursal, filtros, ordenamiento, favoritos, comparación, historial, alertas y
carrito. Los cambios llaman a `notifyListeners()` y la interfaz se actualiza a
través de `AnimatedBuilder` e `InheritedNotifier`.

## 5. Funcionalidades implementadas

### 5.1 Inicio y navegación

- Barra promocional y navegación de marca Vesta.
- Accesos a categorías, novedades, ocasiones y ofertas.
- Navegación de escritorio mediante encabezado y de móvil mediante navegación
  inferior y menú.
- Selector de sucursal: Equipetrol, Centro, Cochabamba y La Paz.
- Cambio de tema claro/oscuro.
- Adaptación de encabezado, grillas y columnas según el ancho de pantalla.

Archivos principales: [store_shell.dart](frontend/lib/src/features/shell/views/store_shell.dart),
[home_page.dart](frontend/lib/src/features/home/views/home_page.dart) y
[responsive.dart](frontend/lib/src/utils/responsive.dart).

### 5.2 Catálogo

- Productos demo con SKU, nombre, categoría, precio, descuento, material,
  corte, estilo, ocasión, tallas, valoración y stock por sucursal.
- Búsqueda por nombre, categoría, SKU o material.
- Corrección de algunas búsquedas frecuentes.
- Filtros por talla, color, material, corte, estilo, ocasión, precio, descuento
  y disponibilidad en la sucursal seleccionada.
- Orden por recomendación, novedad, precio y descuento.
- Vista amplia o compacta y carga progresiva de resultados.
- Favoritos y comparación de hasta tres productos.
- Historial local de productos vistos.

La lógica de filtrado y ordenamiento se concentra en
[shop_controller.dart](frontend/lib/src/controllers/shop_controller.dart), y la
presentación en [catalog_page.dart](frontend/lib/src/features/catalog/views/catalog_page.dart).

### 5.3 Detalle de producto

- Galería con distintas alineaciones de la imagen y zoom.
- Selección de color y talla.
- Guía de medidas, composición, origen, cuidados y opiniones demo.
- Aviso de reposición y aviso de reducción de precio, guardados solo en memoria.
- Agregado a una bolsa local.
- Copia de un enlace de producto al portapapeles.
- Productos relacionados para completar el look.

La vista se encuentra en
[product_detail_dialog.dart](frontend/lib/src/features/catalog/widgets/product_detail_dialog.dart).

### 5.4 Administración

El dashboard presenta:

- Métricas demostrativas de ventas, pedidos, visitas y stock bajo.
- Contexto de usuario, perfil y sucursal.
- Acceso al POS y al explorador del modelo de datos.
- Inventario crítico calculado a partir del catálogo en memoria.
- Accesos informativos para recursos humanos e inventario.

Las métricas de ventas, pedidos y visitas son valores fijos de demostración; el
listado de inventario sí se calcula con los productos cargados localmente.

### 5.5 Punto de venta

- Búsqueda por SKU o nombre.
- Selección de prendas y cantidades.
- Cliente demo intercambiable.
- Cálculo de subtotal y total.
- Selector de sucursal.
- Indicador visual de modo sincronizado u offline.
- Confirmación de cobro simulado o guardado local en cola.

El POS no realiza pagos, no crea una orden persistente y no actualiza el stock.
Está implementado en [pos_page.dart](frontend/lib/src/features/pos/views/pos_page.dart).

### 5.6 Explorador conceptual de datos

El módulo de base de datos permite buscar y agrupar tablas, inspeccionar campos,
tipos, claves y relaciones. El catálogo conceptual contempla dominios como:

- Identidad y acceso.
- Sucursales.
- Recursos humanos.
- Catálogo.
- Inventario.
- Clientes y CRM.
- Ventas y pedidos.

La definición se encuentra en
[schema_catalog_service.dart](frontend/lib/src/features/database/services/schema_catalog_service.dart)
y [schema_definition.dart](frontend/lib/src/features/database/models/schema_definition.dart).
Es una representación de diseño, no un esquema ejecutado en un motor SQL.

## 6. Cómo se fue trabajando

Por la estructura y el nivel actual de implementación, el trabajo se puede
describir en estas etapas:

1. **Definición del concepto:** se estableció Vesta como comercio de moda con
   operación omnicanal y sucursales.
2. **Diseño de experiencia:** se construyeron inicio, catálogo, detalle de
   producto, favoritos, comparación y navegación responsive.
3. **Modelado de dominio:** se creó `Product` con atributos comerciales y stock
   por sucursal, y `CatalogService` con datos representativos.
4. **Centralización del estado:** se incorporó `ShopController` para coordinar
   navegación, búsqueda, filtros, bolsa, alertas, favoritos y tema.
5. **Extensión al sistema interno:** se agregaron dashboard, inventario visual,
   POS y la selección de sucursal.
6. **Diseño de información:** se definieron tablas, campos y relaciones para
   orientar la futura base de datos y se construyó un explorador visual.
7. **Preparación de integración:** se reservaron las capas del backend y un
   guard de acceso para conectar autenticación y permisos posteriormente.

Estas etapas describen lo que evidencia el código actual; no implican que ya
exista un historial de commits o una implementación de backend detrás de ellas.

## 7. Pendientes de implementación

### Prioridad alta: convertir el prototipo en sistema real

- Elegir y configurar framework del backend.
- Crear la base de datos a partir del esquema conceptual.
- Implementar migraciones, relaciones, índices y restricciones.
- Exponer API para catálogo, sucursales, inventario, clientes, carrito, pedidos
  y ventas.
- Reemplazar los datos constantes de `CatalogService` por repositorios y
  llamadas a la API.
- Implementar autenticación, manejo de sesión, roles y permisos.
- Conectar el `DemoAccessGuard` a permisos reales.

### Prioridad funcional

- Persistir usuarios, favoritos, historial, carrito y alertas.
- Implementar creación de pedidos y actualización transaccional de inventario.
- Implementar cobros reales o un proveedor de pagos de prueba.
- Completar sincronización offline del POS, incluyendo reintentos,
  idempotencia y resolución de conflictos.
- Registrar movimientos de inventario, transferencias y compras a proveedores.
- Completar módulos de recursos humanos, turnos, asistencia y nómina.
- Implementar reseñas verificadas, fotos y cupones.

### Calidad y operación

- Agregar pruebas unitarias del controlador y servicios.
- Agregar pruebas de widgets y pruebas de integración de los flujos críticos.
- Incorporar validación de formularios, manejo de errores de red, estados de
  carga y estados vacíos conectados al backend.
- Configurar variables de entorno, logging, seguridad de credenciales y CORS.
- Crear documentación de API y datos de prueba reproducibles.
- Configurar CI para análisis, pruebas y construcción del frontend y backend.

## 8. Riesgos y decisiones pendientes

- El estado global es efímero: al recargar la página se pierde toda interacción.
- Los precios, métricas, opiniones y existencias demo no representan datos
  confiables de negocio.
- La ruta declarada en `AppRoutes` todavía no implementa navegación nombrada
  independiente; `StoreShell` decide la pantalla mediante `DemoSection`.
- El guard de autorización permite siempre el acceso.
- El modelo conceptual debe revisarse antes de migrarlo: definir enums, reglas
  de borrado, índices, auditoría, reservas de stock y consistencia entre
  canales.
- El nombre y la información del cliente del POS están codificados como demo.

## 9. Ejecución y verificación

Requisitos: Flutter instalado con soporte web y un navegador compatible.

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

Para validar el estado estático:

```powershell
cd frontend
flutter analyze
```

La revisión realizada para esta documentación terminó sin errores de análisis
estático en Flutter.

## 10. Conclusión

El entregable actual cumple como prototipo visual y de modelado para explicar
una solución de información orientada a una tienda de moda: permite recorrer la
experiencia del cliente, visualizar operaciones internas y discutir una base de
datos futura. El siguiente salto de trabajo no es agregar más pantallas, sino
construir la capa de persistencia y negocio que conecte esas pantallas con
usuarios, inventario, ventas y permisos reales.

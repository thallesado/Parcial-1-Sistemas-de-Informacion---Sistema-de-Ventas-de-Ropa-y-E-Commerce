# Vesta

Prototipo académico de un e-commerce de moda y sistema de información interno.
La versión actual modela experiencia, navegación e interacciones con datos en
memoria; todavía no implementa autenticación, ventas, pagos, sincronización ni
base de datos.

La documentación técnica completa del alcance, arquitectura, funcionalidades y
pendientes se encuentra en [DOCUMENTACION.md](DOCUMENTACION.md).

La planificación de alcance, requerimientos, reglas de negocio, modelo de datos,
arquitectura y backlog se encuentra en [PLANIFICACION.md](PLANIFICACION.md).

El backend NestJS con PostgreSQL se encuentra en [backend/README.md](backend/README.md).

## Estructura

```text
Parcial1/
├── frontend/                 # Flutter Web responsive
│   ├── assets/images/
│   ├── lib/
│   │   ├── main.dart
│   │   └── src/
│   │       ├── config/
│   │       ├── controllers/
│   │       ├── middlewares/
│   │       ├── models/
│   │       ├── routes/
│   │       ├── services/
│   │       ├── utils/
│   │       └── features/       # Módulos encapsulados por dominio
│   └── web/
└── backend/                  # Estructura reservada, sin implementación
    ├── src/
    │   ├── config/
    │   ├── controllers/
    │   ├── middlewares/
    │   ├── models/
    │   ├── repositories/
    │   ├── routes/
    │   ├── services/
    │   └── utils/
    └── tests/
```

## Ejecutar el prototipo

Se requiere instalar Flutter y habilitar web. Después:

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

## Interacciones modeladas

- Navegación entre inicio, catálogo, favoritos y administración.
- Categorías, búsqueda y panel visual de filtros.
- Favoritos, vista rápida, selección de talla y bolsa.
- Acceso simulado de cliente y enlace al panel administrativo.
- Dashboard con métricas y módulos internos demostrativos.
- Punto de venta independiente con caja simulada y modo offline visual.
- Explorador conceptual interactivo de tablas, campos y relaciones.
- Adaptación de navegación, grillas y contenido a móvil/escritorio.

Las imágenes editoriales son recursos originales generados para este proyecto.

# Vesta Backend

API NestJS para el sistema omnicanal Vesta. Usa TypeORM y PostgreSQL para
centralizar catálogo, sucursales, inventario, clientes, autenticación y ventas.

```text
backend/
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

## Inicio local

1. Copiar `.env.example` a `.env`.
2. Levantar PostgreSQL: `docker compose up -d`.
3. Instalar dependencias: `npm install`.
4. Ejecutar `src/database/schema.sql` y después `src/database/seed.sql` en la
	base `vesta`.
5. Iniciar la API: `npm run start:dev`.

La API queda disponible en `http://localhost:3000/api`.

## CRUD y operaciones disponibles

- `POST /api/auth/register`, `POST /api/auth/login`
- `GET|POST|PATCH|DELETE /api/categories`
- `GET|POST|PATCH|DELETE /api/products`
- `GET|POST|PATCH|DELETE /api/branches`
- `GET|POST|PATCH|DELETE /api/customers`
- `GET|POST|PATCH /api/inventory`
- `GET /api/inventory/movements`
- `POST /api/sales`, `GET /api/sales`, `GET /api/sales/:id`

La creación de ventas se ejecuta en una transacción: valida el SKU, bloquea el
saldo de inventario, descuenta existencias y registra el movimiento. El campo
`operationId` es único y evita duplicar una venta offline al reintentar la
sincronización.

## Pendientes del siguiente corte

Pedidos web, pagos, transferencias de stock, auditoría, JWT/guards de roles y
cola de sincronización HTTP todavía deben implementarse sobre este núcleo.

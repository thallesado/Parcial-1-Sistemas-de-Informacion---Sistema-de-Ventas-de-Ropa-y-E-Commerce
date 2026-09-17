INSERT INTO roles (name, description)
VALUES
  ('ADMIN', 'Administración general del sistema'),
  ('SELLER', 'Ventas en punto de venta'),
  ('INVENTORY', 'Gestión de inventario y transferencias'),
  ('MANAGER', 'Consulta de operación y reportes')
ON CONFLICT (name) DO NOTHING;

INSERT INTO branches (code, name, city)
VALUES
  ('EQT', 'Equipetrol', 'Santa Cruz'),
  ('CEN', 'Centro', 'Santa Cruz'),
  ('CBB', 'Cochabamba', 'Cochabamba'),
  ('LPZ', 'La Paz', 'La Paz')
ON CONFLICT (code) DO NOTHING;

INSERT INTO categories (name, slug)
VALUES
  ('Mujer', 'mujer'),
  ('Abrigos', 'abrigos'),
  ('Tejidos', 'tejidos'),
  ('Pantalones', 'pantalones')
ON CONFLICT (slug) DO NOTHING;
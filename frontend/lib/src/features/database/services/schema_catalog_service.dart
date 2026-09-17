import '../models/schema_definition.dart';

class SchemaCatalogService {
  const SchemaCatalogService();

  static const id = SchemaField('id', 'UUID', key: 'PK');
  static const created = SchemaField('created_at', 'TIMESTAMPTZ');
  static const updated = SchemaField('updated_at', 'TIMESTAMPTZ');
  static SchemaField fk(String name, String target) =>
      SchemaField(name, 'UUID', key: 'FK', note: target);

  List<SchemaTable> load() => [
        _t('Identidad y acceso', 'users', 'Cuentas de clientes y personal.', [
          id,
          const SchemaField('email', 'VARCHAR', key: 'UQ'),
          const SchemaField('password_hash', 'VARCHAR'),
          const SchemaField('status', 'ENUM'),
          created,
          updated
        ], [
          'user_roles',
          'customer_profiles',
          'employees'
        ]),
        _t('Identidad y acceso', 'roles', 'Roles del sistema.', [
          id,
          const SchemaField('name', 'VARCHAR', key: 'UQ'),
          const SchemaField('scope', 'ENUM')
        ], [
          'user_roles',
          'role_permissions'
        ]),
        _t('Identidad y acceso', 'permissions',
            'Permisos atómicos por recurso y acción.', [
          id,
          const SchemaField('resource', 'VARCHAR'),
          const SchemaField('action', 'VARCHAR')
        ], [
          'role_permissions'
        ]),
        _t('Identidad y acceso', 'user_roles',
            'Asignación de roles, opcionalmente por sucursal.', [
          id,
          fk('user_id', 'users'),
          fk('role_id', 'roles'),
          fk('branch_id', 'branches')
        ], [
          'users',
          'roles',
          'branches'
        ]),
        _t(
            'Identidad y acceso',
            'role_permissions',
            'Permisos habilitados para cada rol.',
            [id, fk('role_id', 'roles'), fk('permission_id', 'permissions')],
            ['roles', 'permissions']),
        _t('Identidad y acceso', 'sessions', 'Sesiones seguras y revocables.', [
          id,
          fk('user_id', 'users'),
          const SchemaField('token_hash', 'VARCHAR'),
          const SchemaField('expires_at', 'TIMESTAMPTZ'),
          const SchemaField('revoked_at', 'TIMESTAMPTZ', nullable: true)
        ], [
          'users'
        ]),
        _t('Sucursales', 'branches', 'Sucursales físicas de la cadena.', [
          id,
          const SchemaField('code', 'VARCHAR', key: 'UQ'),
          const SchemaField('name', 'VARCHAR'),
          const SchemaField('status', 'ENUM'),
          fk('address_id', 'addresses'),
          created
        ], [
          'addresses',
          'branch_hours',
          'inventory'
        ]),
        _t('Sucursales', 'addresses',
            'Direcciones reutilizables de clientes y sucursales.', [
          id,
          const SchemaField('department', 'VARCHAR'),
          const SchemaField('city', 'VARCHAR'),
          const SchemaField('line_1', 'VARCHAR'),
          const SchemaField('latitude', 'DECIMAL', nullable: true),
          const SchemaField('longitude', 'DECIMAL', nullable: true)
        ], [
          'branches',
          'customer_addresses',
          'orders'
        ]),
        _t('Sucursales', 'branch_hours',
            'Horarios regulares y excepcionales.', [
          id,
          fk('branch_id', 'branches'),
          const SchemaField('weekday', 'SMALLINT'),
          const SchemaField('opens_at', 'TIME'),
          const SchemaField('closes_at', 'TIME')
        ], [
          'branches'
        ]),
        _t('Recursos humanos', 'employees', 'Ficha laboral del empleado.', [
          id,
          fk('user_id', 'users'),
          fk('primary_branch_id', 'branches'),
          const SchemaField('employee_code', 'VARCHAR', key: 'UQ'),
          const SchemaField('position', 'VARCHAR'),
          const SchemaField('hire_date', 'DATE'),
          const SchemaField('status', 'ENUM')
        ], [
          'users',
          'branches',
          'contracts',
          'shifts'
        ]),
        _t('Recursos humanos', 'contracts', 'Contratos y renovaciones.', [
          id,
          fk('employee_id', 'employees'),
          const SchemaField('contract_type', 'ENUM'),
          const SchemaField('starts_on', 'DATE'),
          const SchemaField('ends_on', 'DATE', nullable: true),
          const SchemaField('document_url', 'VARCHAR', nullable: true)
        ], [
          'employees',
          'salary_history'
        ]),
        _t('Recursos humanos', 'salary_history',
            'Historial salarial inmutable.', [
          id,
          fk('contract_id', 'contracts'),
          const SchemaField('amount', 'DECIMAL(12,2)'),
          const SchemaField('currency', 'CHAR(3)'),
          const SchemaField('valid_from', 'DATE'),
          const SchemaField('valid_to', 'DATE', nullable: true)
        ], [
          'contracts',
          'payroll_items'
        ]),
        _t('Recursos humanos', 'shifts', 'Turnos planificados por sucursal.', [
          id,
          fk('employee_id', 'employees'),
          fk('branch_id', 'branches'),
          const SchemaField('starts_at', 'TIMESTAMPTZ'),
          const SchemaField('ends_at', 'TIMESTAMPTZ'),
          const SchemaField('is_temporary_reinforcement', 'BOOLEAN')
        ], [
          'employees',
          'branches',
          'attendance'
        ]),
        _t('Recursos humanos', 'attendance',
            'Marcaciones y novedades de asistencia.', [
          id,
          fk('shift_id', 'shifts'),
          const SchemaField('check_in', 'TIMESTAMPTZ', nullable: true),
          const SchemaField('check_out', 'TIMESTAMPTZ', nullable: true),
          const SchemaField('source', 'ENUM')
        ], [
          'shifts'
        ]),
        _t('Recursos humanos', 'leave_requests',
            'Vacaciones, permisos y bajas.', [
          id,
          fk('employee_id', 'employees'),
          const SchemaField('type', 'ENUM'),
          const SchemaField('starts_on', 'DATE'),
          const SchemaField('ends_on', 'DATE'),
          const SchemaField('status', 'ENUM')
        ], [
          'employees'
        ]),
        _t('Recursos humanos', 'payrolls', 'Cabecera de nómina por periodo.', [
          id,
          const SchemaField('period', 'VARCHAR'),
          const SchemaField('status', 'ENUM'),
          const SchemaField('total', 'DECIMAL(14,2)')
        ], [
          'payroll_items'
        ]),
        _t('Recursos humanos', 'payroll_items',
            'Detalle de salario, bonos y descuentos.', [
          id,
          fk('payroll_id', 'payrolls'),
          fk('employee_id', 'employees'),
          const SchemaField('base_salary', 'DECIMAL(12,2)'),
          const SchemaField('bonuses', 'DECIMAL(12,2)'),
          const SchemaField('deductions', 'DECIMAL(12,2)'),
          const SchemaField('net_total', 'DECIMAL(12,2)')
        ], [
          'payrolls',
          'employees'
        ]),
        _t('Catálogo', 'categories', 'Árbol de categorías comerciales.', [
          id,
          fk('parent_id', 'categories'),
          const SchemaField('name', 'VARCHAR'),
          const SchemaField('slug', 'VARCHAR', key: 'UQ')
        ], [
          'products'
        ]),
        _t('Catálogo', 'products',
            'Producto conceptual independiente de talla y color.', [
          id,
          fk('category_id', 'categories'),
          const SchemaField('name', 'VARCHAR'),
          const SchemaField('slug', 'VARCHAR', key: 'UQ'),
          const SchemaField('description', 'TEXT'),
          const SchemaField('material', 'VARCHAR'),
          const SchemaField('fit', 'VARCHAR'),
          const SchemaField('origin', 'VARCHAR'),
          const SchemaField('status', 'ENUM'),
          created,
          updated
        ], [
          'categories',
          'product_variants',
          'product_media'
        ]),
        _t('Catálogo', 'product_variants',
            'SKU vendible: combinación de producto, color y talla.', [
          id,
          fk('product_id', 'products'),
          const SchemaField('sku', 'VARCHAR', key: 'UQ'),
          const SchemaField('color', 'VARCHAR'),
          const SchemaField('size', 'VARCHAR'),
          const SchemaField('barcode', 'VARCHAR', key: 'UQ')
        ], [
          'products',
          'inventory',
          'sale_items'
        ]),
        _t('Catálogo', 'product_media',
            'Imágenes y futuros videos del producto.', [
          id,
          fk('product_id', 'products'),
          const SchemaField('url', 'VARCHAR'),
          const SchemaField('media_type', 'ENUM'),
          const SchemaField('sort_order', 'SMALLINT'),
          const SchemaField('alt_text', 'VARCHAR')
        ], [
          'products'
        ]),
        _t('Catálogo', 'product_relations',
            'Similares, complementarios y compra el look.', [
          id,
          fk('product_id', 'products'),
          fk('related_product_id', 'products'),
          const SchemaField('relation_type', 'ENUM')
        ], [
          'products'
        ]),
        _t('Catálogo', 'size_guides', 'Medidas por categoría y talla.', [
          id,
          fk('category_id', 'categories'),
          const SchemaField('size', 'VARCHAR'),
          const SchemaField('measurements', 'JSONB')
        ], [
          'categories'
        ]),
        _t('Catálogo', 'reviews',
            'Opiniones verificadas e incentivo otorgado.', [
          id,
          fk('customer_id', 'customers'),
          fk('product_id', 'products'),
          fk('order_item_id', 'order_items'),
          const SchemaField('rating', 'SMALLINT'),
          const SchemaField('comment', 'TEXT'),
          const SchemaField('fit_feedback', 'ENUM'),
          fk('reward_coupon_id', 'coupons'),
          const SchemaField('status', 'ENUM'),
          created
        ], [
          'customers',
          'products',
          'review_media'
        ]),
        _t('Catálogo', 'review_media', 'Fotografías adjuntas a reseñas.', [
          id,
          fk('review_id', 'reviews'),
          const SchemaField('url', 'VARCHAR'),
          const SchemaField('moderation_status', 'ENUM')
        ], [
          'reviews'
        ]),
        _t('Inventario', 'inventory', 'Existencia por variante y sucursal.', [
          id,
          fk('branch_id', 'branches'),
          fk('variant_id', 'product_variants'),
          const SchemaField('physical_qty', 'INTEGER'),
          const SchemaField('reserved_qty', 'INTEGER'),
          const SchemaField('minimum_qty', 'INTEGER'),
          updated
        ], [
          'branches',
          'product_variants',
          'inventory_movements'
        ]),
        _t('Inventario', 'inventory_movements',
            'Kardex auditable de entradas y salidas.', [
          id,
          fk('inventory_id', 'inventory'),
          const SchemaField('movement_type', 'ENUM'),
          const SchemaField('quantity', 'INTEGER'),
          const SchemaField('reference_type', 'VARCHAR'),
          const SchemaField('reference_id', 'UUID'),
          fk('created_by', 'users'),
          created
        ], [
          'inventory',
          'users'
        ]),
        _t('Inventario', 'stock_transfers',
            'Transferencias entre sucursales.', [
          id,
          fk('origin_branch_id', 'branches'),
          fk('destination_branch_id', 'branches'),
          const SchemaField('status', 'ENUM'),
          fk('requested_by', 'users'),
          fk('received_by', 'users'),
          created
        ], [
          'stock_transfer_items'
        ]),
        _t('Inventario', 'stock_transfer_items',
            'Variantes y cantidades transferidas.', [
          id,
          fk('transfer_id', 'stock_transfers'),
          fk('variant_id', 'product_variants'),
          const SchemaField('quantity', 'INTEGER')
        ], [
          'stock_transfers',
          'product_variants'
        ]),
        _t('Inventario', 'suppliers', 'Proveedores de mercadería.', [
          id,
          const SchemaField('tax_id', 'VARCHAR', key: 'UQ'),
          const SchemaField('name', 'VARCHAR'),
          const SchemaField('contact_data', 'JSONB')
        ], [
          'purchase_orders'
        ]),
        _t('Inventario', 'purchase_orders',
            'Órdenes de compra a proveedores.', [
          id,
          fk('supplier_id', 'suppliers'),
          fk('destination_branch_id', 'branches'),
          const SchemaField('status', 'ENUM'),
          const SchemaField('total', 'DECIMAL(14,2)'),
          created
        ], [
          'purchase_order_items'
        ]),
        _t('Inventario', 'purchase_order_items',
            'Variantes solicitadas al proveedor.', [
          id,
          fk('purchase_order_id', 'purchase_orders'),
          fk('variant_id', 'product_variants'),
          const SchemaField('quantity', 'INTEGER'),
          const SchemaField('unit_cost', 'DECIMAL(12,2)')
        ], [
          'purchase_orders',
          'product_variants'
        ]),
        _t('Clientes y CRM', 'customers', 'Identidad comercial del cliente.', [
          id,
          fk('user_id', 'users'),
          const SchemaField('document_number', 'VARCHAR',
              key: 'UQ', nullable: true),
          const SchemaField('first_name', 'VARCHAR'),
          const SchemaField('last_name', 'VARCHAR'),
          const SchemaField('phone', 'VARCHAR', nullable: true),
          created
        ], [
          'users',
          'orders',
          'loyalty_accounts'
        ]),
        _t('Clientes y CRM', 'customer_addresses',
            'Direcciones guardadas del cliente.', [
          id,
          fk('customer_id', 'customers'),
          fk('address_id', 'addresses'),
          const SchemaField('label', 'VARCHAR'),
          const SchemaField('is_default', 'BOOLEAN')
        ], [
          'customers',
          'addresses'
        ]),
        _t('Clientes y CRM', 'favorites',
            'Productos favoritos sincronizados.', [
          id,
          fk('customer_id', 'customers'),
          fk('product_id', 'products'),
          created
        ], [
          'customers',
          'products'
        ]),
        _t('Clientes y CRM', 'recent_views',
            'Historial limitado de productos vistos.', [
          id,
          fk('customer_id', 'customers'),
          fk('product_id', 'products'),
          const SchemaField('viewed_at', 'TIMESTAMPTZ')
        ], [
          'customers',
          'products'
        ]),
        _t('Clientes y CRM', 'stock_alerts',
            'Avisos solicitados por reposición.', [
          id,
          fk('customer_id', 'customers'),
          fk('variant_id', 'product_variants'),
          const SchemaField('status', 'ENUM'),
          created
        ], [
          'customers',
          'product_variants'
        ]),
        _t('Clientes y CRM', 'price_alerts',
            'Avisos solicitados por reducción de precio.', [
          id,
          fk('customer_id', 'customers'),
          fk('product_id', 'products'),
          const SchemaField('target_price', 'DECIMAL(12,2)', nullable: true),
          const SchemaField('status', 'ENUM')
        ], [
          'customers',
          'products'
        ]),
        _t('Clientes y CRM', 'loyalty_accounts',
            'Saldo y nivel de fidelidad.', [
          id,
          fk('customer_id', 'customers'),
          const SchemaField('points_balance', 'INTEGER'),
          const SchemaField('tier', 'ENUM')
        ], [
          'customers',
          'loyalty_movements'
        ]),
        _t('Clientes y CRM', 'loyalty_movements',
            'Puntos ganados y consumidos.', [
          id,
          fk('loyalty_account_id', 'loyalty_accounts'),
          const SchemaField('points', 'INTEGER'),
          const SchemaField('reason', 'VARCHAR'),
          const SchemaField('reference_id', 'UUID'),
          created
        ], [
          'loyalty_accounts'
        ]),
        _t('Ventas y pedidos', 'carts', 'Carrito web activo o recuperable.', [
          id,
          fk('customer_id', 'customers'),
          const SchemaField('status', 'ENUM'),
          const SchemaField('expires_at', 'TIMESTAMPTZ', nullable: true),
          updated
        ], [
          'cart_items'
        ]),
        _t('Ventas y pedidos', 'cart_items',
            'Variantes y cantidades del carrito.', [
          id,
          fk('cart_id', 'carts'),
          fk('variant_id', 'product_variants'),
          const SchemaField('quantity', 'INTEGER')
        ], [
          'carts',
          'product_variants'
        ]),
        _t('Ventas y pedidos', 'orders', 'Pedido omnicanal confirmado.', [
          id,
          const SchemaField('order_number', 'VARCHAR', key: 'UQ'),
          fk('customer_id', 'customers'),
          fk('branch_id', 'branches'),
          const SchemaField('channel', 'ENUM'),
          const SchemaField('status', 'ENUM'),
          const SchemaField('subtotal', 'DECIMAL(14,2)'),
          const SchemaField('discount_total', 'DECIMAL(14,2)'),
          const SchemaField('grand_total', 'DECIMAL(14,2)'),
          const SchemaField('idempotency_key', 'UUID', key: 'UQ'),
          created
        ], [
          'order_items',
          'payments',
          'shipments'
        ]),
        _t('Ventas y pedidos', 'order_items',
            'Detalle histórico de productos, precios y descuentos.', [
          id,
          fk('order_id', 'orders'),
          fk('variant_id', 'product_variants'),
          const SchemaField('product_snapshot', 'JSONB'),
          const SchemaField('quantity', 'INTEGER'),
          const SchemaField('unit_price', 'DECIMAL(12,2)'),
          const SchemaField('discount', 'DECIMAL(12,2)')
        ], [
          'orders',
          'product_variants'
        ]),
        _t('Ventas y pedidos', 'payments',
            'Intentos de pago simulados y futuros pagos reales.', [
          id,
          fk('order_id', 'orders'),
          const SchemaField('method', 'ENUM'),
          const SchemaField('status', 'ENUM'),
          const SchemaField('amount', 'DECIMAL(14,2)'),
          const SchemaField('provider_reference', 'VARCHAR', nullable: true),
          created
        ], [
          'orders'
        ]),
        _t('Ventas y pedidos', 'shipments', 'Envíos o retiros por sucursal.', [
          id,
          fk('order_id', 'orders'),
          fk('origin_branch_id', 'branches'),
          fk('address_id', 'addresses'),
          const SchemaField('method', 'ENUM'),
          const SchemaField('status', 'ENUM'),
          const SchemaField('tracking_code', 'VARCHAR', nullable: true)
        ], [
          'orders',
          'branches'
        ]),
        _t('Ventas y pedidos', 'returns', 'Cambios y devoluciones.', [
          id,
          fk('order_id', 'orders'),
          fk('branch_id', 'branches'),
          const SchemaField('reason', 'VARCHAR'),
          const SchemaField('status', 'ENUM'),
          created
        ], [
          'return_items'
        ]),
        _t('Ventas y pedidos', 'return_items',
            'Unidades devueltas y destino del inventario.', [
          id,
          fk('return_id', 'returns'),
          fk('order_item_id', 'order_items'),
          const SchemaField('quantity', 'INTEGER'),
          const SchemaField('restock_condition', 'ENUM')
        ], [
          'returns',
          'order_items'
        ]),
        _t('Ventas y pedidos', 'cash_registers',
            'Cajas físicas por sucursal.', [
          id,
          fk('branch_id', 'branches'),
          const SchemaField('code', 'VARCHAR'),
          const SchemaField('status', 'ENUM')
        ], [
          'cash_sessions'
        ]),
        _t('Ventas y pedidos', 'cash_sessions',
            'Apertura, cierre y arqueo de caja.', [
          id,
          fk('cash_register_id', 'cash_registers'),
          fk('employee_id', 'employees'),
          const SchemaField('opening_amount', 'DECIMAL(12,2)'),
          const SchemaField('closing_amount', 'DECIMAL(12,2)', nullable: true),
          const SchemaField('opened_at', 'TIMESTAMPTZ'),
          const SchemaField('closed_at', 'TIMESTAMPTZ', nullable: true)
        ], [
          'cash_registers',
          'employees',
          'orders'
        ]),
        _t('Promociones', 'promotions',
            'Campañas programadas y reglas de descuento.', [
          id,
          const SchemaField('name', 'VARCHAR'),
          const SchemaField('discount_type', 'ENUM'),
          const SchemaField('discount_value', 'DECIMAL(12,2)'),
          const SchemaField('starts_at', 'TIMESTAMPTZ'),
          const SchemaField('ends_at', 'TIMESTAMPTZ'),
          const SchemaField('stackable', 'BOOLEAN'),
          const SchemaField('status', 'ENUM')
        ], [
          'promotion_targets'
        ]),
        _t('Promociones', 'promotion_targets',
            'Productos, categorías o sucursales alcanzadas.', [
          id,
          fk('promotion_id', 'promotions'),
          const SchemaField('target_type', 'ENUM'),
          const SchemaField('target_id', 'UUID')
        ], [
          'promotions'
        ]),
        _t('Promociones', 'coupons', 'Cupones generales o personales.', [
          id,
          const SchemaField('code', 'VARCHAR', key: 'UQ'),
          fk('promotion_id', 'promotions'),
          fk('customer_id', 'customers'),
          const SchemaField('usage_limit', 'INTEGER'),
          const SchemaField('expires_at', 'TIMESTAMPTZ')
        ], [
          'promotions',
          'customers'
        ]),
        _t('Analítica', 'web_sessions',
            'Sesiones anónimas o identificadas de navegación.', [
          id,
          fk('customer_id', 'customers'),
          const SchemaField('device_type', 'VARCHAR'),
          const SchemaField('started_at', 'TIMESTAMPTZ'),
          const SchemaField('ended_at', 'TIMESTAMPTZ', nullable: true)
        ], [
          'analytics_events'
        ]),
        _t('Analítica', 'analytics_events',
            'Visitas, búsquedas, vistas, carrito y conversión.', [
          id,
          fk('web_session_id', 'web_sessions'),
          const SchemaField('event_type', 'VARCHAR'),
          const SchemaField('properties', 'JSONB'),
          const SchemaField('occurred_at', 'TIMESTAMPTZ'),
          const SchemaField('idempotency_key', 'UUID', key: 'UQ')
        ], [
          'web_sessions'
        ]),
        _t('Analítica', 'traffic_forecasts',
            'Predicción o regla de afluencia por franja.', [
          id,
          fk('branch_id', 'branches'),
          const SchemaField('forecast_date', 'DATE'),
          const SchemaField('hour_slot', 'SMALLINT'),
          const SchemaField('expected_visits', 'INTEGER'),
          const SchemaField('recommended_staff', 'INTEGER')
        ], [
          'branches',
          'shifts'
        ]),
        _t('Sincronización y auditoría', 'sync_operations',
            'Cola idempotente de acciones offline.', [
          id,
          const SchemaField('device_id', 'UUID'),
          fk('user_id', 'users'),
          const SchemaField('operation_type', 'VARCHAR'),
          const SchemaField('payload', 'JSONB'),
          const SchemaField('status', 'ENUM'),
          const SchemaField('attempts', 'INTEGER'),
          const SchemaField('idempotency_key', 'UUID', key: 'UQ'),
          created
        ], [
          'users',
          'sync_conflicts'
        ]),
        _t('Sincronización y auditoría', 'sync_conflicts',
            'Conflictos que requieren resolución.', [
          id,
          fk('operation_id', 'sync_operations'),
          const SchemaField('server_state', 'JSONB'),
          const SchemaField('local_state', 'JSONB'),
          const SchemaField('resolution', 'ENUM', nullable: true),
          fk('resolved_by', 'users')
        ], [
          'sync_operations',
          'users'
        ]),
        _t('Sincronización y auditoría', 'devices',
            'Dispositivos autorizados de cajas y empleados.', [
          id,
          fk('branch_id', 'branches'),
          const SchemaField('name', 'VARCHAR'),
          const SchemaField('platform', 'VARCHAR'),
          const SchemaField('last_sync_at', 'TIMESTAMPTZ', nullable: true),
          const SchemaField('status', 'ENUM')
        ], [
          'branches',
          'sync_operations'
        ]),
        _t('Sincronización y auditoría', 'audit_logs',
            'Registro inmutable de acciones sensibles.', [
          id,
          fk('user_id', 'users'),
          const SchemaField('action', 'VARCHAR'),
          const SchemaField('entity_type', 'VARCHAR'),
          const SchemaField('entity_id', 'UUID'),
          const SchemaField('before_data', 'JSONB', nullable: true),
          const SchemaField('after_data', 'JSONB', nullable: true),
          created
        ], [
          'users'
        ]),
      ];

  SchemaTable _t(
          String group, String name, String purpose, List<SchemaField> fields,
          [List<String> relations = const []]) =>
      SchemaTable(
          group: group,
          name: name,
          purpose: purpose,
          fields: fields,
          relations: relations);
}

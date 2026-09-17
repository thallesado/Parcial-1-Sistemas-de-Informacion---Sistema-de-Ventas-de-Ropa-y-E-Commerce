import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../controllers/shop_controller.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: dark ? const Color(0xFF101010) : const Color(0xFFF0F1F3),
      child: Padding(
          padding: const EdgeInsets.all(26),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CENTRO DE OPERACIONES',
                style: TextStyle(letterSpacing: 1.7, fontSize: 11)),
            const SizedBox(height: 7),
            Text('Buenos días, Ana',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text('Sucursal ${shop.branch} · Perfil: Gerente de sucursal'),
            const SizedBox(height: 28),
            const Wrap(spacing: 12, runSpacing: 12, children: [
              _Metric('VENTAS HOY', 'Bs 18.420', '+12,4%', Icons.point_of_sale),
              _Metric(
                  'PEDIDOS WEB', '128', '+8,1%', Icons.shopping_bag_outlined),
              _Metric('VISITAS', '3.842', '+21,6%', Icons.language),
              _Metric(
                  'STOCK BAJO', '14', 'Revisar', Icons.inventory_2_outlined),
            ]),
            const SizedBox(height: 20),
            Wrap(spacing: 12, runSpacing: 12, children: [
              _Shortcut(
                  icon: Icons.point_of_sale,
                  title: 'Punto de venta',
                  subtitle: 'Abrir caja y registrar una venta',
                  color: AppColors.wine,
                  onTap: () => shop.goTo(DemoSection.pos)),
              _Shortcut(
                  icon: Icons.account_tree_outlined,
                  title: 'Modelo de datos',
                  subtitle: 'Explorar tablas, campos y relaciones',
                  color: AppColors.ink,
                  onTap: () => shop.goTo(DemoSection.database)),
              _Shortcut(
                  icon: Icons.people_outline,
                  title: 'Personal y turnos',
                  subtitle: 'Contratos, salarios y refuerzos',
                  onTap: () => _comingSoon(context, 'Recursos humanos')),
              _Shortcut(
                  icon: Icons.local_shipping_outlined,
                  title: 'Inventario',
                  subtitle: 'Movimientos y transferencias',
                  onTap: () => _showInventory(context, shop)),
            ]),
            const SizedBox(height: 20),
            _OperationsPanel(shop: shop),
          ])),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.trend, this.icon);
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
      width: 235,
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 19), const Spacer(), Text(trend)]),
        const SizedBox(height: 24),
        Text(value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 1.2))
      ]));
}

class _Shortcut extends StatelessWidget {
  const _Shortcut(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.color});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 330,
      child: Material(
          color: color ?? Theme.of(context).colorScheme.surface,
          child: InkWell(
              onTap: onTap,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    Icon(icon,
                        color: color == null ? null : Colors.white, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(title,
                              style: TextStyle(
                                  color: color == null ? null : Colors.white,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(subtitle,
                              style: TextStyle(
                                  color: color == null ? null : Colors.white70,
                                  fontSize: 12))
                        ])),
                    Icon(Icons.arrow_forward,
                        color: color == null ? null : Colors.white)
                  ])))));
}

class _OperationsPanel extends StatelessWidget {
  const _OperationsPanel({required this.shop});
  final ShopController shop;
  @override
  Widget build(BuildContext context) => Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('INVENTARIO CRÍTICO · VISTA DE EMPLEADO',
            style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
                columns: const [
                  DataColumn(label: Text('SKU')),
                  DataColumn(label: Text('Producto')),
                  DataColumn(label: Text('Sucursal')),
                  DataColumn(label: Text('Stock exacto')),
                  DataColumn(label: Text('Estado'))
                ],
                rows: shop.products
                    .where((product) =>
                        (product.stockByBranch[shop.branch] ?? 0) <= 5)
                    .map((product) => DataRow(cells: [
                          DataCell(Text(product.id)),
                          DataCell(Text(product.name)),
                          DataCell(Text(shop.branch)),
                          DataCell(Text(
                              '${product.stockByBranch[shop.branch] ?? 0}')),
                          const DataCell(Chip(label: Text('REPOSICIÓN')))
                        ]))
                    .toList())),
      ]));
}

void _comingSoon(BuildContext context, String module) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('$module se implementará en el bloque correspondiente.')));

void _showInventory(BuildContext context, ShopController shop) =>
    showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inventario · ${shop.branch}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  ...shop.products.take(5).map((product) => ListTile(
                      title: Text(product.name),
                      subtitle: Text(product.id),
                      trailing: Text(
                          '${product.stockByBranch[shop.branch] ?? 0} unidades')))
                ])));

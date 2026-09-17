import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../controllers/shop_controller.dart';
import '../../../models/product.dart';
import '../../catalog/widgets/product_image.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final Map<Product, int> sale = {};
  String query = '';
  bool offline = false;
  String customer = 'Consumidor final';

  double get subtotal =>
      sale.entries.fold(0, (sum, item) => sum + item.key.price * item.value);

  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final products = shop.products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.id.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final wide = MediaQuery.sizeOf(context).width >= 950;
    final catalog = _catalog(products);
    final receipt = _receipt(shop);
    return ColoredBox(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF101010)
          : const Color(0xFFF0F1F3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _statusHeader(shop),
          const SizedBox(height: 16),
          if (wide)
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Expanded(flex: 5, child: catalog),
                  const SizedBox(width: 16),
                  SizedBox(width: 390, child: receipt)
                ]))
          else
            Expanded(
                child: ListView(children: [
              SizedBox(height: 590, child: catalog),
              const SizedBox(height: 16),
              SizedBox(height: 620, child: receipt)
            ])),
        ]),
      ),
    );
  }

  Widget _statusHeader(ShopController shop) => Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 18,
            runSpacing: 10,
            children: [
              const CircleAvatar(
                  backgroundColor: AppColors.wine,
                  foregroundColor: Colors.white,
                  child: Text('AM')),
              const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ana Méndez',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('Caja 03 · Turno abierto',
                        style: TextStyle(fontSize: 11))
                  ]),
              const SizedBox(width: 12),
              DropdownButton<String>(
                  value: shop.branch,
                  underline: const SizedBox(),
                  items: ['Equipetrol', 'Centro', 'Cochabamba', 'La Paz']
                      .map((item) =>
                          DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) =>
                      value == null ? null : shop.setBranch(value)),
              const SizedBox(width: 40),
              FilterChip(
                  selected: offline,
                  onSelected: (value) => setState(() => offline = value),
                  avatar: Icon(offline ? Icons.cloud_off : Icons.cloud_done,
                      size: 18),
                  label: Text(
                      offline ? 'Offline · 2 pendientes' : 'Sincronizado')),
              TextButton.icon(
                  onPressed: () => shop.goTo(DemoSection.admin),
                  icon: const Icon(Icons.dashboard_outlined),
                  label: const Text('GESTIÓN')),
            ]),
      );

  Widget _catalog(List<Product> products) => Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PUNTO DE VENTA',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 14),
          TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.qr_code_scanner),
                  hintText: 'Escanea o busca por SKU y nombre',
                  suffixIcon: Icon(Icons.search))),
          const SizedBox(height: 16),
          Expanded(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      childAspectRatio: 1.35,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final product = products[index];
                    return InkWell(
                      onTap: () => setState(() => sale.update(
                          product, (value) => value + 1,
                          ifAbsent: () => 1)),
                      child: Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Row(children: [
                            SizedBox(
                                width: 74,
                                height: double.infinity,
                                child: ProductImage(product: product)),
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(product.id,
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                          const Spacer(),
                                          Text(product.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700)),
                                          Text(
                                              'Bs ${product.price.toStringAsFixed(0)}')
                                        ])))
                          ])),
                    );
                  })),
        ]),
      );

  Widget _receipt(ShopController shop) => Container(
        constraints: const BoxConstraints(minHeight: 540),
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(20),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const Text('VENTA ACTUAL',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
            const Spacer(),
            Text('${sale.values.fold(0, (a, b) => a + b)} prendas')
          ]),
          const SizedBox(height: 14),
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text(customer),
              trailing: TextButton(
                  onPressed: () => setState(() => customer =
                      customer == 'Consumidor final'
                          ? 'María López · Cliente Vesta'
                          : 'Consumidor final'),
                  child: const Text('CAMBIAR'))),
          const Divider(),
          Expanded(
              child: sale.isEmpty
                  ? const Center(
                      child: Text('Escanea o toca una prenda para iniciar'))
                  : ListView(
                      children: sale.entries
                          .map((entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
                                child: Row(children: [
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(entry.key.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        Text('${entry.key.id} · Talla M',
                                            style:
                                                const TextStyle(fontSize: 11))
                                      ])),
                                  IconButton(
                                      onPressed: () => setState(() {
                                            if (entry.value == 1) {
                                              sale.remove(entry.key);
                                            } else {
                                              sale[entry.key] = entry.value - 1;
                                            }
                                          }),
                                      icon: const Icon(Icons.remove, size: 16)),
                                  Text('${entry.value}'),
                                  IconButton(
                                      onPressed: () => setState(() =>
                                          sale[entry.key] = entry.value + 1),
                                      icon: const Icon(Icons.add, size: 16)),
                                  SizedBox(
                                      width: 68,
                                      child: Text(
                                          'Bs ${(entry.key.price * entry.value).toStringAsFixed(0)}',
                                          textAlign: TextAlign.right)),
                                ]),
                              ))
                          .toList())),
          const Divider(),
          _totalRow('Subtotal', subtotal),
          _totalRow('Descuento', 0),
          const SizedBox(height: 8),
          _totalRow('TOTAL', subtotal, strong: true),
          const SizedBox(height: 18),
          FilledButton.icon(
              onPressed: sale.isEmpty ? null : _finishSale,
              icon: const Icon(Icons.payments_outlined),
              label: Text(offline
                  ? 'GUARDAR VENTA EN COLA'
                  : 'COBRAR BS ${subtotal.toStringAsFixed(0)}')),
        ]),
      );

  Widget _totalRow(String label, double value, {bool strong = false}) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Text(label,
                style: TextStyle(
                    fontWeight: strong ? FontWeight.w800 : null,
                    fontSize: strong ? 18 : null)),
            const Spacer(),
            Text('Bs ${value.toStringAsFixed(0)}',
                style: TextStyle(
                    fontWeight: strong ? FontWeight.w800 : null,
                    fontSize: strong ? 18 : null))
          ]));

  void _finishSale() {
    showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              icon: Icon(offline ? Icons.cloud_off : Icons.check_circle_outline,
                  color: AppColors.wine, size: 42),
              title: Text(
                  offline ? 'Venta guardada localmente' : 'Cobro simulado'),
              content: Text(offline
                  ? 'La operación DEMO-${DateTime.now().millisecondsSinceEpoch} quedó en cola y se enviará al recuperar conexión.'
                  : 'Este prototipo no realiza cobros ni descuenta inventario.'),
              actions: [
                FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      setState(sale.clear);
                    },
                    child: const Text('NUEVA VENTA'))
              ],
            ));
  }
}

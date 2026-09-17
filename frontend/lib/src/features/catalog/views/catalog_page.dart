import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../controllers/shop_controller.dart';
import '../../../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = shop.compactGrid
        ? (width >= 1200
            ? 5
            : width >= 700
                ? 3
                : 2)
        : (width >= 1400
            ? 4
            : width >= 900
                ? 3
                : 2);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(26, 48, 26, 22),
          child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 30,
              runSpacing: 18,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('COLECCIÓN',
                      style: TextStyle(letterSpacing: 2, fontSize: 11)),
                  const SizedBox(height: 7),
                  Text(shop.category.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.w700)),
                  Text(
                      '${shop.visibleProducts.length} piezas · Sucursal ${shop.branch}'),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Badge(
                      isLabelVisible: shop.activeFilterCount > 0,
                      label: Text('${shop.activeFilterCount}'),
                      child: OutlinedButton.icon(
                          onPressed: () => showCatalogFilters(context),
                          icon: const Icon(Icons.tune),
                          label: const Text('FILTRAR'))),
                  const SizedBox(width: 8),
                  IconButton(
                      tooltip:
                          shop.compactGrid ? 'Vista amplia' : 'Vista compacta',
                      onPressed: shop.toggleGridDensity,
                      icon: Icon(
                          shop.compactGrid ? Icons.grid_view : Icons.grid_on)),
                  PopupMenuButton<CatalogSort>(
                      tooltip: 'Ordenar',
                      initialValue: shop.sort,
                      onSelected: shop.setSort,
                      icon: const Icon(Icons.swap_vert),
                      itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: CatalogSort.recommended,
                                child: Text('Recomendados')),
                            PopupMenuItem(
                                value: CatalogSort.newest,
                                child: Text('Más nuevos')),
                            PopupMenuItem(
                                value: CatalogSort.priceLow,
                                child: Text('Precio menor')),
                            PopupMenuItem(
                                value: CatalogSort.priceHigh,
                                child: Text('Precio mayor')),
                            PopupMenuItem(
                                value: CatalogSort.discount,
                                child: Text('Mayor descuento')),
                          ]),
                ]),
              ])),
      if (shop.query.isNotEmpty || shop.activeFilterCount > 0)
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Wrap(spacing: 7, runSpacing: 7, children: [
              if (shop.query.isNotEmpty)
                InputChip(
                    label: Text('Búsqueda: ${shop.query}'),
                    onDeleted: () => shop.setQuery('')),
              ...shop.sizes.map((value) => InputChip(
                  label: Text('Talla $value'),
                  onDeleted: () => shop.toggleSetValue(shop.sizes, value))),
              ...shop.colors.map((value) => InputChip(
                  label: Text(value),
                  onDeleted: () => shop.toggleSetValue(shop.colors, value))),
              ...shop.materials.map((value) => InputChip(
                  label: Text(value),
                  onDeleted: () => shop.toggleSetValue(shop.materials, value))),
              ...shop.fits.map((value) => InputChip(
                  label: Text(value),
                  onDeleted: () => shop.toggleSetValue(shop.fits, value))),
              ...shop.styles.map((value) => InputChip(
                  label: Text(value),
                  onDeleted: () => shop.toggleSetValue(shop.styles, value))),
              ...shop.occasions.map((value) => InputChip(
                  label: Text(value),
                  onDeleted: () => shop.toggleSetValue(shop.occasions, value))),
              if (shop.onlyDiscounts)
                InputChip(
                    label: const Text('Con descuento'),
                    onDeleted: () => shop.setOnlyDiscounts(false)),
              if (shop.onlyBranchStock)
                InputChip(
                    label: Text('Stock en ${shop.branch}'),
                    onDeleted: () => shop.setOnlyBranchStock(false)),
              TextButton(
                  onPressed: shop.clearFilters, child: const Text('LIMPIAR')),
            ])),
      if (shop.suggestedCorrection case final suggestion?)
        Padding(
            padding: const EdgeInsets.fromLTRB(26, 16, 26, 0),
            child: TextButton.icon(
                onPressed: () => shop.setQuery(suggestion),
                icon: const Icon(Icons.auto_fix_high),
                label: Text('¿Quisiste buscar “$suggestion”?'))),
      const SizedBox(height: 18),
      if (shop.displayedProducts.isEmpty)
        const Padding(
            padding: EdgeInsets.all(70),
            child: Center(
                child: Text('No encontramos prendas con estos criterios.')))
      else
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 8,
              mainAxisSpacing: 25,
              childAspectRatio: shop.compactGrid ? .67 : .61),
          itemCount: shop.displayedProducts.length,
          itemBuilder: (_, index) => ProductCard(
              product: shop.displayedProducts[index],
              compact: shop.compactGrid),
        ),
      if (shop.displayedProducts.length < shop.visibleProducts.length)
        Center(
            child: Padding(
                padding: const EdgeInsets.all(36),
                child: OutlinedButton.icon(
                    onPressed: shop.showMore,
                    icon: const Icon(Icons.add),
                    label: Text(
                        'MOSTRAR MÁS · ${shop.visibleProducts.length - shop.displayedProducts.length} restantes')))),
      if (shop.comparison.isNotEmpty) _CompareBar(products: shop.comparison),
      const SizedBox(height: 54),
    ]);
  }
}

class _CompareBar extends StatelessWidget {
  const _CompareBar({required this.products});
  final List<Product> products;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(16),
        color: AppColors.ink,
        child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Text('COMPARAR ${products.length}/3',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              ...products.map((product) => Chip(label: Text(product.name))),
              FilledButton(
                  onPressed: () => _showComparison(context, products),
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink),
                  child: const Text('ABRIR COMPARADOR')),
            ]),
      );
}

void _showComparison(BuildContext context, List<Product> products) {
  showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
              child: SafeArea(
                  child: Column(children: [
            Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Text('COMPARADOR',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close))
                ])),
            Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: products
                            .map((product) => SizedBox(
                                width: 300,
                                child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              height: 330,
                                              child: ProductImage(
                                                  product: product)),
                                          const SizedBox(height: 14),
                                          Text(product.name,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700)),
                                          _compareRow('Precio',
                                              'Bs ${product.price.toStringAsFixed(0)}'),
                                          _compareRow(
                                              'Material', product.material),
                                          _compareRow('Corte', product.fit),
                                          _compareRow('Estilo', product.style),
                                          _compareRow('Tallas',
                                              product.sizes.join(', ')),
                                          _compareRow('Valoración',
                                              '${product.rating} / 5'),
                                        ]))))
                            .toList()))),
          ]))));
}

Widget _compareRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Expanded(child: Text(label)),
      Expanded(
          child:
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)))
    ]));

Future<void> showCatalogFilters(BuildContext context) async {
  final shop = ShopScope.of(context);
  await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FilterPanel(shop: shop));
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.shop});
  final ShopController shop;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: shop,
      builder: (_, __) => FractionallySizedBox(
            heightFactor: .9,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        const Text('FILTRAR',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        Text('${shop.visibleProducts.length} resultados')
                      ]),
                      Expanded(
                          child: ListView(children: [
                        _choiceSection(
                            'TALLA', ['XS', 'S', 'M', 'L', 'XL'], shop.sizes),
                        _choiceSection(
                            'COLOR',
                            [
                              'Marfil',
                              'Crema',
                              'Borgoña',
                              'Carbón',
                              'Negro',
                              'Taupe',
                              'Arena'
                            ],
                            shop.colors),
                        _choiceSection(
                            'MATERIAL',
                            ['Lino', 'Punto', 'Lana', 'Viscosa', 'Algodón'],
                            shop.materials),
                        _choiceSection(
                            'CORTE',
                            [
                              'Regular',
                              'Entallado',
                              'Oversized',
                              'Relaxed',
                              'Wide leg',
                              'Recto'
                            ],
                            shop.fits),
                        _choiceSection(
                            'ESTILO',
                            ['Minimalista', 'Elegante', 'Urbano', 'Casual'],
                            shop.styles),
                        _choiceSection(
                            'OCASIÓN',
                            ['Oficina', 'Noche', 'Exterior', 'Diario'],
                            shop.occasions),
                        ExpansionTile(
                            title: Text(
                                'PRECIO · Bs ${shop.priceRange.start.round()}–${shop.priceRange.end.round()}'),
                            children: [
                              RangeSlider(
                                  values: shop.priceRange,
                                  min: 0,
                                  max: 1000,
                                  divisions: 20,
                                  labels: RangeLabels(
                                      '${shop.priceRange.start.round()}',
                                      '${shop.priceRange.end.round()}'),
                                  onChanged: shop.setPriceRange)
                            ]),
                        SwitchListTile(
                            value: shop.onlyDiscounts,
                            onChanged: shop.setOnlyDiscounts,
                            title: const Text('Solo productos con descuento')),
                        SwitchListTile(
                            value: shop.onlyBranchStock,
                            onChanged: shop.setOnlyBranchStock,
                            title: Text('Disponible en ${shop.branch}')),
                      ])),
                      FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                              'VER ${shop.visibleProducts.length} PRODUCTOS')),
                      TextButton(
                          onPressed: shop.clearFilters,
                          child: const Text('LIMPIAR TODO')),
                    ])),
          ));

  Widget _choiceSection(
          String title, List<String> values, Set<String> selected) =>
      ExpansionTile(title: Text(title), children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: values
                    .map((value) => FilterChip(
                        label: Text(value),
                        selected: selected.contains(value),
                        onSelected: (_) =>
                            shop.toggleSetValue(selected, value)))
                    .toList()))
      ]);
}

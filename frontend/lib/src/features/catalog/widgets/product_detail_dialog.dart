import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/app_theme.dart';
import '../../../controllers/shop_controller.dart';
import '../../../models/product.dart';
import 'product_image.dart';

Future<void> showProductDetail(BuildContext context, Product product) async {
  final shop = ShopScope.of(context);
  shop.viewProduct(product);
  await showDialog<void>(
      context: context, builder: (_) => ProductDetailDialog(product: product));
}

class ProductDetailDialog extends StatefulWidget {
  const ProductDetailDialog({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailDialog> createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  int galleryIndex = 0;
  String? selectedSize;
  late Color selectedColor = widget.product.color;

  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final product = widget.product;
    final mobile = MediaQuery.sizeOf(context).width < 760;
    final gallery = _gallery(product);
    final details = _details(shop, product);
    return Dialog.fullscreen(
      child: SafeArea(
          child: Column(children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Text('VESTA',
                  style: TextStyle(
                      letterSpacing: 4,
                      fontWeight: FontWeight.w800,
                      fontSize: 20)),
              const Spacer(),
              Text(product.id, style: const TextStyle(fontFamily: 'monospace')),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ])),
        const Divider(height: 1),
        Expanded(
            child: mobile
                ? ListView(
                    children: [SizedBox(height: 540, child: gallery), details])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Expanded(flex: 6, child: gallery),
                        Expanded(
                            flex: 4,
                            child: SingleChildScrollView(child: details))
                      ])),
      ])),
    );
  }

  Widget _gallery(Product product) {
    final alignments = [
      product.imageAlignment,
      Alignment(product.imageAlignment.x, -.45),
      Alignment(product.imageAlignment.x, .55)
    ];
    return ColoredBox(
      color: const Color(0xFFE9E6E1),
      child: Stack(children: [
        Positioned.fill(
            child: InteractiveViewer(
                minScale: 1,
                maxScale: 3.5,
                child: ProductImage(
                    product: product, alignment: alignments[galleryIndex]))),
        Positioned(
            left: 14,
            top: 14,
            bottom: 14,
            child: SizedBox(
                width: 64,
                child: ListView.separated(
                    itemCount: alignments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) => InkWell(
                          onTap: () => setState(() => galleryIndex = index),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: galleryIndex == index
                                          ? AppColors.wine
                                          : Colors.white,
                                      width: 2)),
                              child: ProductImage(
                                  product: product,
                                  alignment: alignments[index])),
                        )))),
        const Positioned(
            right: 16,
            bottom: 16,
            child: Chip(
                avatar: Icon(Icons.zoom_in, size: 17),
                label: Text('Pellizca o desplaza para ampliar'))),
      ]),
    );
  }

  Widget _details(ShopController shop, Product product) {
    final restock = shop.restockAlertIds.contains(product.id);
    final priceAlert = shop.priceAlertIds.contains(product.id);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
              child: Text(product.category.toUpperCase(),
                  style: const TextStyle(letterSpacing: 1.5))),
          IconButton(
              tooltip: 'Compartir enlace',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(
                    text:
                        'https://vesta.bo/productos/${product.id.toLowerCase()}'));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Enlace del producto copiado.')));
                }
              },
              icon: const Icon(Icons.share_outlined))
        ]),
        Text(product.name,
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.w700, height: 1.05)),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.star, size: 18, color: Colors.amber.shade700),
          Text(' ${product.rating} (${product.reviewCount} opiniones)'),
          const Spacer(),
          Text('Bs ${product.price.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))
        ]),
        const SizedBox(height: 24),
        Text(product.description, style: const TextStyle(height: 1.5)),
        const SizedBox(height: 24),
        const Text('COLOR', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
            spacing: 10,
            children: [
              product.color,
              const Color(0xFF111111),
              const Color(0xFFECE4D8)
            ]
                .map((color) => InkWell(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: selectedColor == color
                                    ? AppColors.wine
                                    : Colors.black26,
                                width: selectedColor == color ? 3 : 1)))))
                .toList()),
        const SizedBox(height: 22),
        Row(children: [
          const Text('TALLA', style: TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          TextButton(
              onPressed: _showSizeGuide, child: const Text('GUÍA DE MEDIDAS'))
        ]),
        Wrap(
            spacing: 8,
            children: ['XS', 'S', 'M', 'L', 'XL']
                .map((size) => ChoiceChip(
                    label: Text(size),
                    selected: selectedSize == size,
                    onSelected: product.sizes.contains(size)
                        ? (_) => setState(() => selectedSize = size)
                        : null))
                .toList()),
        if (product.hasLowStock)
          const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Últimas unidades disponibles',
                  style: TextStyle(
                      color: AppColors.wine, fontWeight: FontWeight.w700))),
        const SizedBox(height: 18),
        FilledButton(
            onPressed: selectedSize == null
                ? null
                : () {
                    shop.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            '${product.name} · talla $selectedSize añadido.')));
                  },
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('AÑADIR A LA BOLSA')),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () => shop.toggleRestockAlert(product),
            icon: Icon(restock
                ? Icons.notifications_active
                : Icons.notifications_none),
            label: Text(restock
                ? 'AVISO DE REPOSICIÓN ACTIVADO'
                : 'AVISARME SI SE AGOTA MI TALLA')),
        TextButton.icon(
            onPressed: () => shop.togglePriceAlert(product),
            icon: Icon(priceAlert ? Icons.bookmark_added : Icons.sell_outlined),
            label: Text(priceAlert
                ? 'AVISO DE PRECIO ACTIVADO'
                : 'AVISARME SI BAJA DE PRECIO')),
        const Divider(height: 34),
        ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.storefront_outlined),
            title: Text('Retiro disponible en ${shop.branch}'),
            subtitle: const Text(
                'La cantidad exacta solo es visible para empleados.'),
            trailing: const Icon(Icons.chevron_right)),
        ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('DETALLES Y AJUSTE'),
            children: [
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Corte ${product.fit}'),
                  subtitle: Text(product.modelInfo))
            ]),
        ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('COMPOSICIÓN Y CUIDADOS'),
            children: [
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(product.composition),
                  subtitle: Text(
                      '${product.origin}\nLavar según instrucciones de la etiqueta.'))
            ]),
        ExpansionTile(
            tilePadding: EdgeInsets.zero,
            initiallyExpanded: true,
            title: Text('OPINIONES (${product.reviewCount})'),
            children: [
              const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text('ML')),
                  title: Text('La caída es preciosa',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '★★★★★ · Compra verificada\nLa talla coincide y la tela se siente muy bien.')),
              Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(14),
                  child: const Row(children: [
                    Icon(Icons.add_a_photo_outlined),
                    SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            'Deja una opinión con foto después de comprar y recibe un cupón para tu próxima compra.'))
                  ])),
            ]),
        const SizedBox(height: 26),
        const Text('COMPLETA EL LOOK',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        SizedBox(
            height: 155,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final related = shop.products[
                      (shop.products.indexOf(product) + index + 1) %
                          shop.products.length];
                  return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showProductDetail(context, related);
                      },
                      child: SizedBox(
                          width: 110,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: ProductImage(product: related)),
                                const SizedBox(height: 5),
                                Text(related.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11)),
                                Text('Bs ${related.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700))
                              ])));
                })),
      ]),
    );
  }

  void _showSizeGuide() => showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text('Guía de medidas'),
            content: SingleChildScrollView(
                child: DataTable(columns: const [
              DataColumn(label: Text('Talla')),
              DataColumn(label: Text('Busto')),
              DataColumn(label: Text('Cintura')),
              DataColumn(label: Text('Cadera'))
            ], rows: const [
              DataRow(cells: [
                DataCell(Text('XS')),
                DataCell(Text('82')),
                DataCell(Text('64')),
                DataCell(Text('90'))
              ]),
              DataRow(cells: [
                DataCell(Text('S')),
                DataCell(Text('86')),
                DataCell(Text('68')),
                DataCell(Text('94'))
              ]),
              DataRow(cells: [
                DataCell(Text('M')),
                DataCell(Text('92')),
                DataCell(Text('74')),
                DataCell(Text('100'))
              ]),
              DataRow(cells: [
                DataCell(Text('L')),
                DataCell(Text('98')),
                DataCell(Text('80')),
                DataCell(Text('106'))
              ]),
            ])),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CERRAR'))
            ],
          ));
}

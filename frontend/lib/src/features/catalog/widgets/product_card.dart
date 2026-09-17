import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../controllers/shop_controller.dart';
import '../../../models/product.dart';
import 'product_detail_dialog.dart';
import 'product_image.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, this.compact = false});
  final Product product;
  final bool compact;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final product = widget.product;
    final favorite = shop.favoriteIds.contains(product.id);
    final compared = shop.comparisonIds.contains(product.id);
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Stack(fit: StackFit.expand, children: [
          AnimatedScale(
              scale: hovered ? 1.015 : 1,
              duration: const Duration(milliseconds: 180),
              child: ProductImage(product: product)),
          Positioned(
              top: 8,
              left: 8,
              child: Wrap(spacing: 4, children: [
                if (product.isNew) const ProductTag('NUEVO'),
                if (product.discount > 0) ProductTag('-${product.discount}%'),
                if (product.hasLowStock)
                  const ProductTag('ÚLTIMAS UNIDADES', color: AppColors.wine),
              ])),
          Positioned(
              right: 6,
              top: 6,
              child: Column(children: [
                IconButton.filledTonal(
                    tooltip: favorite ? 'Quitar favorito' : 'Guardar favorito',
                    onPressed: () => shop.toggleFavorite(product),
                    icon: Icon(
                        favorite ? Icons.favorite : Icons.favorite_border)),
                IconButton.filledTonal(
                    tooltip: compared ? 'Quitar comparación' : 'Comparar',
                    onPressed: () {
                      final before = shop.comparisonIds.length;
                      shop.toggleCompare(product);
                      if (!compared && before == 3 && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Puedes comparar hasta 3 productos.')));
                      }
                    },
                    icon: Icon(compared
                        ? Icons.compare_arrows
                        : Icons.compare_outlined)),
              ])),
          Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: AnimatedOpacity(
                opacity:
                    hovered || MediaQuery.sizeOf(context).width < 700 ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: FilledButton(
                    onPressed: () => showProductDetail(context, product),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.ink),
                    child: Text(widget.compact ? 'VER' : 'VISTA RÁPIDA')),
              )),
        ])),
        Padding(
            padding: const EdgeInsets.fromLTRB(7, 10, 7, 3),
            child: Text(product.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700))),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Row(children: [
              Text('Bs ${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                      color: product.oldPrice == null ? null : AppColors.wine,
                      fontWeight: FontWeight.w700)),
              if (product.oldPrice != null) ...[
                const SizedBox(width: 7),
                Text('Bs ${product.oldPrice!.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 11, decoration: TextDecoration.lineThrough))
              ],
              const Spacer(),
              Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                      color: product.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26))),
            ])),
      ]),
    );
  }
}

class ProductTag extends StatelessWidget {
  const ProductTag(this.text, {super.key, this.color = AppColors.ink});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)));
}

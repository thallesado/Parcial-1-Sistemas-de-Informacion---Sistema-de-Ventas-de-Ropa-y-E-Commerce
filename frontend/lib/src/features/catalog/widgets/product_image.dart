import 'package:flutter/material.dart';

import '../../../models/product.dart';

class ProductImage extends StatelessWidget {
  const ProductImage(
      {super.key,
      required this.product,
      this.alignment,
      this.fit = BoxFit.cover});
  final Product product;
  final Alignment? alignment;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/images/catalog_vesta.png',
        fit: fit,
        alignment: alignment ?? product.imageAlignment,
        semanticLabel: product.name,
      );
}

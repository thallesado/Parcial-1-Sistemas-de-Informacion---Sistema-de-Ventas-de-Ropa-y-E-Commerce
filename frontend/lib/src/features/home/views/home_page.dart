import 'dart:async';

import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../controllers/shop_controller.dart';
import '../../../models/product.dart';
import '../../catalog/widgets/product_card.dart';
import '../../catalog/widgets/product_image.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final newest = shop.products.where((product) => product.isNew).toList();
    final best = [...shop.products]
      ..sort((a, b) => b.popularity.compareTo(a.popularity));
    final last = shop.products.where((product) => product.hasLowStock).toList();
    return Column(children: [
      _Hero(onTap: () => shop.setCategory('Novedades')),
      const _SaleCountdown(),
      _Title('NOVEDADES', 'La nueva sofisticación',
          onTap: () => shop.setCategory('Novedades')),
      ProductRail(products: newest),
      const _Occasions(),
      _Title('LOS MÁS ELEGIDOS', 'Favoritos de la semana',
          onTap: () => shop.setCategory('Todo')),
      ProductRail(products: best.take(6).toList()),
      const _EditorialStory(),
      _Title('ÚLTIMA OPORTUNIDAD', 'Quedan pocas unidades',
          onTap: () => shop.setCategory('Últimas unidades')),
      ProductRail(products: last),
      const _ShopTheLook(),
      if (shop.recents.isNotEmpty) ...[
        const _Title('VISTOS RECIENTEMENTE', 'Continúa donde lo dejaste'),
        ProductRail(products: shop.recents)
      ],
      const _Benefits(),
    ]);
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    return SizedBox(
        height: mobile ? 570 : 680,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset('assets/images/hero_vesta.png',
              fit: BoxFit.cover,
              alignment: mobile ? const Alignment(.62, 0) : Alignment.center,
              semanticLabel: 'Campaña editorial Vesta'),
          const DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [Color(0x99000000), Colors.transparent]))),
          Positioned(
              left: mobile ? 22 : 50,
              right: mobile ? 22 : null,
              bottom: mobile ? 34 : 50,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('EDICIÓN 01 · OTOÑO',
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text('La nueva\nsofisticación',
                        style: TextStyle(
                            color: Colors.white,
                            height: .96,
                            fontSize: mobile ? 46 : 72,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2)),
                    const SizedBox(height: 22),
                    OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 17),
                            shape: const RoundedRectangleBorder()),
                        child: const Text('DESCUBRIR COLECCIÓN')),
                  ])),
        ]));
  }
}

class _SaleCountdown extends StatefulWidget {
  const _SaleCountdown();
  @override
  State<_SaleCountdown> createState() => _SaleCountdownState();
}

class _SaleCountdownState extends State<_SaleCountdown> {
  Duration remaining = const Duration(hours: 19, minutes: 5, seconds: 22);
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && remaining.inSeconds > 0) {
        setState(() => remaining -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
      color: AppColors.wine,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('OFERTA DE TEMPORADA · HASTA 25%  ',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        Text(
            '${remaining.inHours.toString().padLeft(2, '0')}:${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}',
            style:
                const TextStyle(color: Colors.white, fontFamily: 'monospace')),
      ]));
}

class _Title extends StatelessWidget {
  const _Title(this.eyebrow, this.title, {this.onTap});
  final String eyebrow;
  final String title;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(26, 64, 26, 22),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(eyebrow, style: const TextStyle(fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 7),
          Text(title,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700))
        ])),
        if (onTap != null)
          TextButton(onPressed: onTap, child: const Text('VER TODO')),
      ]));
}

class ProductRail extends StatelessWidget {
  const ProductRail({super.key, required this.products});
  final List<Product> products;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width < 700 ? width * .72 : 310.0;
    return SizedBox(
        height: 500,
        child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) => SizedBox(
                width: cardWidth,
                child: ProductCard(product: products[index]))));
  }
}

class _Occasions extends StatelessWidget {
  const _Occasions();
  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final cards = [
      ('OFICINA', 'Oficina', const Alignment(-1, 0)),
      ('NOCHE', 'Noche', const Alignment(-.34, 0)),
      ('CAPAS', 'Exterior', const Alignment(.34, 0)),
      ('DIARIO', 'Diario', const Alignment(1, 0))
    ];
    return Padding(
        padding: const EdgeInsets.only(top: 74),
        child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mobile ? 2 : 4,
                childAspectRatio: mobile ? .7 : .76),
            itemCount: cards.length,
            itemBuilder: (_, index) {
              final card = cards[index];
              return InkWell(
                  onTap: () => shop.setCategory(card.$2),
                  child: Stack(fit: StackFit.expand, children: [
                    Image.asset('assets/images/catalog_vesta.png',
                        fit: BoxFit.cover, alignment: card.$3),
                    const DecoratedBox(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [Colors.black54, Colors.transparent]))),
                    Positioned(
                        left: 18,
                        bottom: 18,
                        child: Text(card.$1,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5)))
                  ]));
            }));
  }
}

class _EditorialStory extends StatelessWidget {
  const _EditorialStory();
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final image = Image.asset('assets/images/catalog_vesta.png',
        fit: BoxFit.cover, alignment: const Alignment(.34, 0));
    const copy = Padding(
        padding: EdgeInsets.all(42),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VESTA JOURNAL · 01',
                  style: TextStyle(color: Colors.white70, letterSpacing: 2)),
              SizedBox(height: 18),
              Text('Vestir menos.\nElegir mejor.',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      height: 1,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 20),
              Text(
                  'Una historia editorial de tonos serenos, cortes amplios y prendas que permanecen.',
                  style: TextStyle(color: Colors.white, height: 1.5))
            ]));
    return Container(
        margin: const EdgeInsets.only(top: 74),
        color: AppColors.wine,
        child: mobile
            ? Column(
                children: [AspectRatio(aspectRatio: 1.2, child: image), copy])
            : SizedBox(
                height: 590,
                child: Row(children: [
                  Expanded(flex: 3, child: image),
                  const Expanded(flex: 2, child: copy)
                ])));
  }
}

class _ShopTheLook extends StatelessWidget {
  const _ShopTheLook();
  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    return Padding(
        padding: const EdgeInsets.fromLTRB(22, 76, 22, 20),
        child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 30,
                  runSpacing: 20,
                  children: [
                    SizedBox(
                        width: 340,
                        height: 380,
                        child: ProductImage(product: shop.products.first)),
                    SizedBox(
                        width: 430,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('COMPRA EL LOOK',
                                  style: TextStyle(letterSpacing: 2)),
                              const SizedBox(height: 12),
                              const Text('Sastrería tonal',
                                  style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              const Text(
                                  'Combina tres piezas de la selección y construye un uniforme contemporáneo.'),
                              const SizedBox(height: 22),
                              ...shop.products.take(3).map((product) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(product.name),
                                  trailing: Text(
                                      'Bs ${product.price.toStringAsFixed(0)}'),
                                  onTap: () => shop.addToCart(product))),
                              FilledButton(
                                  onPressed: () {
                                    for (final product
                                        in shop.products.take(3)) {
                                      shop.addToCart(product);
                                    }
                                  },
                                  child: const Text('AÑADIR LOOK COMPLETO'))
                            ]))
                  ]),
            )));
  }
}

class _Benefits extends StatelessWidget {
  const _Benefits();
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.symmetric(vertical: 64, horizontal: 20),
      child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 55,
          runSpacing: 28,
          children: [
            _Benefit(Icons.local_shipping_outlined, 'ENVÍO NACIONAL'),
            _Benefit(Icons.storefront_outlined, 'RECOJO EN TIENDA'),
            _Benefit(Icons.refresh, 'CAMBIOS SIMPLES'),
            _Benefit(Icons.lock_outline, 'COMPRA SEGURA'),
          ]));
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 190,
      child: Column(children: [
        Icon(icon, size: 28),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 11, letterSpacing: 1.3))
      ]));
}

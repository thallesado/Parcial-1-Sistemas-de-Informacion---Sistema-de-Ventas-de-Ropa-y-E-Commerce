import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../controllers/shop_controller.dart';
import '../../admin/views/admin_dashboard_page.dart';
import '../../catalog/views/catalog_page.dart';
import '../../catalog/widgets/product_card.dart';
import '../../catalog/widgets/product_image.dart';
import '../../database/views/database_explorer_page.dart';
import '../../home/views/home_page.dart';
import '../../pos/views/pos_page.dart';

class StoreShell extends StatelessWidget {
  const StoreShell({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final mobile = MediaQuery.sizeOf(context).width < 720;
    final internal = {DemoSection.admin, DemoSection.pos, DemoSection.database}
        .contains(shop.section);
    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        if (!internal) const _PromoBar(),
        _Header(internal: internal),
        Expanded(
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                    key: ValueKey(shop.section), child: _page(shop)))),
      ])),
      bottomNavigationBar: mobile ? const _MobileNav() : null,
    );
  }

  Widget _page(ShopController shop) => switch (shop.section) {
        DemoSection.home => const SingleChildScrollView(child: HomePage()),
        DemoSection.catalog =>
          const SingleChildScrollView(child: CatalogPage()),
        DemoSection.favorites =>
          const SingleChildScrollView(child: _FavoritesPage()),
        DemoSection.admin =>
          const SingleChildScrollView(child: AdminDashboardPage()),
        DemoSection.pos => const PosPage(),
        DemoSection.database =>
          const SingleChildScrollView(child: DatabaseExplorerPage()),
      };
}

class _PromoBar extends StatelessWidget {
  const _PromoBar();
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      color: AppColors.wine,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: const Text('ENVÍO GRATIS DESDE BS 350  ·  NUEVA TEMPORADA',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700)));
}

class _Header extends StatelessWidget {
  const _Header({required this.internal});
  final bool internal;

  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final mobile = MediaQuery.sizeOf(context).width < 720;
    return Container(
        height: mobile ? 64 : 76,
        color: AppColors.ink,
        padding: EdgeInsets.symmetric(horizontal: mobile ? 10 : 28),
        child: Row(children: [
          if (mobile)
            IconButton(
                onPressed: () => _showMegaMenu(context),
                icon: const Icon(Icons.menu, color: Colors.white)),
          InkWell(
              onTap: () => shop.goTo(DemoSection.home),
              child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('VESTA',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 23,
                          letterSpacing: 5)))),
          if (!mobile && !internal) ...[
            const SizedBox(width: 35),
            _HeaderLink('MUJER', () => shop.setCategory('Mujer')),
            _HeaderLink('NOVEDADES', () => shop.setCategory('Novedades')),
            _HeaderLink('OCASIONES', () => _showMegaMenu(context)),
            _HeaderLink('OFERTAS', () => shop.setCategory('Ofertas')),
          ],
          if (!mobile && internal) ...[
            const SizedBox(width: 30),
            _HeaderLink('RESUMEN', () => shop.goTo(DemoSection.admin)),
            _HeaderLink('PUNTO DE VENTA', () => shop.goTo(DemoSection.pos)),
            _HeaderLink('BASE DE DATOS', () => shop.goTo(DemoSection.database)),
          ],
          const Spacer(),
          if (!mobile)
            Theme(
                data: ThemeData.dark(),
                child: DropdownButton<String>(
                    value: shop.branch,
                    dropdownColor: AppColors.ink,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    underline: const SizedBox(),
                    iconEnabledColor: Colors.white,
                    items: ['Equipetrol', 'Centro', 'Cochabamba', 'La Paz']
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) =>
                        value == null ? null : shop.setBranch(value))),
          if (!internal)
            IconButton(
                tooltip: 'Buscar',
                onPressed: () => _showSearch(context),
                icon: const Icon(Icons.search, color: Colors.white)),
          IconButton(
              tooltip: shop.darkMode ? 'Tema claro' : 'Tema oscuro',
              onPressed: shop.toggleTheme,
              icon: Icon(
                  shop.darkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: Colors.white)),
          if (!mobile && !internal)
            IconButton(
                tooltip: 'Favoritos',
                onPressed: () => shop.goTo(DemoSection.favorites),
                icon: Badge(
                    isLabelVisible: shop.favoriteIds.isNotEmpty,
                    label: Text('${shop.favoriteIds.length}'),
                    child: const Icon(Icons.favorite_border,
                        color: Colors.white))),
          IconButton(
              tooltip: 'Cuenta',
              onPressed: () => _showAccount(context),
              icon: const Icon(Icons.person_outline, color: Colors.white)),
          if (!internal)
            IconButton(
                tooltip: 'Bolsa',
                onPressed: () => _showCart(context),
                icon: Badge(
                    isLabelVisible: shop.cart.isNotEmpty,
                    label: Text('${shop.cart.length}'),
                    child: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white))),
        ]));
  }
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink(this.text, this.onTap);
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      child:
          Text(text, style: const TextStyle(letterSpacing: 1.2, fontSize: 11)));
}

class _MobileNav extends StatelessWidget {
  const _MobileNav();
  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final section = shop.section;
    final index = section == DemoSection.home
        ? 0
        : section == DemoSection.catalog
            ? 1
            : section == DemoSection.favorites
                ? 2
                : 3;
    return NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => shop.goTo([
              DemoSection.home,
              DemoSection.catalog,
              DemoSection.favorites,
              DemoSection.admin
            ][value]),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.grid_view_outlined), label: 'Tienda'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          NavigationDestination(
              icon: Icon(Icons.badge_outlined), label: 'Empleados'),
        ]);
  }
}

class _FavoritesPage extends StatelessWidget {
  const _FavoritesPage();
  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 25),
          const Text('TU SELECCIÓN',
              style: TextStyle(letterSpacing: 2, fontSize: 11)),
          const Text('Favoritos',
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          if (shop.favorites.isEmpty)
            Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 90),
                    child: Column(children: [
                      const Icon(Icons.favorite_border, size: 45),
                      const SizedBox(height: 14),
                      const Text('Todavía no guardaste ninguna prenda.'),
                      const SizedBox(height: 18),
                      FilledButton(
                          onPressed: () => shop.setCategory('Todo'),
                          child: const Text('EXPLORAR'))
                    ])))
          else
            GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: width >= 1100 ? 4 : 2,
                    childAspectRatio: .62,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 20),
                itemCount: shop.favorites.length,
                itemBuilder: (_, index) =>
                    ProductCard(product: shop.favorites[index])),
        ]));
  }
}

void _showMegaMenu(BuildContext context) {
  final shop = ShopScope.of(context);
  final groups = <String, List<String>>{
    'PRENDAS': ['Mujer', 'Abrigos', 'Tejidos', 'Pantalones', 'Faldas'],
    'DESCUBRIR': ['Novedades', 'Más vendidos', 'Últimas unidades', 'Ofertas'],
    'POR OCASIÓN': ['Oficina', 'Noche', 'Exterior', 'Diario'],
  };
  showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text('EXPLORAR VESTA',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w800)),
                          const Spacer(),
                          IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.close))
                        ]),
                        const SizedBox(height: 22),
                        Wrap(
                            spacing: 70,
                            runSpacing: 30,
                            children: groups.entries
                                .map((entry) => SizedBox(
                                    width: 220,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(entry.key,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  letterSpacing: 1.5,
                                                  fontWeight: FontWeight.w800)),
                                          const SizedBox(height: 10),
                                          ...entry.value.map((item) => ListTile(
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(item),
                                              trailing: const Icon(
                                                  Icons.arrow_forward,
                                                  size: 15),
                                              onTap: () {
                                                Navigator.pop(dialogContext);
                                                shop.setCategory(
                                                    item == 'Más vendidos'
                                                        ? 'Todo'
                                                        : item);
                                              }))
                                        ])))
                                .toList()),
                      ])))));
}

void _showSearch(BuildContext context) {
  final shop = ShopScope.of(context);
  final input = TextEditingController();
  showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
          child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text('BUSCAR',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w800)),
                          const Spacer(),
                          IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.close))
                        ]),
                        const SizedBox(height: 34),
                        TextField(
                            controller: input,
                            autofocus: true,
                            style: const TextStyle(fontSize: 30),
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Prenda, material o SKU'),
                            onSubmitted: (value) {
                              shop.setQuery(value);
                              Navigator.pop(dialogContext);
                            }),
                        const SizedBox(height: 30),
                        const Text('BÚSQUEDAS POPULARES',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4)),
                        const SizedBox(height: 10),
                        Wrap(
                            spacing: 8,
                            children: ShopController.popularSearches
                                .map((item) => ActionChip(
                                    label: Text(item),
                                    onPressed: () {
                                      shop.setQuery(item);
                                      Navigator.pop(dialogContext);
                                    }))
                                .toList()),
                        if (shop.searchHistory.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          const Text('BÚSQUEDAS RECIENTES',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4)),
                          ...shop.searchHistory.map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.history),
                              title: Text(item),
                              trailing: IconButton(
                                  onPressed: () =>
                                      shop.removeSearchHistory(item),
                                  icon: const Icon(Icons.close)),
                              onTap: () {
                                shop.setQuery(item);
                                Navigator.pop(dialogContext);
                              })),
                        ],
                        const Spacer(),
                        OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'B06 · Búsqueda por imagen reservada. Requeriría visión computacional o un servicio de similitud visual; no está implementada.')));
                            },
                            icon: const Icon(Icons.image_search),
                            label: const Text(
                                '¿BUSCARÍAS CON UNA FOTO? VER EXPLICACIÓN')),
                      ])))));
}

void _showAccount(BuildContext context) {
  final shop = ShopScope.of(context);
  showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
          padding: EdgeInsets.fromLTRB(
              26, 4, 26, MediaQuery.viewInsetsOf(sheetContext).bottom + 30),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('ACCESO VESTA',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
                const SizedBox(height: 7),
                const Text('Elige el tipo de acceso para recorrer la maqueta.'),
                const SizedBox(height: 22),
                const TextField(
                    decoration: InputDecoration(
                        labelText: 'Correo o código de empleado')),
                const SizedBox(height: 10),
                const TextField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Contraseña')),
                const SizedBox(height: 20),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Inicio de cliente simulado.')));
                    },
                    child: const Text('INGRESAR COMO CLIENTE')),
                OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      shop.goTo(DemoSection.pos);
                    },
                    icon: const Icon(Icons.point_of_sale),
                    label:
                        const Text('INGRESAR COMO EMPLEADO · PUNTO DE VENTA')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      shop.goTo(DemoSection.admin);
                    },
                    child: const Text('ABRIR CENTRO DE OPERACIONES')),
              ])));
}

void _showCart(BuildContext context) {
  final shop = ShopScope.of(context);
  showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AnimatedBuilder(
          animation: shop,
          builder: (context, __) => FractionallySizedBox(
              heightFactor: .82,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('TU BOLSA (${shop.cart.length})',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 15),
                        Expanded(
                            child: shop.cart.isEmpty
                                ? const Center(
                                    child: Text('Tu bolsa está vacía.'))
                                : ListView.separated(
                                    itemCount: shop.cart.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(),
                                    itemBuilder: (_, index) {
                                      final product = shop.cart[index];
                                      return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: SizedBox(
                                              width: 60,
                                              child: ProductImage(
                                                  product: product)),
                                          title: Text(product.name),
                                          subtitle: Text(
                                              'Talla seleccionada · Bs ${product.price.toStringAsFixed(0)}'),
                                          trailing: IconButton(
                                              onPressed: () =>
                                                  shop.removeFromCart(product),
                                              icon: const Icon(Icons.close)));
                                    })),
                        const Divider(),
                        Row(children: [
                          const Text('TOTAL ESTIMADO'),
                          const Spacer(),
                          Text(
                              'Bs ${shop.cart.fold<double>(0, (sum, item) => sum + item.price).toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w800))
                        ]),
                        const SizedBox(height: 15),
                        FilledButton(
                            onPressed: shop.cart.isEmpty
                                ? null
                                : () => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Checkout será modelado en el bloque D.'))),
                            child: const Text('CONTINUAR COMPRA')),
                      ])))));
}

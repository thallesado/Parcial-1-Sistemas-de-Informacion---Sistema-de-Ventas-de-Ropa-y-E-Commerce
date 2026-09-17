import 'package:flutter/material.dart';

import 'src/config/app_theme.dart';
import 'src/controllers/shop_controller.dart';
import 'src/routes/app_routes.dart';
import 'src/features/shell/views/store_shell.dart';

void main() {
  runApp(const VestaApp());
}

class VestaApp extends StatefulWidget {
  const VestaApp({super.key});

  @override
  State<VestaApp> createState() => _VestaAppState();
}

class _VestaAppState extends State<VestaApp> {
  final ShopController controller = ShopController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => ShopScope(
        controller: controller,
        child: MaterialApp(
          title: 'Vesta',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: controller.darkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.home,
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const StoreShell(),
          ),
        ),
      ),
    );
  }
}

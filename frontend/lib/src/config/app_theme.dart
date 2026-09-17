import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF111111);
  static const paper = Color(0xFFF5F2EC);
  static const wine = Color(0xFF6C2535);
  static const taupe = Color(0xFFA18D7C);
  static const mist = Color(0xFFE8E3DB);
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.wine,
        primary: AppColors.ink,
        surface: AppColors.paper,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
        fontFamily: 'Arial',
      ),
      dividerColor: AppColors.ink.withValues(alpha: .14),
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.ink, width: 2),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.wine,
        brightness: Brightness.dark,
        primary: const Color(0xFFD5B8BE),
        surface: const Color(0xFF171717),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFFF4F0E9),
        displayColor: const Color(0xFFF4F0E9),
        fontFamily: 'Arial',
      ),
      dividerColor: Colors.white.withValues(alpha: .15),
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

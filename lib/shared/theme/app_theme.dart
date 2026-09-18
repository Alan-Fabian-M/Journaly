import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // Pill-like button radius, matching the very rounded card/button style
  // from design.md.
  static const double _buttonRadius = 20;

  static ButtonStyle _filledStyle() => FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
      );

  static ButtonStyle _outlinedStyle() => OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
      );

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: const TextTheme().apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      filledButtonTheme: FilledButtonThemeData(style: _filledStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedStyle()),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: const TextTheme().apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      filledButtonTheme: FilledButtonThemeData(style: _filledStyle()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedStyle()),
    );
  }
}

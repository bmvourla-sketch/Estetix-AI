import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// The "Aura Dark" theme definition.
abstract final class AppTheme {
  static ThemeData get auraDark {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: AppColors.emerald,
      onPrimary: Color(0xFF052E22),
      secondary: AppColors.purple,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: Color(0xFFF87171),
      onError: Colors.black,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    final TextTheme textTheme = GoogleFonts.interTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: const Color(0xFF052E22),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      dividerTheme: const DividerThemeData(color: AppColors.glassBorder),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}

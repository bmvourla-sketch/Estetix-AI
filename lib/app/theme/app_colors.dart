import 'package:flutter/material.dart';

/// Aura Dark palette — the single source of truth for colors.
abstract final class AppColors {
  // Surfaces
  static const Color background = Color(0xFF0E0F14);
  static const Color surface = Color(0xFF171923);
  static const Color surfaceElevated = Color(0xFF1E2029);

  // Brand accents
  static const Color emerald = Color(0xFF10B981);
  static const Color purple = Color(0xFF8B5CF6);

  // Text
  static const Color textPrimary = Color(0xFFF4F6FB);
  static const Color textSecondary = Color(0xFF9AA1B2);

  // Glassmorphism
  static const Color glassFill = Color(0x14FFFFFF); // white @ ~8%
  static const Color glassBorder = Color(0x33FFFFFF); // white @ ~20%

  static const LinearGradient brandGradient = LinearGradient(
    colors: <Color>[emerald, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

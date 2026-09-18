import 'package:flutter/material.dart';

/// Neutral palette copied literally from design.md's style: white/light-gray
/// surfaces, near-black text, light-gray tiles, solid black/white accent for
/// the active nav pill. Dark mode mirrors the same neutral language inverted
/// (design.md itself only shows a light screen).
class AppColors {
  AppColors._();

  // Seed used for ColorScheme.fromSeed in app_theme.dart — kept neutral so
  // Material defaults don't fight the literal neutral surfaces below.
  static const Color seed = Color(0xFF1A1A1A);

  // Light theme surfaces.
  static const Color lightBackground = Color(0xFFF7F7F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTile = Color(0xFFF1F1F4);
  static const Color lightAccent = Color(0xFF1A1A1A);
  static const Color lightOnAccent = Colors.white;

  // Dark theme surfaces.
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTile = Color(0xFF2A2A2A);
  static const Color darkAccent = Colors.white;
  static const Color darkOnAccent = Color(0xFF1A1A1A);

  // Text.
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF8A8A8E);
  static const Color textPrimaryDark = Color(0xFFF2F2F2);
  static const Color textSecondaryDark = Color(0xFFA0A0A5);

  // Emotion accents (semantic, not decorative — kept distinct from the
  // neutral base style since they carry meaning per EmotionType).
  static const Color sage = Color(0xFF8AA68C);
  static const Color terracotta = Color(0xFFC97B63);
  static const Color dustyBlue = Color(0xFF7C93A8);
}

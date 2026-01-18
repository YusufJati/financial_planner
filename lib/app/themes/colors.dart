import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Monochrome (Tech Grid)
  static const primary = Color(0xFF111111);
  static const primaryLight = Color(0xFF2A2A2A);
  static const primaryDark = Color(0xFF000000);
  static const primarySoft = Color(0xFFE1E0DA);

  // Accent - Neutral
  static const accent = Color(0xFF3B3B38);
  static const accentLight = Color(0xFFD9D7CF);

  // Semantic
  static const income = Color(0xFF2F3C35);
  static const expense = Color(0xFF3D2F2F);
  static const transfer = Color(0xFF2F333D);
  static const warning = Color(0xFF3D3A2F);

  // Status Colors (from Figma)
  static const good = Color(0xFF2F3C35); // Muted green tone
  static const notBad = Color(0xFF3D3A2F); // Muted amber tone

  // Light Theme
  static const background = Color(0xFFE8E7E2);
  static const surface = Color(0xFFF3F2EC);
  static const textPrimary = Color(0xFF1B1B1A);
  static const textSecondary = Color(0xFF4D4C47);
  static const textTertiary = Color(0xFF7B7A74);
  static const border = Color(0xFFC9C7C0);

  // Dark Theme
  static const backgroundDark = Color(0xFF141412);
  static const surfaceDark = Color(0xFF1D1D1A);
  static const textPrimaryDark = Color(0xFFF2F1EB);
  static const textSecondaryDark = Color(0xFFB7B6AF);
  static const borderDark = Color(0xFF2F2E2A);

  // Category Colors (Monochrome scale)
  static const List<Color> categoryColors = [
    Color(0xFF151513),
    Color(0xFF22221F),
    Color(0xFF2E2E2A),
    Color(0xFF3A3934),
    Color(0xFF45433E),
    Color(0xFF504F49),
    Color(0xFF5B5A53),
    Color(0xFF67655D),
    Color(0xFF737168),
    Color(0xFF7F7D73),
    Color(0xFF8C8A7F),
    Color(0xFF99978C),
    Color(0xFFA6A499),
    Color(0xFFB3B1A6),
    Color(0xFFC1BEB2),
    Color(0xFFD0CDC1),
  ];

  static Color fromHex(String hex) {
    final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
    return toMonochrome(color);
  }

  static Color toMonochrome(
    Color color, {
    double minLightness = 0.2,
    double maxLightness = 0.8,
  }) {
    final hsl = HSLColor.fromColor(color);
    final lightness = hsl.lightness.clamp(minLightness, maxLightness);
    return hsl.withSaturation(0).withLightness(lightness).toColor();
  }

  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}

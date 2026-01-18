import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Amount Display (Tabular figures for aligned numbers)
  static TextStyle get amountLarge => GoogleFonts.silkscreen(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: 1.2,
      );

  static TextStyle get amountMedium => GoogleFonts.silkscreen(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      );

  static TextStyle get amountSmall => GoogleFonts.spaceMono(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      );

  // Headings
  static TextStyle get h1 => GoogleFonts.silkscreen(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
      );

  static TextStyle get h2 => GoogleFonts.silkscreen(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      );

  static TextStyle get h3 => GoogleFonts.spaceMono(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      );

  static TextStyle get h4 => GoogleFonts.spaceMono(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.spaceMono(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  static TextStyle get bodyMedium => GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  // Labels
  static TextStyle get labelLarge => GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      );

  static TextStyle get labelMedium => GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      );

  static TextStyle get labelSmall => GoogleFonts.spaceMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      );

  // Get base text theme with Space Mono + Silkscreen accents
  static TextTheme get textTheme {
    final base = GoogleFonts.spaceMonoTextTheme();
    return base.copyWith(
      displayLarge: GoogleFonts.silkscreen(fontSize: 32),
      displayMedium: GoogleFonts.silkscreen(fontSize: 28),
      displaySmall: GoogleFonts.silkscreen(fontSize: 24),
      headlineLarge: GoogleFonts.silkscreen(fontSize: 24),
      headlineMedium: GoogleFonts.silkscreen(fontSize: 22),
      headlineSmall: GoogleFonts.silkscreen(fontSize: 20),
    );
  }
}

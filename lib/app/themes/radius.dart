import 'package:flutter/material.dart';

/// Border radius constants based on Figma design system
class AppRadius {
  AppRadius._();

  // Radius values (in logical pixels)
  static const double none = 0;
  static const double sm = 4;
  static const double md = 6;
  static const double base = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double xxl = 16;
  static const double xxxl = 20;
  static const double full = 999;

  // Pre-built BorderRadius objects
  static final BorderRadius radiusNone = BorderRadius.circular(none);
  static final BorderRadius radiusSm = BorderRadius.circular(sm);
  static final BorderRadius radiusMd = BorderRadius.circular(md);
  static final BorderRadius radiusBase = BorderRadius.circular(base);
  static final BorderRadius radiusLg = BorderRadius.circular(lg);
  static final BorderRadius radiusXl = BorderRadius.circular(xl);
  static final BorderRadius radiusXxl = BorderRadius.circular(xxl);
  static final BorderRadius radiusXxxl = BorderRadius.circular(xxxl);
  static final BorderRadius radiusFull = BorderRadius.circular(full);
}

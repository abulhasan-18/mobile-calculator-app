import 'package:flutter/material.dart';

class AppTheme {
  static ColorScheme scheme(Brightness b) {
    // cooler blue seed for “Calculator #04” vibe
    final seed = b == Brightness.dark
        ? const Color(0xFF2CC0FF)
        : const Color(0xFF6BA6FF);
    return ColorScheme.fromSeed(seedColor: seed, brightness: b);
  }
}

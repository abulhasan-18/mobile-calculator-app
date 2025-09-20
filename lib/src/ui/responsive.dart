// lib/src/ui/responsive.dart
import 'package:flutter/material.dart';

/// Returns a smooth scale factor based on device width.
/// 390px (iPhone 12) => 1.0
/// clamped between 0.90 and 1.20 so it never gets silly.
double fontScale(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  final scale = w / 390.0;
  return scale.clamp(0.90, 1.20);
}

/// Handy function to get a font size relative to width,
/// with clamping so it’s predictable.
double rs(BuildContext context, double base) {
  return (base * fontScale(context));
}

import 'dart:ui';

import 'package:flutter/material.dart';

class Colors {
  const Colors();

  static const Color primary = Color(0xFFF6511D);
  static const Color secondary = Color(0xFFF6511D);
  static const Color grey = Color(0xFFE5E5E5);
  static const Color background = Color(0xFFF0F1F6);
  static const Color titleColor = Color(0xFF061857);
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFFF6501C), Color(0xFFFF7E00)],
    stops: [0.0, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
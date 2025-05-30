import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSizes {
  static const double title = 24.0;
  static const double subTitle = 18.0;
  static const double body = 16.0;
  static const double caption = 14.0;
}

class FontStyles {
  static TextStyle get title => GoogleFonts.poppins(
    fontSize: FontSizes.title,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );
  static TextStyle get subTitle => GoogleFonts.poppins(
    fontSize: FontSizes.subTitle,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );
  static TextStyle get body => GoogleFonts.poppins(
    fontSize: FontSizes.body,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.8,
  );
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: FontSizes.caption,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.6,
  );
}

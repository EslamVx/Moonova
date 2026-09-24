import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get display => GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
  );

  static TextStyle get h1 => GoogleFonts.spaceGrotesk(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 38 / 30,
  );

  static TextStyle get h2 => GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
  );

  static TextStyle get h3 => GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  static TextStyle get bodyLarge => GoogleFonts.spaceGrotesk(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 26 / 17,
  );

  static TextStyle get body => GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 22 / 15,
  );

  static TextStyle get bodySmall => GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
  );

  static TextStyle get button => GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 20 / 15,
  );

  static TextStyle get label => GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
  );

  static TextStyle get caption => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 16 / 11,
  );
}

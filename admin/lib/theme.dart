import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Admin color palette — dark-first, premium look.
class AdminColors {
  AdminColors._();

  static const primary = Color(0xFF1A2332);
  static const secondary = Color(0xFF10B981);
  static const accent = Color(0xFF6366F1);

  static const profit = Color(0xFF22C55E);
  static const loss = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  static const darkBg = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkCard = Color(0xFF1E293B);
  static const darkBorder = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFE8ECF0);
  static const darkTextSecondary = Color(0xFF94A3B8);

  static const lightBg = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFF1F5F9);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightTextPrimary = Color(0xFF1A2332);
  static const lightTextSecondary = Color(0xFF64748B);
}

class AdminTheme {
  AdminTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AdminColors.primary,
    scaffoldBackgroundColor: AdminColors.lightBg,
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    colorScheme: const ColorScheme.light(
      primary: AdminColors.primary,
      secondary: AdminColors.secondary,
      surface: AdminColors.lightCard,
      error: AdminColors.loss,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AdminColors.lightCard,
      foregroundColor: AdminColors.lightTextPrimary,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AdminColors.lightTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AdminColors.lightCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AdminColors.lightCard,
      selectedIconTheme: const IconThemeData(color: AdminColors.secondary),
      selectedLabelTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        color: AdminColors.secondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AdminColors.primary,
    scaffoldBackgroundColor: AdminColors.darkBg,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark(
      primary: AdminColors.secondary,
      secondary: AdminColors.secondary,
      surface: AdminColors.darkCard,
      error: AdminColors.loss,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AdminColors.darkCard,
      foregroundColor: AdminColors.darkTextPrimary,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AdminColors.darkTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AdminColors.darkCard,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AdminColors.darkCard,
      selectedIconTheme: const IconThemeData(color: AdminColors.secondary),
      selectedLabelTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        color: AdminColors.secondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

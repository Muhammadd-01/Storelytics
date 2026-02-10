import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _baseFont => GoogleFonts.inter();

  // ── Headings ──
  static TextStyle h1({bool dark = false}) => _baseFont.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
  );

  static TextStyle h2({bool dark = false}) => _baseFont.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
  );

  static TextStyle h3({bool dark = false}) => _baseFont.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
  );

  // ── Body ──
  static TextStyle body({bool dark = false}) => _baseFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
  );

  static TextStyle bodySmall({bool dark = false}) => _baseFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
  );

  static TextStyle bodySemiBold({bool dark = false}) => _baseFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
  );

  // ── Labels ──
  static TextStyle label({bool dark = false}) => _baseFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    letterSpacing: 0.5,
  );

  // ── Numbers / Stats ──
  static TextStyle statLarge({bool dark = false}) => _baseFont.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
  );

  static TextStyle statMedium({bool dark = false}) => _baseFont.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
  );
}

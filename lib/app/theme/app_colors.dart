import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFFE50914);
  static const primaryDark = Color(0xFFB20710);

  // Dark theme
  static const darkBackground = Color(0xFF0D0D0F);
  static const darkSurface = Color(0xFF17171B);
  static const darkSurfaceElevated = Color(0xFF222228);
  static const darkBorder = Color(0xFF2C2C32);

  static const darkText = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFA6A6AE);
  static const darkTextDisabled = Color(0xFF66666E);

  // Light theme
  static const lightBackground = Color(0xFFF7F7F8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFEEEEF0);
  static const lightBorder = Color(0xFFDEDEE2);

  static const lightText = Color(0xFF111113);
  static const lightTextSecondary = Color(0xFF66666E);
}
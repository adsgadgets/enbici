import 'package:flutter/material.dart';

/// Design tokens EnBici
/// AdsGadgets brand: Orange #E84700, Black #1A1A1A
class AppColors {
  AppColors._();

  // Marca
  static const primary = Color(0xFFE84700);       // Naranja AdsGadgets
  static const primaryDark = Color(0xFFB33500);
  static const secondary = Color(0xFF1A1A1A);      // Negro AdsGadgets

  // Fondos (Dark mode por defecto — visibilidad bajo sol)
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const surfaceVariant = Color(0xFF2A2A2A);

  // Textos
  static const onPrimary = Colors.white;
  static const onBackground = Colors.white;
  static const onSurface = Colors.white;
  static const textSecondary = Color(0xFFAAAAAA);

  // SOS — siempre rojo, nunca cambiar
  static const sos = Color(0xFFFF0000);
  static const sosBackground = Color(0xFF3D0000);

  // Estado
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFCF6679);

  // Mapa
  static const companionPin = primary;
  static const cyclistPin = Color(0xFF2196F3);
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onBackground: AppColors.onBackground,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Inter',

    // AppBar sin elevación, fondo oscuro
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      centerTitle: false,
    ),

    // Botones primarios: naranja, mínimo 48px de alto (uso con guantes)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Cards: superficie ligeramente más clara que el fondo
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceVariant, width: 1),
      ),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.surfaceVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.surfaceVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}

/// Tamaños mínimos para uso con guantes de ciclismo
class AppSizes {
  AppSizes._();

  static const double tapTargetMin = 48.0;   // Mínimo botón táctil
  static const double sosButton = 80.0;       // Botón SOS (extra grande)
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;

  // Espaciados
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
}

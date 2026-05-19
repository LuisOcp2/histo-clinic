import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Tema visual Material 3 para FonoClinic.
abstract final class AppTheme {
  static ThemeData get light {
    final baseTextTheme =
        GoogleFonts.nunitoSansTextTheme(ThemeData.light().textTheme);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
      primary: AppColors.teal,
      secondary: AppColors.aprendizajeColor,
      error: AppColors.danger,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme.copyWith(
        primary: AppColors.teal,
        secondary: AppColors.aprendizajeColor,
        error: AppColors.danger,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.tealSoft,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => baseTextTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.teal
                : AppColors.textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.navy.withValues(alpha: .08),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
        labelStyle: const TextStyle(
            color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal,
          textStyle:
              baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.teal,
        textColor: AppColors.textPrimary,
        subtitleTextStyle: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

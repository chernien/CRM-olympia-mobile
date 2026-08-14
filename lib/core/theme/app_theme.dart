import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium responsive typography system for OLYMPIA.
/// NOTE: Font sizes here use RAW values. ScreenUtil's minTextAdapt
/// flag in main.dart handles scaling automatically at runtime.
/// Never use .sp inside AppTheme — it runs before ScreenUtilInit.
class AppTheme {
  AppTheme._();

  // ─── Typography Scale (raw sp-equivalent values) ─────────────────────────
  static TextTheme _buildTextTheme({required Brightness brightness}) {
    final baseColor = brightness == Brightness.light
        ? AppColors.textPrimary
        : Colors.white;
    final mutedColor = brightness == Brightness.light
        ? AppColors.textSecondary
        : const Color(0xFF94A3B8);

    return GoogleFonts.outfitTextTheme().copyWith(
      // Display
      displayLarge:  GoogleFonts.outfit(fontSize: 57, fontWeight: FontWeight.w800, color: baseColor, letterSpacing: -1.5),
      displayMedium: GoogleFonts.outfit(fontSize: 45, fontWeight: FontWeight.w700, color: baseColor, letterSpacing: -0.5),
      displaySmall:  GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w700, color: baseColor),

      // Headline
      headlineLarge:  GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: baseColor, letterSpacing: -0.5),
      headlineMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: baseColor, letterSpacing: -0.5),
      headlineSmall:  GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: baseColor),

      // Title
      titleLarge:  GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: baseColor),
      titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: baseColor),
      titleSmall:  GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: baseColor),

      // Body
      bodyLarge:  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: baseColor, height: 1.6),
      bodyMedium: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400, color: baseColor, height: 1.5),
      bodySmall:  GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400, color: mutedColor, height: 1.4),

      // Label
      labelLarge:  GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: baseColor,  letterSpacing: 0.1),
      labelMedium: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: mutedColor, letterSpacing: 0.5),
      labelSmall:  GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: mutedColor, letterSpacing: 0.5),
    );
  }

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      textTheme: _buildTextTheme(brightness: Brightness.light),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.error, width: 2)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        // Placeholder text must stay readable: textSecondary sits at ~2.3:1 on
        // the input fill and fails WCAG AA.
        hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w400),
        errorStyle: GoogleFonts.outfit(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w500),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark),
      textTheme: _buildTextTheme(brightness: Brightness.dark),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        titleTextStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
    );
  }
}
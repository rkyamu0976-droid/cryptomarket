import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0B1220);
  static const surface = Color(0xFF121C2F);
  static const surfaceHigh = Color(0xFF1A2742);
  static const border = Color(0xFF243352);
  static const text = Color(0xFFE8EEF9);
  static const muted = Color(0xFF8A98B5);
  static const accent = Color(0xFFF5B544); // gold
  static const onAccent = Color(0xFF1A1200);
  static const up = Color(0xFF34D399);
  static const down = Color(0xFFF87171);
}

class AppText {
  static TextStyle heading(double size,
          {FontWeight weight = FontWeight.w700, Color color = AppColors.text}) =>
      GoogleFonts.sora(
          fontSize: size, fontWeight: weight, color: color, letterSpacing: -0.4);

  static TextStyle number(double size,
          {FontWeight weight = FontWeight.w600, Color color = AppColors.text}) =>
      GoogleFonts.sora(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: -0.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle body(double size,
          {FontWeight weight = FontWeight.w500, Color color = AppColors.text}) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color);

  static TextStyle muted(double size, {FontWeight weight = FontWeight.w500}) =>
      body(size, weight: weight, color: AppColors.muted);
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = base.textTheme
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.down,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.heading(18),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accent.withOpacity(0.16),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
            AppText.body(12,
                weight: FontWeight.w600,
                color: states.contains(WidgetState.selected)
                    ? AppColors.accent
                    : AppColors.muted)),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.muted)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppText.muted(15),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.4)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: AppText.body(14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // 2.5D Cell-Shaded Styling
  static const Color cellBorderColor = Color(0xFFE5E5E5); // Dark slate almost black
  static const double cellBorderWidth = 1.0;
  static const BoxShadow cellShadow = BoxShadow(
    color: Color(0x0A000000),
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  );
  
  static const BoxShadow cellShadowSmall = BoxShadow(
    color: Color(0x05000000),
    offset: Offset(0, 1),
    blurRadius: 4,
    spreadRadius: 0,
  );

  // Vibrant Brand Primary Colors (Playful & Sportsy)
  static const Color primary = Color(0xFF35A629); // Electric Royal Blue
  static const Color primaryDark = Color(0xFF1E6E16);
  static const Color primaryLight = Color(0xFFD6F5D0);
  static const Color secondary = Color(0xFF10B981); // Crisp Turf Emerald Green
  static const Color secondaryLight = Color(0xFFECFDF5);
  static const Color accent = Color(0xFFF43F5E); // Playful Bubbly Rose
  static const Color accentLight = Color(0xFFFFF1F2);
  static const Color brandPurple = Color(0xFF7C3AED); // Candy Violet
  static const Color brandPurpleLight = Color(0xFFF5F3FF);

  // Light Theme Canvas & Surfaces
  static const Color bg = Colors.white; // Crisp Clean Off-White / Soft Blue-Grey
  static const Color surface = Colors.white; // Pure Crisp White
  static const Color surfaceLight = Color(0xFFF1F5F9); // Light Gray-Blue Tint
  static const Color surfaceLighter = Color(0xFFE5E5E5); // Delicate Outline
  static const Color cardBg = Colors.white; // Pure White Card
  static const Color cardBorder = Color(0xFFE5E5E5); // Subtle Border

  // Playful High-Contrast Text
  static const Color textPrimary = Color(0xFF0F172A); // Deep Slate Navy
  static const Color textSecondary = Color(0xFF475569); // Slate Gray
  static const Color textMuted = Color(0xFF94A3B8); // Soft Slate

  // Playful Multi-Sport Palette
  static const Color cricket = Color(0xFF059669); // Vibrant Cricket Turf Green
  static const Color football = Color(0xFF1E6E16); // Stadium Sky / Football Blue
  static const Color basketball = Color(0xFFEA580C); // Juicy Flare Basketball Orange
  static const Color tennis = Color(0xFF65A30D); // Energetic Volt Tennis Ball Green
  static const Color gold = Color(0xFFD97706); // Championship Amber / Gold
  static const Color magenta = Color(0xFFDB2777); // Candy Magenta Pink

  // Status & Badges
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color live = Color(0xFFE11D48); // Bubbly Live Alert Red

  // Executive Athletic Gradients (White & Cobalt Theme)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF35A629), Color(0xFF1E6E16)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient multiColorGradient = LinearGradient(
    colors: [
      Color(0xFF166534), // Dark Green
      Color(0xFF35A629), // Grass Green
      Color(0xFF6BD85F), // Light Green
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Colors.white, Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient championshipGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFFB923C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient voltGradient = LinearGradient(
    colors: [Color(0xFF84CC16), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF35A629)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cricketGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient footballGradient = LinearGradient(
    colors: [Color(0xFF1E6E16), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient basketballGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tennisGradient = LinearGradient(
    colors: [Color(0xFF84CC16), Color(0xFFEAB308)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient sportGradient(String sport) {
    return primaryGradient;
  }

  static Color sportColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return cricket;
      case 'football':
        return football;
      case 'basketball':
        return basketball;
      case 'tennis':
        return tennis;
      default:
        return primary;
    }
  }

  static Color sportLightBg(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return const Color(0xFFECFDF5);
      case 'football':
        return const Color(0xFFD6F5D0);
      case 'basketball':
        return const Color(0xFFFFF7ED);
      case 'tennis':
        return const Color(0xFFF7FEE7);
      default:
        return const Color(0xFFD6F5D0);
    }
  }

  static Color sportAccentColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return const Color(0xFF06B6D4);
      case 'football':
        return const Color(0xFF6366F1);
      case 'basketball':
        return const Color(0xFFEF4444);
      case 'tennis':
        return const Color(0xFFEAB308);
      default:
        return secondary;
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.surfaceLighter, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.surfaceLighter, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: GoogleFonts.outfit(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // Alias for compatibility
  static ThemeData get darkTheme => lightTheme;
}

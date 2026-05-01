import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // Backward-compatible aliases used across existing screens.
  static const Color primaryGreen = AppColors.primaryGreen;
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color accentGreen = AppColors.lightGreen;

  static const BorderRadius _radius12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius _radius16 = BorderRadius.all(Radius.circular(16));

  static ColorScheme get _lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryGreen,
    onPrimary: AppColors.white,
    primaryContainer: Color(0xFFC8E6C9),
    onPrimaryContainer: AppColors.darkGreen,
    secondary: AppColors.cropYellow,
    onSecondary: AppColors.darkText,
    secondaryContainer: Color(0xFFFFF3CD),
    onSecondaryContainer: Color(0xFF5D4037),
    tertiary: AppColors.weatherBlue,
    onTertiary: AppColors.white,
    tertiaryContainer: Color(0xFFB3E5FC),
    onTertiaryContainer: Color(0xFF01579B),
    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: Color(0xFFFFDAD4),
    onErrorContainer: Color(0xFF410002),
    surface: AppColors.white,
    onSurface: AppColors.darkText,
    onSurfaceVariant: Color(0xFF5E5E5E),
    outline: Color(0xFFBDBDBD),
    outlineVariant: Color(0xFFE0E0E0),
    shadow: Color(0x33000000),
    scrim: Color(0x52000000),
    inverseSurface: Color(0xFF303030),
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.lightGreen,
    surfaceContainerHighest: Color(0xFFF1F8E9),
    surfaceContainerHigh: Color(0xFFF6FBEF),
    surfaceContainer: Color(0xFFFAFAFA),
    surfaceContainerLow: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
  );

  static ColorScheme get _darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.lightGreen,
    onPrimary: Color(0xFF0F2A12),
    primaryContainer: AppColors.darkGreen,
    onPrimaryContainer: Color(0xFFC8E6C9),
    secondary: AppColors.cropYellow,
    onSecondary: Color(0xFF312200),
    secondaryContainer: Color(0xFF4E3B00),
    onSecondaryContainer: Color(0xFFFFE082),
    tertiary: AppColors.aiCyan,
    onTertiary: Color(0xFF00363D),
    tertiaryContainer: Color(0xFF004F59),
    onTertiaryContainer: Color(0xFF7DE8F7),
    error: Color(0xFFFFB4A9),
    onError: Color(0xFF680003),
    errorContainer: Color(0xFF930006),
    onErrorContainer: Color(0xFFFFDAD4),
    surface: Color(0xFF0F1A12),
    onSurface: Color(0xFFE7F2E8),
    onSurfaceVariant: Color(0xFFB7C9B8),
    outline: Color(0xFF728A74),
    outlineVariant: Color(0xFF344A36),
    shadow: Color(0x66000000),
    scrim: Color(0x99000000),
    inverseSurface: Color(0xFFE7F2E8),
    onInverseSurface: Color(0xFF162A1D),
    inversePrimary: AppColors.primaryGreen,
    surfaceContainerHighest: Color(0xFF26362A),
    surfaceContainerHigh: Color(0xFF1E2F22),
    surfaceContainer: Color(0xFF1A281E),
    surfaceContainerLow: Color(0xFF142118),
    surfaceContainerLowest: Color(0xFF0B140D),
  );

  static ThemeData get lightTheme {
    final scheme = _lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightGreyBackground,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: scheme.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        iconTheme: IconThemeData(color: scheme.primary, size: 28),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: _radius16),
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: Color(0xFF757575),
          fontWeight: FontWeight.w500,
        ),
        labelStyle: TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: _radius12,
          borderSide: BorderSide(color: Color(0xFFD0D0D0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _radius12,
          borderSide: BorderSide(color: Color(0xFFD0D0D0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _radius12,
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _radius12,
          borderSide: BorderSide(color: AppColors.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _radius12,
          borderSide: BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 56),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 56),
          foregroundColor: scheme.primary,
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      iconTheme: const IconThemeData(size: 28, color: AppColors.primaryGreen),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F8E9),
        selectedColor: scheme.primaryContainer,
        disabledColor: const Color(0xFFE0E0E0),
        labelStyle: const TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkText,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: scheme.primary,
        unselectedItemColor: const Color(0xFF7A7A7A),
        selectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = _darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLow,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.primary, size: 28),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: _radius16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
          fontWeight: FontWeight.w500,
        ),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: _radius12,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _radius12,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _radius12,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: _radius12,
          borderSide: BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 56),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 56),
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      iconTheme: IconThemeData(size: 28, color: scheme.primary),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

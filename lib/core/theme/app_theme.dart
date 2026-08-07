import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Preset accent color choices for user personalization.
class AccentColor {
  const AccentColor(this.name, this.seed);

  final String name;
  final Color seed;
}

const List<AccentColor> accentColors = [
  AccentColor('Indigo', Color(0xFF5C6BC0)),
  AccentColor('Violet', Color(0xFF7C4DFF)),
  AccentColor('Rose', Color(0xFFEC407A)),
  AccentColor('Crimson', Color(0xFFE53935)),
  AccentColor('Orange', Color(0xFFFB8C00)),
  AccentColor('Amber', Color(0xFFFFB300)),
  AccentColor('Emerald', Color(0xFF43A047)),
  AccentColor('Teal', Color(0xFF009688)),
  AccentColor('Sky', Color(0xFF29B6F6)),
];

/// App theme modes supported by settings.
enum AppThemeMode {
  system('system', 'System'),
  light('light', 'Light'),
  dark('dark', 'Dark'),
  amoled('amoled', 'AMOLED');

  const AppThemeMode(this.value, this.label);
  final String value;
  final String label;

  static AppThemeMode fromValue(String? value) {
    return AppThemeMode.values.firstWhere(
      (m) => m.value == value,
      orElse: () => AppThemeMode.system,
    );
  }
}

class AppTheme {
  AppTheme._();

  /// Builds the light Material 3 theme.
  static ThemeData light(Color seed, {bool dynamicColor = false}) {
    final scheme = dynamicColor ? null : ColorScheme.fromSeed(seedColor: seed);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.light,
    );
    return _finish(base, seed);
  }

  /// Builds the dark Material 3 theme.
  static ThemeData dark(Color seed, {bool dynamicColor = false}) {
    final scheme = dynamicColor ? null : ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
    );
    return _finish(base, seed);
  }

  /// Builds the pure-black AMOLED theme.
  static ThemeData amoled(Color seed, {bool dynamicColor = false}) {
    final scheme = dynamicColor
        ? null
        : ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.dark,
            surface: Colors.black,
          );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
    );
    final theme = _finish(base, seed);
    return theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        surface: const Color(0xFF000000),
        onSurface: const Color(0xFFE6E6E6),
        surfaceContainerLowest: const Color(0xFF000000),
        surfaceContainerLow: const Color(0xFF0A0A0A),
        surfaceContainer: const Color(0xFF141414),
        surfaceContainerHigh: const Color(0xFF1C1C1C),
        surfaceContainerHighest: const Color(0xFF242424),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      cardColor: const Color(0xFF101010),
      dialogTheme: theme.dialogTheme.copyWith(backgroundColor: const Color(0xFF141414)),
    );
  }

  static ThemeData _finish(ThemeData base, Color seed) {
    final scheme = base.colorScheme;
    final isDark = base.brightness == Brightness.dark;
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: scheme.surfaceContainerLow,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh.withValues(alpha: isDark ? 0.6 : 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
    );
  }
}

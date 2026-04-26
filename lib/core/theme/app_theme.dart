import 'package:flutter/material.dart';

/// Material 3 light and dark themes with tuned semantic colors for past/future.
abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF386A20),
      brightness: Brightness.light,
    );
    return _base(scheme).copyWith(
      colorScheme: scheme.copyWith(
        surfaceContainerLow: scheme.surfaceContainerLow,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF9BD29F),
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.compact,
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Muted accent for past events (grey with a hint of red).
  static Color pastAccent(ColorScheme scheme) {
    return Color.lerp(scheme.outline, scheme.error, 0.35)!;
  }

  /// Cool accent for upcoming events (green/blue blend from seed).
  static Color futureAccent(ColorScheme scheme) {
    return Color.lerp(scheme.primary, scheme.tertiary, 0.45)!;
  }
}

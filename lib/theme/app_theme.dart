import 'package:flutter/material.dart';

/// Material 3 theme, light and dark, built from one seed colour so both modes
/// share the same palette logic (CRS Section 10).
class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF4F46E5);
  static const double _tileRadius = 24;
  static const double _sheetRadius = 28;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
    final background = isDark
        ? const Color(0xFF0E1020)
        : const Color(0xFFF4F5FB);
    final tile = isDark ? const Color(0xFF1A1D33) : Colors.white;
    const pill = StadiumBorder();
    const buttonSize = Size(64, 56);
    final tileShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_tileRadius),
    );
    final buttonText = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(surface: background),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        surfaceTintColor: Colors.transparent,
        color: tile,
        shape: tileShape,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: pill,
          minimumSize: buttonSize,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: pill,
          minimumSize: buttonSize,
          textStyle: buttonText,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tile,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_sheetRadius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tile,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_sheetRadius),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: tileShape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        // An underline border, with no line drawn, keeps the floating label
        // inside the field; an outline border would float it across the edge.
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(_tileRadius / 2),
          borderSide: BorderSide.none,
        ),
      ),
      listTileTheme: ListTileThemeData(shape: tileShape),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Hero-tile backgrounds per tracking state. White text stays above 4.5:1 on
/// every stop, in both light and dark mode.
class AppGradients {
  AppGradients._();
  static const idle = [Color(0xFF334155), Color(0xFF1E293B)];
  static const working = [Color(0xFF4338CA), Color(0xFF7C3AED)];
  static const onBreak = [Color(0xFFC2410C), Color(0xFFBE185D)];
  static const finished = [Color(0xFF047857), Color(0xFF0F766E)];
}

/// Accent hues for the dashboard's stat tiles.
class AppAccents {
  AppAccents._();
  static const worked = Color(0xFF6366F1);
  static const breaks = Color(0xFFF97316);
  static const productive = Color(0xFF10B981);
  static const remaining = Color(0xFF8B5CF6);
  static const warning = Color(0xFFEF4444);
}

/// Shared spacing scale so every screen uses the same rhythm.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// A rounded, softly tinted square holding an icon.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }
}

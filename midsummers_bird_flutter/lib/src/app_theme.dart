import 'dart:convert';

import 'package:flutter/material.dart';

class AppThemeSpec {
  final String name;
  final Map<String, dynamic> light;
  final Map<String, dynamic> dark;
  const AppThemeSpec({required this.name, required this.light, required this.dark});

  factory AppThemeSpec.fromJson(Map<String, dynamic> json) => AppThemeSpec(
        name: json['name'] as String? ?? 'OpenAI Minimal',
        light: json['light'] as Map<String, dynamic>? ?? const {},
        dark: json['dark'] as Map<String, dynamic>? ?? const {},
      );

  static AppThemeSpec defaults() => const AppThemeSpec(name: 'OpenAI Minimal', light: {}, dark: {});

  static AppThemeSpec fromString(String source) => AppThemeSpec.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

ThemeData buildLightTheme(AppThemeSpec spec) {
  Color parse(String key, String fallback) => _hex(spec.light[key] ?? fallback);

  final colorScheme = ColorScheme.light(
    background: parse('background', '#FFFFFF'),
    surface: parse('surface', '#F5F7FB'),
    primary: parse('primary', '#2563EB'),
    secondary: parse('secondary', '#0EA5E9'),
    onBackground: parse('textPrimary', '#0F172A'),
    onSurface: parse('textPrimary', '#0F172A'),
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,
    useMaterial3: true,
    textTheme: _textTheme(Brightness.light, spec),
    dividerColor: parse('divider', '#E2E8F0'),
    chipTheme: ChipThemeData(backgroundColor: parse('chip', '#E5E7EB')),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.background,
      elevation: 0,
      foregroundColor: colorScheme.onBackground,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: parse('divider', '#E2E8F0')),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: parse('divider', '#E2E8F0'))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: parse('divider', '#E2E8F0'))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary)),
      filled: true,
      fillColor: colorScheme.surface,
    ),
    listTileTheme: const ListTileThemeData(dense: true),
  );
}

ThemeData buildDarkTheme(AppThemeSpec spec) {
  Color parse(String key, String fallback) => _hex(spec.dark[key] ?? fallback);

  final colorScheme = ColorScheme.dark(
    background: parse('background', '#0B1220'),
    surface: parse('surface', '#0F172A'),
    primary: parse('primary', '#60A5FA'),
    secondary: parse('secondary', '#38BDF8'),
    onBackground: parse('textPrimary', '#E2E8F0'),
    onSurface: parse('textPrimary', '#E2E8F0'),
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.background,
    useMaterial3: true,
    textTheme: _textTheme(Brightness.dark, spec),
    dividerColor: parse('divider', '#1F2937'),
    chipTheme: ChipThemeData(backgroundColor: parse('chip', '#111827')),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.background,
      elevation: 0,
      foregroundColor: colorScheme.onBackground,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: parse('divider', '#1F2937')),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: parse('divider', '#1F2937'))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: parse('divider', '#1F2937'))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary)),
      filled: true,
      fillColor: colorScheme.surface,
    ),
    listTileTheme: const ListTileThemeData(dense: true),
  );
}

TextTheme _textTheme(Brightness brightness, AppThemeSpec spec) {
  final primary = brightness == Brightness.light ? _hex(spec.light['textPrimary'] ?? '#0F172A') : _hex(spec.dark['textPrimary'] ?? '#E2E8F0');
  final secondary = brightness == Brightness.light ? _hex(spec.light['textSecondary'] ?? '#475569') : _hex(spec.dark['textSecondary'] ?? '#94A3B8');
  return TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.w700, color: primary),
    titleMedium: TextStyle(fontWeight: FontWeight.w600, color: primary),
    titleSmall: TextStyle(fontWeight: FontWeight.w600, color: primary),
    bodyLarge: TextStyle(color: primary),
    bodyMedium: TextStyle(color: primary),
    bodySmall: TextStyle(color: secondary),
    labelLarge: TextStyle(fontWeight: FontWeight.w600, color: primary),
  );
}

Color _hex(String s) {
  String hex = s.replaceAll('#', '').toUpperCase();
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

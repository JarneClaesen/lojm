import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
  ),
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Colors.grey[900]!,
    secondary: Colors.grey[800]!,
    tertiary: Colors.grey[700]!,
    onSurface: Colors.white,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
    ),
  ),
);
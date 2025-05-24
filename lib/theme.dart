import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primaryColor: const Color(0xFF039DAE),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: const Color(0xFFF99226),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
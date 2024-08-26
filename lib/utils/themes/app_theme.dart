import 'package:flutter/material.dart';

class AppTheme {
  // static final lighTheme = ThemeData.light(useMaterial3: true).copyWith(
  //     brightness: Brightness.light,
  //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  //     scaffoldBackgroundColor: Colors.white70);
  static final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.white,
      brightness: Brightness.dark,
      primary: Colors.blue.shade900,
      onPrimary: Colors.white,
      secondary: Colors.lightBlueAccent,
      onSecondary: Colors.black,
      surface: Colors.grey[800],
      onSurface: Colors.white,
      error: Colors.red,
      onError: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 1,
        ),
      ),
      // contentPadding: const EdgeInsets.symmetric(vertical: 55, horizontal: 20),
    ),
    scaffoldBackgroundColor: Colors.white10,
  );
}

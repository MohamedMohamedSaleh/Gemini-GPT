import 'package:flutter/material.dart';

class MyThemes {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.deepPurple,
      background: Colors.black,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Colors.deepPurple,
      background: Colors.white,
    ),
  );
}

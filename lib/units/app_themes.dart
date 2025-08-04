import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF02ABFF),
    scaffoldBackgroundColor: Color(0xFF101010),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF09090B),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF02ABFF),
      secondary: Color(0xFF02ABFF),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue[700],
    scaffoldBackgroundColor: Color(0xFFF8F8F8),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.blue),
      titleTextStyle: TextStyle(color: Colors.blue[900], fontSize: 20),
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
  );
}

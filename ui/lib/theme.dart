import 'package:flutter/material.dart';

class CustomeTheme {
  static ThemeData get theme {
    final themeData = ThemeData.light();
    final textTheme = themeData.textTheme;
    final bodyMedium =
        textTheme.bodyMedium?.copyWith(decorationColor: Colors.transparent);

    return ThemeData.light().copyWith(
      primaryColor: Colors.white,
      colorScheme: themeData.colorScheme.copyWith(
        secondary: Colors.cyan[700],
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.cyan[200],
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.cyan[700],
      ),
      textTheme: textTheme.copyWith(
        bodyMedium: bodyMedium,
      ),
    );
  }

  static ThemeData get darkTheme {
    final themeData = ThemeData.dark();
    final textTheme = themeData.textTheme;
    final bodyMedium =
        textTheme.bodyMedium?.copyWith(decorationColor: Colors.transparent);

    return ThemeData.dark().copyWith(
      primaryColor: Colors.grey[800],
      colorScheme: themeData.colorScheme.copyWith(
        secondary: Colors.cyan[300],
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.cyan[100],
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.cyan[300],
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: themeData.dialogBackgroundColor,
        contentTextStyle: bodyMedium,
        actionTextColor: Colors.cyan[300],
      ),
      textTheme: textTheme.copyWith(
        bodyMedium: bodyMedium,
      ),
    );
  }
}

import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
  ),
  colorScheme: ColorScheme.dark(
    background: Colors.black,
    primary: Colors.grey[100]!,
    primaryContainer: Colors.grey[900]!,
    secondary: Colors.grey[800]!,
    tertiary: Colors.grey[700]!,
    onSurface: Colors.white,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.grey[300], // Color of the cursor
    selectionColor: Colors.grey[300], // Background color of the selected text
    selectionHandleColor: Colors.grey[300], // Color of the selection handles
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Color.fromRGBO(1, 1, 1, 1.0),
    dialBackgroundColor: Colors.grey[900],
    dialHandColor: Colors.grey[200],
    //dialTextColor: Colors.grey[800], // all the times in the circle
    entryModeIconColor: Colors.grey[200],
    hourMinuteColor: Colors.grey[900],
    hourMinuteTextColor: Colors.grey[200], // time color
    hourMinuteTextStyle: TextStyle(
      color: Colors.grey[200], // does nothing
      fontSize: 45,
    ),
    helpTextStyle: TextStyle( // "Tijd Selecteren"
      color: Colors.grey[200],
    ),
    dayPeriodTextStyle: TextStyle(
      color: Colors.grey[200], // does nothing
    ),
    dayPeriodTextColor: Colors.grey[300], // does nothing
    dayPeriodColor: Colors.grey[700],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
);
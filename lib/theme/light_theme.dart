import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  colorScheme: ColorScheme.light(
    background: Colors.grey[300]!,
    primary: Colors.grey[900]!,
    primaryContainer: Colors.grey[200]!,
    secondary: Colors.grey[300]!,
    tertiary: Colors.grey[400]!,
    onSurface: Colors.grey[900]!,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.grey[900],
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.grey[700], // Color of the cursor
    selectionColor: Colors.grey[700], // Background color of the selected text
    selectionHandleColor: Colors.grey[700], // Color of the selection handles
  ),

  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.grey[100],
    dialBackgroundColor: Colors.grey[200],
    dialHandColor: Colors.grey[800],
    //dialTextColor: Colors.grey[800], // all the times in the circle
    entryModeIconColor: Colors.grey[800],
    hourMinuteColor: Colors.grey[200],
    hourMinuteTextColor: Colors.grey[800], // time color
    hourMinuteTextStyle: TextStyle(
      color: Colors.grey[800], // does nothing
      fontSize: 60,
    ),
    helpTextStyle: TextStyle( // "Tijd Selecteren"
      color: Colors.grey[800],
    ),
    dayPeriodTextStyle: TextStyle(
      color: Colors.grey[800], // does nothing
    ),
    dayPeriodTextColor: Colors.grey[700], // does nothing
    dayPeriodColor: Colors.grey[300],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
);
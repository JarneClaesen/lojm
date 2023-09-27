import 'package:flutter/material.dart';
import 'package:orchestra_app/theme/dark_theme.dart';
import 'package:orchestra_app/theme/light_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;
  final String key = "theme";

  ThemeProvider(Brightness systemBrightness)
      : _themeData = systemBrightness == Brightness.dark ? darkTheme : lightTheme {
    _loadTheme();
  }

  ThemeData get getTheme => _themeData;

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isDark = prefs.getBool(key);

    if (isDark != null) {
      if (isDark) {
        _themeData = darkTheme;
      } else {
        _themeData = lightTheme;
      }
      notifyListeners();
    } else {
      // If no preference is found in SharedPreferences, keep the theme as the system's brightness.
      // The _themeData is already initialized in the constructor, so no need to set it again.
      notifyListeners();
    }
  }

  void toggleTheme() async {
    if (_themeData == lightTheme) {
      _themeData = darkTheme;
    } else {
      _themeData = lightTheme;
    }
    notifyListeners();

    // Save the theme preference in shared preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, _themeData == darkTheme);
  }
}

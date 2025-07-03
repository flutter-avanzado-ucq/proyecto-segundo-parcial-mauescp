import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    _isDarkMode = await PreferencesService.getDarkMode();
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await PreferencesService.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}

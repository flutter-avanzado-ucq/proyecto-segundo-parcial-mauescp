import 'package:hive/hive.dart';

class PreferencesService {
  static const String _boxName = 'preferences_box';
  static const String _themeKey = 'isDarkMode';

  static Future<void> setDarkMode(bool isDark) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, isDark);
  }

  static Future<bool> getDarkMode() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_themeKey, defaultValue: false);
  }
}

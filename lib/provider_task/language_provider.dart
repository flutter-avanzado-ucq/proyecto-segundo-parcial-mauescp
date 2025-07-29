import 'package:flutter/material.dart';
import '../utils/translations.dart';
import 'package:hive/hive.dart';

class LanguageProvider with ChangeNotifier {
  static const String _boxName = 'preferences_box';
  static const String _languageKey = 'language';
  
  String _currentLanguage = 'es';
  String get currentLanguage => _currentLanguage;

  Future<void> toggleLanguage() async {
    _currentLanguage = _currentLanguage == 'es' ? 'en' : 'es';
    await Translations.load(_currentLanguage);
    
    // Guardar preferencia
    final box = await Hive.openBox(_boxName);
    await box.put(_languageKey, _currentLanguage);
    
    notifyListeners();
  }

  Future<void> initializeLanguage() async {
    // Cargar preferencia guardada
    final box = await Hive.openBox(_boxName);
    _currentLanguage = box.get(_languageKey, defaultValue: 'es');
    await Translations.load(_currentLanguage);
    notifyListeners();
  }

  String getTranslation(String key) {
    return Translations.translate(key, _currentLanguage);
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';

class Translations {
  static Map<String, dynamic> _localizedValues = {};
  static String _currentLanguage = 'es';

  static Future<void> load([String lang = 'es']) async {
    _currentLanguage = lang;
    String jsonContent = await rootBundle.loadString('assets/lang/$lang.json');
    _localizedValues = json.decode(jsonContent);
    print('Idioma cargado: $lang'); // Debug
    print('Valores cargados: $_localizedValues'); // Debug
  }

  static String get(String key, [Map<String, String>? params]) {
    String value = _localizedValues[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }

  static String get currentLanguage => _currentLanguage;
}

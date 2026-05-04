import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale';
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null && code.isNotEmpty && code != _locale.languageCode) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {
      // Ignore: fallback to default locale.
    }
  }

  void changeLanguage(String langCode) {
    _locale = Locale(langCode);
    notifyListeners(); // ⚠️ Sans ça, l'écran ne changera jamais de langue
    _persist(langCode);
  }

  Future<void> _persist(String langCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, langCode);
    } catch (_) {
      // Ignore persistence failures.
    }
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalizationController extends ChangeNotifier {
  LocalizationController() {
    _loadForCurrentScope();
  }

  static const String _boxName = 'app_preferences';
  static const String _guestScope = 'guest';
  static const String _legacyKey = 'locale_language_code';
  Locale _locale = const Locale('en');
  String _scope = _guestScope;
  bool _changedInCurrentSession = false;

  Locale get locale => _locale;

  bool get isUrdu => _locale.languageCode == 'ur';

  void onUserChanged(String? userId) {
    final nextScope = userId == null || userId.isEmpty ? _guestScope : userId;
    if (nextScope == _scope) return;
    final currentLanguageCode = _locale.languageCode;
    _scope = nextScope;
    final box = Hive.box(_boxName);
    final scopedKey = 'locale_$_scope';
    final hasScopedPreference = box.get(scopedKey) != null;

    // If user explicitly changed language just before auth transition
    // (e.g. on login/signup), keep that exact selection in the new scope.
    if (_changedInCurrentSession) {
      _locale =
          currentLanguageCode == 'ur' ? const Locale('ur') : const Locale('en');
      _saveForCurrentScope();
      _changedInCurrentSession = false;
      notifyListeners();
      return;
    }

    if (hasScopedPreference) {
      _loadForCurrentScope();
      return;
    }

    // First time for this user scope: keep currently selected language.
    _locale =
        currentLanguageCode == 'ur' ? const Locale('ur') : const Locale('en');
    _saveForCurrentScope();
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = isUrdu ? const Locale('en') : const Locale('ur');
    _changedInCurrentSession = true;
    _saveForCurrentScope();
    notifyListeners();
  }

  void _loadForCurrentScope() {
    final box = Hive.box(_boxName);
    final scoped = box.get('locale_$_scope') as String?;
    final fallback = box.get(_legacyKey) as String?;
    final raw = scoped ?? fallback ?? 'en';
    _locale = raw == 'ur' ? const Locale('ur') : const Locale('en');
    notifyListeners();
  }

  void _saveForCurrentScope() {
    final box = Hive.box(_boxName);
    box.put('locale_$_scope', _locale.languageCode);
    box.put(_legacyKey, _locale.languageCode);
  }
}

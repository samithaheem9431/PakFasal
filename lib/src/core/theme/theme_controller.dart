import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeController extends ChangeNotifier {
  ThemeController() {
    _loadForCurrentScope();
  }

  static const String _boxName = 'app_preferences';
  static const String _guestScope = 'guest';
  static const String _legacyKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  String _scope = _guestScope;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void onUserChanged(String? userId) {
    final nextScope = userId == null || userId.isEmpty ? _guestScope : userId;
    if (nextScope == _scope) return;
    _scope = nextScope;
    _loadForCurrentScope();
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    _saveForCurrentScope();
    notifyListeners();
  }

  void _loadForCurrentScope() {
    final box = Hive.box(_boxName);
    final scoped = box.get('theme_mode_$_scope') as String?;
    final fallback = box.get(_legacyKey) as String?;
    final raw = scoped ?? fallback;

    switch (raw) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
      default:
        _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void _saveForCurrentScope() {
    final box = Hive.box(_boxName);
    final raw = isDarkMode ? 'dark' : 'light';
    box.put('theme_mode_$_scope', raw);
    box.put(_legacyKey, raw);
  }
}

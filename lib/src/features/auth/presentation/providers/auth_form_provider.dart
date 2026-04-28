import 'package:flutter/material.dart';

class AuthFormProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }
}

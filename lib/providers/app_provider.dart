import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class AppProvider extends ChangeNotifier {
  String _selectedLanguage = 'en';
  bool _isLoading = false;
  String? _errorMessage;
  
  String get selectedLanguage => _selectedLanguage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  AppProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString(AppConstants.prefLanguage) ?? 'en';
    notifyListeners();
  }
  
  Future<void> setLanguage(String languageCode) async {
    if (AppConstants.supportedLanguages.containsKey(languageCode)) {
      _selectedLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefLanguage, languageCode);
      notifyListeners();
    }
  }
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  String getString(String key) {
    return AppStrings.get(key, _selectedLanguage);
  }
}

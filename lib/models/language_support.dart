import 'package:flutter/material.dart';

class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String? flagEmoji;
  final TextDirection textDirection;

  LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    this.flagEmoji,
    this.textDirection = TextDirection.ltr,
  });
}

class LanguageManager extends ChangeNotifier {
  // Default language code
  static const String defaultLanguageCode = 'en';
  // Map of all available languages
  static final Map<String, LanguageModel> _availableLanguages = {
    'en': LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flagEmoji: '🇬🇧',
    ),
    'hi': LanguageModel(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flagEmoji: '🇮🇳',
    ),
    'ar': LanguageModel(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flagEmoji: '🇸🇦',
      textDirection: TextDirection.rtl,
    ),
    'es': LanguageModel(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flagEmoji: '🇪🇸',
    ),
    'fr': LanguageModel(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flagEmoji: '🇫🇷',
    ),
    'de': LanguageModel(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      flagEmoji: '🇩🇪',
    ),
    'zh': LanguageModel(
      code: 'zh',
      name: 'Chinese',
      nativeName: '中文',
      flagEmoji: '🇨🇳',
    ),
  };

  // Currently enabled languages
  final List<String> _enabledLanguages = [defaultLanguageCode];
  
  // Currently selected language for editing/preview
  String _currentLanguage = defaultLanguageCode;

  // Getter for available languages
  Map<String, LanguageModel> get availableLanguages => _availableLanguages;
  
  // Getter for enabled languages
  List<String> get enabledLanguages => List.unmodifiable(_enabledLanguages);
  
  // Getter for current language
  String get currentLanguage => _currentLanguage;
  
  // Setter for current language
  set currentLanguage(String languageCode) {
    if (_enabledLanguages.contains(languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }

  // Add a language to enabled languages
  void addLanguage(String languageCode) {
    if (_availableLanguages.containsKey(languageCode) && 
        !_enabledLanguages.contains(languageCode)) {
      _enabledLanguages.add(languageCode);
      notifyListeners();
    }
  }

  // Remove a language from enabled languages
  void removeLanguage(String languageCode) {
    // Cannot remove default language
    if (languageCode != defaultLanguageCode && _enabledLanguages.contains(languageCode)) {
      _enabledLanguages.remove(languageCode);
      // If current language was removed, switch to default
      if (_currentLanguage == languageCode) {
        _currentLanguage = defaultLanguageCode;
      }
      notifyListeners();
    }
  }
  
 // Add a new language to available languages
  void addNewLanguage(LanguageModel language) {
    // Add to available languages
    _availableLanguages[language.code] = language;
    
    // Auto-enable it
    addLanguage(language.code);
    
    notifyListeners();
  }


  // Get the language model for a specific language code
  LanguageModel? getLanguageModel(String languageCode) {
    return _availableLanguages[languageCode];
  }

  // Get language name by code
  String getLanguageName(String languageCode) {
    return _availableLanguages[languageCode]?.name ?? languageCode;
  }

  // Check if a language is RTL
  bool isRtl(String languageCode) {
    return _availableLanguages[languageCode]?.textDirection == TextDirection.rtl;
  }
}
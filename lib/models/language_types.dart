// lib/models/language_types.dart

import 'package:core_image_editor/models/template_types.dart';
import 'package:flutter/material.dart';

class LocalizedText {
  Map<String, String> translations = {};
  String defaultLanguage;

  LocalizedText({
    required this.defaultLanguage,
    Map<String, String>? initialTranslations,
  }) {
    if (initialTranslations != null) {
      translations = Map.from(initialTranslations);
    }
  }

  String get(String languageCode) {
    return translations[languageCode] ?? translations[defaultLanguage] ?? '';
  }

  void set(String languageCode, String text) {
    translations[languageCode] = text;
  }

  Map<String, dynamic> toJson() {
    return {
      'translations': translations,
      'defaultLanguage': defaultLanguage,
    };
  }

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      defaultLanguage: json['defaultLanguage'] ?? 'en',
      initialTranslations: Map<String, String>.from(json['translations'] ?? {}),
    );
  }

  factory LocalizedText.fromText(String text, String defaultLanguage) {
    return LocalizedText(
      defaultLanguage: defaultLanguage,
      initialTranslations: {defaultLanguage: text},
    );
  }
}

// Extension to add localization to TemplateElement
extension LocalizedTemplateElement on TemplateElement {
  LocalizedText get localizedText {
    if (type != 'text') {
      throw Exception('Cannot get localizedText for non-text element');
    }
    
    if (content['localizedText'] == null) {
      // Create a new LocalizedText from the existing text
      final String currentText = content['text'] ?? '';
      final localizedText = LocalizedText.fromText(currentText, 'en');
      content['localizedText'] = localizedText.toJson();
      return localizedText;
    }
    
    return LocalizedText.fromJson(content['localizedText']);
  }

  void setLocalizedText(LocalizedText localizedText) {
    if (type != 'text') {
      throw Exception('Cannot set localizedText for non-text element');
    }
    
    content['localizedText'] = localizedText.toJson();
    
    // Update the visible text based on the current language
    final appState = AppLanguageState.instance;
    content['text'] = localizedText.get(appState.currentLanguage);
  }
  
  // Convenience method to update text in a specific language
  void updateTextForLanguage(String languageCode, String text) {
    final localized = localizedText;
    localized.set(languageCode, text);
    setLocalizedText(localized);
  }
}

// Singleton class to manage app-wide language state
class AppLanguageState extends ChangeNotifier {
  static final AppLanguageState _instance = AppLanguageState._internal();
  
  static AppLanguageState get instance => _instance;
  
  AppLanguageState._internal();
  
  // List of supported languages
  final List<LanguageOption> supportedLanguages = [
    LanguageOption(code: 'en', name: 'English'),
    LanguageOption(code: 'hi', name: 'Hindi'),
    LanguageOption(code: 'es', name: 'Spanish'),
    LanguageOption(code: 'fr', name: 'French'),
    LanguageOption(code: 'de', name: 'German'),
    LanguageOption(code: 'ar', name: 'Arabic'),
    LanguageOption(code: 'zh', name: 'Chinese'),
  ];
  
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;
  
  void changeLanguage(String languageCode) {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }
}

class LanguageOption {
  final String code;
  final String name;
  
  LanguageOption({required this.code, required this.name});
}
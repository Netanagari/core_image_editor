// lib/models/language_types.dart
// Extend the AppLanguageState class with add/remove language methods

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

// Singleton class to manage app-wide language state with add/remove language capabilities
class AppLanguageState extends ChangeNotifier {
  static final AppLanguageState _instance = AppLanguageState._internal();

  static AppLanguageState get instance => _instance;

  AppLanguageState._internal();

  // List of supported languages
  final List<LanguageOption> _supportedLanguages = [
    LanguageOption(code: 'en', name: 'English'),
    LanguageOption(code: 'hi', name: 'Hindi'),
  ];

  List<LanguageOption> get supportedLanguages =>
      List.unmodifiable(_supportedLanguages);

  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  void changeLanguage(String languageCode) {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }

  // Method to add a new language
  void addLanguage(String code, String name) {
    // Check if the language code already exists
    final existingIndex =
        _supportedLanguages.indexWhere((lang) => lang.code == code);

    if (existingIndex == -1) {
      _supportedLanguages.add(LanguageOption(code: code, name: name));
      notifyListeners();
    }
  }

  // Method to remove a language
  bool removeLanguage(String code) {
    // Don't allow removing the current language
    if (code == _currentLanguage) {
      return false;
    }

    // Find the language
    final index = _supportedLanguages.indexWhere((lang) => lang.code == code);

    if (index != -1) {
      _supportedLanguages.removeAt(index);
      notifyListeners();
      return true;
    }

    return false;
  }

  // Get language by code
  LanguageOption? getLanguageByCode(String code) {
    try {
      return _supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  // Check if a language code is valid
  bool isValidLanguageCode(String code) {
    return _supportedLanguages.any((lang) => lang.code == code);
  }
}

class LanguageOption {
  final String code;
  final String name;

  LanguageOption({required this.code, required this.name});
}

// New class to handle multiple language content JSONs
class MultiLanguageContent {
  // Map of language code to list of template elements
  Map<String, List<TemplateElement>> languageContents = {};

  // The current active language
  String currentLanguage;

  MultiLanguageContent({
    required this.currentLanguage,
    Map<String, List<TemplateElement>>? initialContents,
  }) {
    if (initialContents != null) {
      languageContents = Map.from(initialContents);
    }
  }

  // Get elements for the current language
  List<TemplateElement> getCurrentElements() {
    return languageContents[currentLanguage] ?? [];
  }

  // Set elements for the current language
  void setCurrentElements(List<TemplateElement> elements) {
    languageContents[currentLanguage] = elements;
  }

  // Get elements for a specific language
  List<TemplateElement> getElementsForLanguage(String languageCode) {
    return languageContents[languageCode] ?? [];
  }

  // Set elements for a specific language
  void setElementsForLanguage(
      String languageCode, List<TemplateElement> elements) {
    languageContents[languageCode] = elements;
  }

  // Copy elements from one language to another
  void copyElementsFromLanguage(String sourceLanguage, String targetLanguage) {
    final sourceElements = languageContents[sourceLanguage];
    if (sourceElements != null) {
      // Deep copy elements
      final copiedElements = sourceElements
          .map((e) => TemplateElement.fromJson(e.toJson()))
          .toList();

      languageContents[targetLanguage] = copiedElements;
    }
  }

  // When a new language is added, copy the default language content
  void addLanguage(String languageCode) {
    if (!languageContents.containsKey(languageCode)) {
      // Copy from default language (English or current)
      final sourceLang =
          languageContents.containsKey('en') ? 'en' : currentLanguage;
      copyElementsFromLanguage(sourceLang, languageCode);
    }
  }

  // Remove language content
  void removeLanguage(String languageCode) {
    languageContents.remove(languageCode);
  }

  // Convert to JSON format
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'currentLanguage': currentLanguage,
      'contents': []
    };

    languageContents.forEach((lang, elements) {
      result['contents'].add({
        'language': lang,
        'content_json': elements.map((e) => e.toJson()).toList()
      });
    });

    return result;
  }

  // Create from JSON
  factory MultiLanguageContent.fromJson(Map<String, dynamic> json) {
    final currentLang = json['currentLanguage'] ?? 'en';
    final Map<String, List<TemplateElement>> contents = {};

    final contentsList = json['contents'] as List? ?? [];
    for (final langContent in contentsList) {
      if (langContent is Map<String, dynamic>) {
        final lang = langContent['language'] as String? ?? 'en';
        final contentJson = langContent['content_json'] as List? ?? [];

        contents[lang] =
            contentJson.map((e) => TemplateElement.fromJson(e)).toList();
      }
    }

    return MultiLanguageContent(
      currentLanguage: currentLang,
      initialContents: contents,
    );
  }

  // Initialize with a single language and elements
  factory MultiLanguageContent.fromSingleLanguage(
      String languageCode, List<TemplateElement> elements) {
    return MultiLanguageContent(
      currentLanguage: languageCode,
      initialContents: {
        languageCode: elements,
      },
    );
  }
}

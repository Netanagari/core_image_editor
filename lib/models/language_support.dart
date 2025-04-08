import 'dart:convert';

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

  LanguageModel copyWith({
    String? code,
    String? name,
    String? nativeName,
    String? flagEmoji,
    TextDirection? textDirection,
  }) {
    return LanguageModel(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      textDirection: textDirection ?? this.textDirection,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'flagEmoji': flagEmoji,
      'textDirection': TextDirection.ltr.toString(),
    };
  }

  factory LanguageModel.fromMap(Map<String, dynamic> map) {
    return LanguageModel(
      code: map['code'] as String,
      name: map['name'] as String,
      nativeName: map['nativeName'] as String,
      flagEmoji: map['flagEmoji'] != null ? map['flagEmoji'] as String : null,
      textDirection: TextDirection.ltr,
    );
  }

  String toJson() => json.encode(toMap());

  factory LanguageModel.fromJson(String source) =>
      LanguageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LanguageModel(code: $code, name: $name, nativeName: $nativeName, flagEmoji: $flagEmoji, textDirection: $textDirection)';
  }

  @override
  bool operator ==(covariant LanguageModel other) {
    if (identical(this, other)) return true;

    return other.code == code &&
        other.name == name &&
        other.nativeName == nativeName &&
        other.flagEmoji == flagEmoji &&
        other.textDirection == textDirection;
  }

  @override
  int get hashCode {
    return code.hashCode ^
        name.hashCode ^
        nativeName.hashCode ^
        flagEmoji.hashCode ^
        textDirection.hashCode;
  }
}

class LanguageManager extends ChangeNotifier {
  // Default language code
  static final LanguageModel defaultLanguage = LanguageModel(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flagEmoji: '🇬🇧',
  );

  // Map of all available languages
  static final Map<String, LanguageModel> _availableLanguages = {
    'en': defaultLanguage,
    'hi': LanguageModel(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flagEmoji: '🇮🇳',
    )
  };

  // Currently enabled languages
  final List<LanguageModel> _enabledLanguages = [defaultLanguage];

  // Currently selected language for editing/preview
  String _currentLanguage = defaultLanguage.code;

  // Getter for available languages
  Map<String, LanguageModel> get availableLanguages => _availableLanguages;

  // Getter for enabled languages
  List<LanguageModel> get enabledLanguages =>
      List.unmodifiable(_enabledLanguages);

  // Getter for current language
  String get currentLanguage => _currentLanguage;

  // Setter for current language - FIXED
  set currentLanguage(String languageCode) {
    if (_enabledLanguages.any((language) => language.code == languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }

  // Add a language to enabled languages
  void addLanguage(LanguageModel language) {
    if (_availableLanguages.containsKey(language.code) &&
        !_enabledLanguages.contains(language)) {
      _enabledLanguages.add(language);
      notifyListeners();
    }
  }

  // Remove a language from enabled languages
  void removeLanguage(LanguageModel language) {
    // Cannot remove default language
    if (language != defaultLanguage && _enabledLanguages.contains(language)) {
      _enabledLanguages.remove(language);
      // If current language was removed, switch to default
      if (_currentLanguage == language.code) {
        _currentLanguage = defaultLanguage.code;
      }
      notifyListeners();
    }
  }

  // Add a new language to available languages
  void addNewLanguage(LanguageModel language) {
    // Add to available languages
    _availableLanguages[language.code] = language;

    // Auto-enable it
    addLanguage(language);

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
    return _availableLanguages[languageCode]?.textDirection ==
        TextDirection.rtl;
  }
}

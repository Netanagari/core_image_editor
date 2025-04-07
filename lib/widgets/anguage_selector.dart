// lib/widgets/language_selector.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_types.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppLanguageState.instance,
      child: Consumer<AppLanguageState>(
        builder: (context, languageState, _) {
          final currentLanguage = languageState.supportedLanguages
              .firstWhere((lang) => lang.code == languageState.currentLanguage, 
                  orElse: () => LanguageOption(code: 'en', name: 'English'));
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 20),
                const SizedBox(width: 8),
                Text('Preview language:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: languageState.currentLanguage,
                  underline: Container(), // Remove the default underline
                  items: languageState.supportedLanguages.map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang.code,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(lang.name),
                      ),
                    );
                  }).toList(),
                  onChanged: (code) {
                    if (code != null) {
                      languageState.changeLanguage(code);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Smaller version for mobile view
class CompactLanguageSelector extends StatelessWidget {
  const CompactLanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppLanguageState.instance,
      child: Consumer<AppLanguageState>(
        builder: (context, languageState, _) {
          final currentLanguage = languageState.supportedLanguages
              .firstWhere((lang) => lang.code == languageState.currentLanguage, 
                  orElse: () => LanguageOption(code: 'en', name: 'English'));
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: languageState.currentLanguage,
              underline: Container(), // Remove the default underline
              icon: const Icon(Icons.language, size: 18),
              items: languageState.supportedLanguages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang.code,
                  child: Text(lang.name),
                );
              }).toList(),
              onChanged: (code) {
                if (code != null) {
                  languageState.changeLanguage(code);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
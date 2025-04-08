import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/language_support.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final languageManager = Provider.of<LanguageManager>(context);
    final currentLanguage = languageManager.currentLanguage;
    final enabledLanguages = languageManager.enabledLanguages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Current Language'),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: currentLanguage,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: enabledLanguages.map((language) {
            final lang = languageManager.getLanguageModel(language.code);
            return DropdownMenuItem(
              value: language.code,
              child: Row(
                children: [
                  if (lang?.flagEmoji != null) ...[
                    Text(
                      lang!.flagEmoji!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(lang?.name ?? "English"),
                  const SizedBox(width: 4),
                  Text(
                    '(${lang?.nativeName})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              languageManager.currentLanguage = value;
            }
          },
        ),
      ],
    );
  }
}

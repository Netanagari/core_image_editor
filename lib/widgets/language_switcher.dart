import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_support.dart';
import '../widgets/property_controls/language_manager_dialog.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (context, languageManager, child) {
        final currentLanguage = languageManager.currentLanguage;
        final currentLanguageModel =
            languageManager.getLanguageModel(currentLanguage);

        return Row(
          children: [
            // Current language display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  if (currentLanguageModel?.flagEmoji != null) ...[
                    Text(currentLanguageModel!.flagEmoji!),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    currentLanguageModel?.nativeName ??
                        currentLanguageModel?.name ??
                        currentLanguage,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Quick language selector for enabled languages
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: languageManager.enabledLanguages
                      .any((lang) => lang.code == currentLanguage)
                  ? currentLanguage
                  : (languageManager.enabledLanguages.isNotEmpty
                      ? languageManager.enabledLanguages.first.code
                      : null),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              items: languageManager.enabledLanguages.map((language) {
                final lang = languageManager.getLanguageModel(language.code);
                return DropdownMenuItem(
                  value: language
                      .code, // Always use the exact code from enabledLanguages
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (lang?.flagEmoji != null) ...[
                        Text(lang!.flagEmoji!),
                        const SizedBox(width: 4),
                      ],
                      Text(lang?.name ?? "English"),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null &&
                    languageManager.enabledLanguages
                        .any((lang) => lang.code == value)) {
                  languageManager.currentLanguage = value;
                }
              },
            ),

            // Button to open language manager
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Manage Languages',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => ChangeNotifierProvider.value(
                    value: languageManager,
                    child: const LanguageManagerDialog(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

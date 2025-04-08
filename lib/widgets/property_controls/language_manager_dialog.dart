// lib/widgets/language_manager_dialog.dart
// Simple language manager dialog

import 'package:core_image_editor/models/language_support.dart';
import 'package:core_image_editor/widgets/add_language_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageManagerDialog extends StatelessWidget {
  const LanguageManagerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(
      builder: (context, languageManager, _) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Manage Languages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),

                // Enabled Languages Section
                const Text(
                  'Enabled Languages',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: languageManager.enabledLanguages.map((langCode) {
                    final lang = languageManager.getLanguageModel(langCode);
                    final isDefault =
                        langCode == LanguageManager.defaultLanguageCode;

                    return Chip(
                      avatar: lang?.flagEmoji != null
                          ? Text(lang!.flagEmoji!)
                          : null,
                      label: Text(lang?.name ?? langCode),
                      deleteIcon:
                          isDefault ? null : const Icon(Icons.close, size: 16),
                      onDeleted: isDefault
                          ? null
                          : () => languageManager.removeLanguage(langCode),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Available Languages Section
                const Text(
                  'Available Languages',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: languageManager.availableLanguages.entries
                      .where((entry) =>
                          !languageManager.enabledLanguages.contains(entry.key))
                      .map((entry) {
                    final lang = entry.value;

                    return ActionChip(
                      avatar:
                          lang.flagEmoji != null ? Text(lang.flagEmoji!) : null,
                      label: Text(lang.name),
                      onPressed: () => languageManager.addLanguage(lang.code),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Add New Language Button
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Language'),
                    onPressed: () {
                      // Close this dialog first
                      Navigator.of(context).pop();

                      // Show add language dialog
                      showAddLanguageDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper method to show the dialog
void showLanguageManagerDialog(BuildContext context) {
  final languageManager = Provider.of<LanguageManager>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => ChangeNotifierProvider<LanguageManager>.value(
      value: languageManager,
      child: const LanguageManagerDialog(),
    ),
  );
}

// lib/widgets/language_manager_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_types.dart';

class LanguageManagerDialog extends StatefulWidget {
  const LanguageManagerDialog({Key? key}) : super(key: key);

  @override
  State<LanguageManagerDialog> createState() => _LanguageManagerDialogState();
}

class _LanguageManagerDialogState extends State<LanguageManagerDialog> {
  final _languageCodeController = TextEditingController();
  final _languageNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _languageCodeController.dispose();
    _languageNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguageState = AppLanguageState.instance;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Languages',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Available Languages'),
                      const SizedBox(height: 8),
                      // List of existing languages
                      ...appLanguageState.supportedLanguages.map(
                        (language) => LanguageListItem(
                          language: language,
                          isCurrentLanguage:
                              language.code == appLanguageState.currentLanguage,
                          onDelete: () => _deleteLanguage(language.code),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'Add New Language'),
                      const SizedBox(height: 8),
                      // Form to add new language
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Language code field
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: _languageCodeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Language Code',
                                      hintText: 'e.g., fr, ja, pt',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a language code';
                                      }
                                      if (value.length > 10) {
                                        return 'Code should be short (max 10 chars)';
                                      }
                                      if (appLanguageState
                                          .isValidLanguageCode(value)) {
                                        return 'This language code already exists';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Language name field
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _languageNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Language Name',
                                      hintText:
                                          'e.g., French, Japanese, Portuguese',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a language name';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _addLanguage,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Language'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Note: When adding a new language, templates will copy content from the default language.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addLanguage() {
    if (_formKey.currentState?.validate() ?? false) {
      final code = _languageCodeController.text.trim();
      final name = _languageNameController.text.trim();

      AppLanguageState.instance.addLanguage(code, name);

      // Clear the form
      _languageCodeController.clear();
      _languageNameController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Language "$name" added')),
      );

      // Trigger a rebuild
      setState(() {});
    }
  }

  void _deleteLanguage(String code) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to remove this language? This will delete all templates in this language.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              final result = AppLanguageState.instance.removeLanguage(code);

              if (result) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language removed')),
                );
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cannot remove the current language'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class LanguageListItem extends StatelessWidget {
  final LanguageOption language;
  final bool isCurrentLanguage;
  final VoidCallback onDelete;

  const LanguageListItem({
    Key? key,
    required this.language,
    required this.isCurrentLanguage,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrentLanguage ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(language.code),
          backgroundColor:
              isCurrentLanguage ? Colors.blue : Colors.grey.shade200,
          foregroundColor: isCurrentLanguage ? Colors.white : Colors.black,
        ),
        title: Text(language.name),
        subtitle: Text(
          isCurrentLanguage
              ? 'Current Language'
              : 'Language code: ${language.code}',
        ),
        trailing: isCurrentLanguage
            ? const Chip(
                label: Text('Current'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              )
            : IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Remove ${language.name}',
              ),
      ),
    );
  }
}

// Enhanced LanguageSelector with manage languages button
class EnhancedLanguageSelector extends StatelessWidget {
  const EnhancedLanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppLanguageState.instance,
      child: Consumer<AppLanguageState>(
        builder: (context, languageState, _) {
          final currentLanguage = languageState.supportedLanguages.firstWhere(
              (lang) => lang.code == languageState.currentLanguage,
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
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.settings, size: 18),
                  tooltip: 'Manage Languages',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LanguageManagerDialog(),
                    );
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

// Compact version for mobile view
class EnhancedCompactLanguageSelector extends StatelessWidget {
  const EnhancedCompactLanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppLanguageState.instance,
      child: Consumer<AppLanguageState>(
        builder: (context, languageState, _) {
          final currentLanguage = languageState.supportedLanguages.firstWhere(
              (lang) => lang.code == languageState.currentLanguage,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
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
                IconButton(
                  icon: const Icon(Icons.settings, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  tooltip: 'Manage Languages',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LanguageManagerDialog(),
                    );
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

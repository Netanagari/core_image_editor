// lib/widgets/language_content_viewer.dart

import 'package:core_image_editor/widgets/language_manager_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_types.dart';
import '../models/template_types.dart';
import '../state/editor_state.dart';

class LanguageContentViewer extends StatefulWidget {
  const LanguageContentViewer({Key? key}) : super(key: key);

  @override
  State<LanguageContentViewer> createState() => _LanguageContentViewerState();
}

class _LanguageContentViewerState extends State<LanguageContentViewer> {
  String? _selectedSourceLanguage;
  String? _selectedTargetLanguage;

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final languageState = AppLanguageState.instance;
    final currentLanguage = languageState.currentLanguage;

    // Get the list of languages that have content
    final languagesWithContent =
        editorState.multiLanguageContent.languageContents.keys.toList();

    // Filter languages to show only those that are supported by the app
    final supportedLanguagesWithContent = languageState.supportedLanguages
        .where((lang) => languagesWithContent.contains(lang.code))
        .toList();

    // Languages without content yet
    final languagesWithoutContent = languageState.supportedLanguages
        .where((lang) => !languagesWithContent.contains(lang.code))
        .toList();

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Language Content Manager',
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
                      // Language status overview
                      _buildLanguageStatusOverview(
                        supportedLanguagesWithContent,
                        languagesWithoutContent,
                        currentLanguage,
                      ),

                      const SizedBox(height: 24),

                      // Copy content between languages
                      _buildCopyContentSection(
                        context,
                        editorState,
                        languageState,
                        supportedLanguagesWithContent,
                      ),

                      const SizedBox(height: 24),

                      // Manage languages
                      ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text('Manage Languages'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => const LanguageManagerDialog(),
                          );
                        },
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

  Widget _buildLanguageStatusOverview(
    List<LanguageOption> languagesWithContent,
    List<LanguageOption> languagesWithoutContent,
    String currentLanguage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Languages with Content',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Languages with content
        if (languagesWithContent.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No languages with content yet.'),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: languagesWithContent
                .map(
                  (lang) => Chip(
                    label: Text(lang.name),
                    avatar: CircleAvatar(
                      backgroundColor: lang.code == currentLanguage
                          ? Colors.blue
                          : Colors.grey,
                      child: Text(
                        lang.code.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    backgroundColor: lang.code == currentLanguage
                        ? Colors.blue.withOpacity(0.1)
                        : null,
                  ),
                )
                .toList(),
          ),

        const SizedBox(height: 16),

        Text(
          'Languages without Content',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Languages without content
        if (languagesWithoutContent.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('All supported languages have content.'),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: languagesWithoutContent
                .map(
                  (lang) => Chip(
                    label: Text(lang.name),
                    avatar: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: Text(
                        lang.code.toUpperCase(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildCopyContentSection(
    BuildContext context,
    EditorState editorState,
    AppLanguageState languageState,
    List<LanguageOption> languagesWithContent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Copy Content Between Languages',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        if (languagesWithContent.length < 2)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
                'You need at least two languages with content to use this feature.'),
          )
        else
          Row(
            children: [
              // Source language dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Copy From',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSourceLanguage,
                  items: languagesWithContent
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang.code,
                          child: Text(lang.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSourceLanguage = value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward),
              const SizedBox(width: 16),

              // Target language dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Copy To',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedTargetLanguage,
                  items: languageState.supportedLanguages
                      .where((lang) => lang.code != _selectedSourceLanguage)
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang.code,
                          child: Text(lang.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTargetLanguage = value;
                    });
                  },
                ),
              ),
            ],
          ),

        const SizedBox(height: 16),

        // Copy button
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy Content'),
            onPressed: (_selectedSourceLanguage != null &&
                    _selectedTargetLanguage != null)
                ? () => _copyContent(context, editorState)
                : null,
          ),
        ),

        if (_selectedSourceLanguage != null && _selectedTargetLanguage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Note: This will overwrite any existing content in the target language.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
      ],
    );
  }

  void _copyContent(BuildContext context, EditorState editorState) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Copy'),
        content: Text(
          'Are you sure you want to copy content from ${_getLanguageName(_selectedSourceLanguage!)} to ${_getLanguageName(_selectedTargetLanguage!)}?\n\nThis will overwrite any existing content in the target language.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              // Perform the copy
              editorState.copyElementsBetweenLanguages(
                _selectedSourceLanguage!,
                _selectedTargetLanguage!,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Content copied successfully')),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    final lang = AppLanguageState.instance.getLanguageByCode(code);
    return lang?.name ?? code;
  }
}

// Button to open the Language Content Viewer
class LanguageContentViewerButton extends StatelessWidget {
  const LanguageContentViewerButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.language),
      label: const Text('Manage Content by Language'),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const LanguageContentViewer(),
        );
      },
    );
  }
}

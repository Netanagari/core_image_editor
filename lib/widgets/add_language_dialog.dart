import 'package:core_image_editor/models/editor_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_support.dart';

class AddLanguageDialog extends StatefulWidget {
  const AddLanguageDialog({super.key});

  @override
  State<AddLanguageDialog> createState() => _AddLanguageDialogState();
}

class _AddLanguageDialogState extends State<AddLanguageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _fontFamily = TextEditingController();
  final _nativeNameController = TextEditingController();
  final _flagEmojiController = TextEditingController();

  bool _isRtl = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _fontFamily.dispose();
    _nativeNameController.dispose();
    _flagEmojiController.dispose();
    super.dispose();
  }

  void _addLanguage() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _error = null;
    });

    try {
      final languageManager =
          Provider.of<LanguageManager>(context, listen: false);

      // Check if language code already exists
      if (languageManager.availableLanguages
          .containsKey(_codeController.text.trim())) {
        setState(() {
          _error = 'A language with this code already exists.';
        });
        return;
      }

      // Create the language model
      final language = LanguageModel(
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        nativeName: _nativeNameController.text.trim(),
        fontFamily:
            _fontFamily.text.trim().isEmpty ? null : _fontFamily.text.trim(),
        flagEmoji: _flagEmojiController.text.trim().isEmpty
            ? null
            : _flagEmojiController.text.trim(),
        textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      );

      // Add the language
      languageManager.addNewLanguage(language);

      // Close the dialog
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = 'Failed to add language: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Language code field
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Language Code*',
                  hintText: 'e.g., fr, de, es',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a language code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Language name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Language Name*',
                  hintText: 'e.g., French, German, Spanish',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a language name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Native name field
              TextFormField(
                controller: _nativeNameController,
                decoration: const InputDecoration(
                  labelText: 'Native Name*',
                  hintText: 'e.g., Français, Deutsch, Español',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the native name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Font family field
              DropdownButtonFormField<String>(
                value: _fontFamily.text.isEmpty ? null : _fontFamily.text,
                items: EditorConfiguration.supportedFallbackFonts
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _fontFamily.text = value;
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Font Family (optional)',
                ),
              ),

              const SizedBox(height: 12),

              // Flag emoji field
              TextFormField(
                controller: _flagEmojiController,
                decoration: const InputDecoration(
                  labelText: 'Flag Emoji (optional)',
                  hintText: 'e.g., 🇫🇷, 🇩🇪, 🇪🇸',
                ),
              ),
              const SizedBox(height: 12),

              // RTL switch
              SwitchListTile(
                title: const Text('Right-to-Left Language'),
                value: _isRtl,
                onChanged: (value) {
                  setState(() {
                    _isRtl = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addLanguage,
                    child: const Text('Add Language'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper method to show the dialog
void showAddLanguageDialog(BuildContext context) {
  final languageManager = Provider.of<LanguageManager>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => ChangeNotifierProvider<LanguageManager>.value(
      value: languageManager,
      child: const AddLanguageDialog(),
    ),
  );
}

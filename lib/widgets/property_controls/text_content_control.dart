import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/language_support.dart';
import '../../models/template_types.dart';
import '../../utils/text_measurement.dart';
import 'copy_translations_tool.dart';
import 'language_manager_dialog.dart';
import 'language_selector.dart';

class TextContentControl extends StatefulWidget {
  final TemplateElement element;
  final Size viewportSize;
  final VoidCallback onUpdate;

  const TextContentControl({
    super.key,
    required this.element,
    required this.viewportSize,
    required this.onUpdate,
  });

  @override
  State<TextContentControl> createState() => _TextContentControlState();
}

class _TextContentControlState extends State<TextContentControl> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isMultiline = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    // Get the language manager
    final languageManager = Provider.of<LanguageManager>(context, listen: false);
    final currentLanguage = languageManager.currentLanguage;
    
    // Initialize controller with current language text
    _controller = TextEditingController(
      text: widget.element.getTextContent(currentLanguage),
    );
    
    // Detect if the current text contains newlines
    _isMultiline = _controller.text.contains('\n');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TextContentControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Get the language manager
    final languageManager = Provider.of<LanguageManager>(context, listen: false);
    final currentLanguage = languageManager.currentLanguage;
    
    // Only update controller text if element changed or we're not focused
    if (oldWidget.element != widget.element || !_focusNode.hasFocus) {
      final text = widget.element.getTextContent(currentLanguage);
      if (_controller.text != text) {
        _controller.text = text;
      }
      _isMultiline = text.contains('\n');
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _updateContent(_controller.text);
    }
  }

  void _updateContent(String newText) {
    // Get the language manager
    final languageManager = Provider.of<LanguageManager>(context, listen: false);
    final currentLanguage = languageManager.currentLanguage;
    
    // Get the current text for comparison
    final currentText = widget.element.getTextContent(currentLanguage);
    
    if (currentText != newText) {
      // Update the text for the current language
      widget.element.setTextContent(currentLanguage, newText);
      
      // Adjust the box height if needed
      TextMeasurement.adjustBoxHeightForAllLanguages(
        element: widget.element,
        viewportSize: widget.viewportSize,
        context: context,
      );
      
      widget.onUpdate();
    }
  }

  void _toggleMultiline() {
    setState(() {
      _isMultiline = !_isMultiline;
      if (!_isMultiline) {
        // Remove newlines when switching to single line
        final newText = _controller.text.replaceAll('\n', ' ');
        _controller.text = newText;
        _updateContent(newText);
      }
    });
  }

  void _showLanguageManager() {
    showDialog(
      context: context,
      builder: (context) => const LanguageManagerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the language manager and theme
    final languageManager = Provider.of<LanguageManager>(context);
    final currentLanguage = languageManager.currentLanguage;
    final currentLanguageModel = languageManager.enabledLanguages
        .firstWhere((l) => l.code == currentLanguage);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language controls section
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LanguageSelector(),
            ),
            IconButton(
              icon: const Icon(Icons.language),
              tooltip: 'Manage Languages',
              onPressed: _showLanguageManager,
            ),
          ],
        ),

        const SizedBox(height: 8),
        CopyTranslationsTool(
          currentElement: widget.element,
          onUpdate: widget.onUpdate,
        ),

        // Display current language info
        const SizedBox(height: 4),
        Row(
          children: [
            if (currentLanguageModel.flagEmoji != null) ...[
              Text(
                currentLanguageModel.flagEmoji!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              'Editing ${currentLanguageModel.name} (${currentLanguageModel.nativeName})',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // Text input section
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: _isMultiline ? null : 1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_isMultiline ? Icons.wrap_text : Icons.short_text),
                  onPressed: _toggleMultiline,
                  tooltip: _isMultiline ? 'Single line' : 'Multi-line',
                ),
                if (!_isMultiline) ...[
                  IconButton(
                    icon: Icon(
                      widget.element.style.isItalic
                          ? Icons.format_italic
                          : Icons.format_italic_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        widget.element.style.isItalic = !widget.element.style.isItalic;
                        widget.onUpdate();
                      });
                    },
                    tooltip: 'Italic',
                  ),
                  IconButton(
                    icon: Icon(
                      widget.element.style.isUnderlined
                          ? Icons.format_underline
                          : Icons.format_underline_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        widget.element.style.isUnderlined = !widget.element.style.isUnderlined;
                        widget.onUpdate();
                      });
                    },
                    tooltip: 'Underline',
                  ),
                ],
              ],
            ),
          ),
          onChanged: (value) {
            // Update content immediately on change
            _updateContent(value);
          },
          textDirection: languageManager.isRtl(currentLanguage)
              ? TextDirection.rtl
              : TextDirection.ltr,
        ),
      ],
    );
  }
}

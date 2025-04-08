import 'package:core_image_editor/widgets/property_controls/copy_translations_tool.dart';
import 'package:core_image_editor/widgets/property_controls/language_manager_dialog.dart';
import 'package:core_image_editor/widgets/property_controls/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/language_support.dart';
import '../../models/template_types.dart';
import '../../utils/text_measurement.dart';

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
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Ensure the element has multilingual content structure
    if (!widget.element.hasMultilingualContent) {
      widget.element.convertToMultilingual();
    }

    // Get the language manager
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final currentLanguage = languageManager.currentLanguage;

    // Initialize controller with the text for current language
    _controller = TextEditingController(
      text: widget.element.getTextContent(currentLanguage),
    );

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Detect if the current text contains newlines
    _isMultiline = (_controller.text.contains('\n'));
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
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final currentLanguage = languageManager.currentLanguage;

    // If the element or language changed, update the controller
    if (oldWidget.element != widget.element || _focusNode.hasFocus == false) {
      _controller.text = widget.element.getTextContent(currentLanguage);
      _isMultiline = _controller.text.contains('\n');
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _updateContent(_controller.text);
    }
  }

  void _updateContent(String newText) {
    // Get the language manager
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final currentLanguage = languageManager.currentLanguage;

    // Get the current text for comparison
    final currentText = widget.element.getTextContent(currentLanguage);

    if (currentText != newText) {
      // Update the text for the current language
      widget.element.setTextContent(currentLanguage, newText);

      // Adjust the box height if needed
      TextMeasurement.adjustBoxHeight(
        element: widget.element,
        newText: newText,
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
    final theme = Theme.of(context);

    // Get the language manager
    final languageManager = Provider.of<LanguageManager>(context);
    final currentLanguage = languageManager.currentLanguage;
    final currentLanguageModel =
        languageManager.getLanguageModel(currentLanguage);

    // Update the controller if language changes
    if (widget.element.getTextContent(currentLanguage) != _controller.text &&
        !_focusNode.hasFocus) {
      _controller.text = widget.element.getTextContent(currentLanguage);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Text Content',
                  style: theme.textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isMultiline ? Icons.wrap_text : Icons.short_text,
                        size: 20,
                        color: _isHovered || _isMultiline
                            ? theme.primaryColor
                            : theme.iconTheme.color,
                      ),
                      tooltip: _isMultiline
                          ? 'Switch to Single Line'
                          : 'Switch to Multiline',
                      onPressed: _toggleMultiline,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ],
            ),

            // Add language selector
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
            if (currentLanguageModel != null) ...[
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
            ],

            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: _isMultiline ? null : 1,
              minLines: _isMultiline ? 3 : 1,
              keyboardType:
                  _isMultiline ? TextInputType.multiline : TextInputType.text,
              textInputAction:
                  _isMultiline ? TextInputAction.newline : TextInputAction.done,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                hintText: 'Enter text...',
              ),
              textDirection: languageManager.isRtl(currentLanguage)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              onChanged: (value) {
                // Update the element's content immediately
                _isMultiline = value.contains('\n');
                _updateContent(value);
              },
            ),
            if (_isMultiline)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lines: ${_controller.text.split('\n').length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      'Characters: ${_controller.text.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            // Quick text tools
            if (_isMultiline)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickTextButton(
                      label: 'Clear',
                      icon: Icons.clear_all,
                      onPressed: () {
                        _controller.clear();
                        _updateContent('');
                      },
                    ),
                    _QuickTextButton(
                      label: 'Capitalize',
                      icon: Icons.text_fields,
                      onPressed: () {
                        final newText = _controller.text.toUpperCase();
                        _controller.text = newText;
                        _updateContent(newText);
                      },
                    ),
                    _QuickTextButton(
                      label: 'Lowercase',
                      icon: Icons.text_fields,
                      onPressed: () {
                        final newText = _controller.text.toLowerCase();
                        _controller.text = newText;
                        _updateContent(newText);
                      },
                    ),
                    _QuickTextButton(
                      label: 'Title Case',
                      icon: Icons.text_fields,
                      onPressed: () {
                        final newText = _controller.text
                            .split(' ')
                            .map((word) => word.isEmpty
                                ? ''
                                : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
                            .join(' ');
                        _controller.text = newText;
                        _updateContent(newText);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickTextButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _QuickTextButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_QuickTextButton> createState() => _QuickTextButtonState();
}

class _QuickTextButtonState extends State<_QuickTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? theme.primaryColor.withOpacity(0.1) : null,
            border: Border.all(
              color: _isHovered ? theme.primaryColor : theme.dividerColor,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _isHovered ? theme.primaryColor : theme.iconTheme.color,
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _isHovered
                      ? theme.primaryColor
                      : theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

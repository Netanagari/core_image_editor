// lib/widgets/property_controls/localized_text_control.dart

import 'package:flutter/material.dart';
import '../../models/template_types.dart';
import '../../models/language_types.dart';
import '../../utils/text_measurement.dart';

class LocalizedTextControl extends StatefulWidget {
  final TemplateElement element;
  final Size viewportSize;
  final VoidCallback onUpdate;

  const LocalizedTextControl({
    super.key,
    required this.element,
    required this.viewportSize,
    required this.onUpdate,
  });

  @override
  State<LocalizedTextControl> createState() => _LocalizedTextControlState();
}

class _LocalizedTextControlState extends State<LocalizedTextControl> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final GlobalKey _tabBarKey = GlobalKey();
  bool _isMultiline = false;

  @override
  void initState() {
    super.initState();
    final languages = AppLanguageState.instance.supportedLanguages;
    _tabController = TabController(length: languages.length, vsync: this);
    
    // Setup controllers and focus nodes for each language
    final localizedText = widget.element.localizedText;
    
    for (final language in languages) {
      final text = localizedText.get(language.code);
      _controllers[language.code] = TextEditingController(text: text);
      _focusNodes[language.code] = FocusNode()..addListener(() {
        _handleFocusChange(language.code);
      });
    }
    
    // Detect if any text contains newlines
    _isMultiline = _controllers.values.any((controller) => controller.text.contains('\n'));
    
    // Set initial tab to current language
    final currentLangIndex = languages.indexWhere(
      (lang) => lang.code == AppLanguageState.instance.currentLanguage
    );
    if (currentLangIndex != -1) {
      _tabController.index = currentLangIndex;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.removeListener(() {});
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange(String languageCode) {
    if (!_focusNodes[languageCode]!.hasFocus) {
      _updateContent(languageCode, _controllers[languageCode]!.text);
    }
  }

  void _updateContent(String languageCode, String newText) {
    widget.element.updateTextForLanguage(languageCode, newText);
    
    TextMeasurement.adjustBoxHeight(
      element: widget.element,
      newText: newText,
      viewportSize: widget.viewportSize,
      context: context,
    );
    
    widget.onUpdate();
  }

  void _toggleMultiline() {
    setState(() {
      _isMultiline = !_isMultiline;
      if (!_isMultiline) {
        // Remove newlines when switching to single line for all languages
        for (final entry in _controllers.entries) {
          final languageCode = entry.key;
          final controller = entry.value;
          final newText = controller.text.replaceAll('\n', ' ');
          controller.text = newText;
          _updateContent(languageCode, newText);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languages = AppLanguageState.instance.supportedLanguages;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Multilingual Text Content',
                style: theme.textTheme.bodyMedium,
              ),
              IconButton(
                icon: Icon(
                  _isMultiline ? Icons.wrap_text : Icons.short_text,
                  size: 20,
                  color: _isMultiline ? theme.primaryColor : theme.iconTheme.color,
                ),
                tooltip: _isMultiline ? 'Switch to Single Line' : 'Switch to Multiline',
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
          const SizedBox(height: 8),
          
          // Language tabs
          TabBar(
            key: _tabBarKey,
            controller: _tabController,
            isScrollable: true,
            tabs: languages.map((lang) => Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flag or language indicator could go here
                  // For now, just show language code
                  Text(lang.name),
                ],
              ),
            )).toList(),
          ),
          
          // Text field area
          SizedBox(
            height: _isMultiline ? 200 : 80,
            child: TabBarView(
              controller: _tabController,
              children: languages.map((language) {
                final controller = _controllers[language.code]!;
                final focusNode = _focusNodes[language.code]!;
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    maxLines: _isMultiline ? null : 1,
                    minLines: _isMultiline ? 5 : 1,
                    keyboardType: _isMultiline ? TextInputType.multiline : TextInputType.text,
                    textInputAction: _isMultiline ? TextInputAction.newline : TextInputAction.done,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      hintText: 'Enter text in ${language.name}...',
                    ),
                    onChanged: (value) {
                      // Update the content immediately
                      _updateContent(language.code, value);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          if (_isMultiline)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickTextButton(
                    label: 'Clear Current',
                    icon: Icons.clear,
                    onPressed: () {
                      final currentLang = languages[_tabController.index].code;
                      _controllers[currentLang]!.clear();
                      _updateContent(currentLang, '');
                    },
                  ),
                  _QuickTextButton(
                    label: 'Copy from Default',
                    icon: Icons.copy,
                    onPressed: () {
                      final defaultLang = widget.element.localizedText.defaultLanguage;
                      final currentLang = languages[_tabController.index].code;
                      if (defaultLang != currentLang) {
                        final defaultText = _controllers[defaultLang]?.text ?? '';
                        _controllers[currentLang]!.text = defaultText;
                        _updateContent(currentLang, defaultText);
                      }
                    },
                  ),
                  _QuickTextButton(
                    label: 'Set as Default',
                    icon: Icons.star,
                    onPressed: () {
                      final currentLang = languages[_tabController.index].code;
                      final localized = widget.element.localizedText;
                      localized.defaultLanguage = currentLang;
                      widget.element.setLocalizedText(localized);
                      widget.onUpdate();
                    },
                  ),
                ],
              ),
            ),
        ],
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
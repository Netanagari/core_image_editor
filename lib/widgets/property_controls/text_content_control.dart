import 'package:flutter/material.dart';
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
    _controller = TextEditingController(
      text: widget.element.content['text'] ?? '',
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
    if (oldWidget.element.content['text'] != widget.element.content['text'] &&
        !_focusNode.hasFocus) {
      _controller.text = widget.element.content['text'] ?? '';
      _isMultiline = _controller.text.contains('\n');
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _updateContent(_controller.text);
    }
  }

  void _updateContent(String newText) {
    if (widget.element.content['text'] != newText) {
      widget.element.content['text'] = newText;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            const SizedBox(height: 4),
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

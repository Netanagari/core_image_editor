import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/template_types.dart';
import '../../models/editor_config.dart';

class NestedContentControls extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;
  final Future<String> Function(BuildContext) onSelectImage;
  final EditorConfiguration configuration;

  const NestedContentControls({
    super.key,
    required this.element,
    required this.onUpdate,
    required this.onSelectImage,
    required this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    if (!element.canContainNestedContent) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Nested Content'),
        const SizedBox(height: 8),
        _buildAddContentButton(context),
        if (element.nestedContent?.content != null) ...[
          const SizedBox(height: 16),
          _buildContentFitControl(),
          const SizedBox(height: 8),
          _buildContentAlignmentControl(),
          const SizedBox(height: 8),
          if (element.nestedContent?.content?.type == 'text') ...[
            _buildTextControls(context),
          ],
          const SizedBox(height: 16),
          _buildRemoveContentButton(),
        ],
      ],
    );
  }

  Widget _buildTextControls(BuildContext context) {
    final nestedElement = element.nestedContent!.content!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Text Properties'),

        // Text Content
        TextField(
          decoration: const InputDecoration(
            labelText: 'Text Content',
          ),
          maxLines: null,
          controller: TextEditingController(
            text: nestedElement.content['text'] ?? '',
          ),
          onChanged: (value) {
            nestedElement.content['text'] = value;
            onUpdate();
          },
        ),
        const SizedBox(height: 12),

        // Font Size
        Row(
          children: [
            const Text('Font Size (vw)'),
            Expanded(
              child: Slider(
                value: nestedElement.style.fontSizeVw,
                min: 1,
                max: 10,
                divisions: 90,
                label: nestedElement.style.fontSizeVw.toStringAsFixed(1),
                onChanged: (value) {
                  nestedElement.style.fontSizeVw = value;
                  onUpdate();
                },
              ),
            ),
          ],
        ),

        // Font Weight
        Row(
          children: [
            const Text('Bold'),
            Switch(
              value: nestedElement.style.fontWeight == FontWeight.bold,
              onChanged: (value) {
                nestedElement.style.fontWeight =
                    value ? FontWeight.bold : FontWeight.normal;
                onUpdate();
              },
            ),
          ],
        ),

        // Italic
        Row(
          children: [
            const Text('Italic'),
            Switch(
              value: nestedElement.style.isItalic,
              onChanged: (value) {
                nestedElement.style.isItalic = value;
                onUpdate();
              },
            ),
          ],
        ),

        // Text Color
        ColorPickerButton(
          color: Color(
            int.parse(nestedElement.style.color.replaceFirst('#', '0xff')),
          ),
          onColorChanged: (color) {
            nestedElement.style.color =
                '#${color.value.toRadixString(16).substring(2)}';
            onUpdate();
          },
        ),

        // Font Family Selection
        if (configuration.can(EditorCapability.changeFonts)) ...[
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: nestedElement.style.fontFamily,
            isExpanded: true,
            items: configuration.availableFonts.map((font) {
              return DropdownMenuItem(
                value: font,
                child: Text(font),
              );
            }).toList(),
            onChanged: (newFont) {
              if (newFont != null) {
                nestedElement.style.fontFamily = newFont;
                onUpdate();
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAddContentButton(BuildContext context) {
    if (element.nestedContent?.content != null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.image),
          label: const Text('Add Image'),
          onPressed: () => _addImage(context),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.text_fields),
          label: const Text('Add Text'),
          onPressed: () => _addText(),
        ),
      ],
    );
  }

  Widget _buildContentFitControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Content Fit'),
        const SizedBox(height: 4),
        DropdownButton<BoxFit>(
          value: element.nestedContent!.contentFit,
          isExpanded: true,
          items: [
            BoxFit.contain,
            BoxFit.cover,
            BoxFit.fill,
            BoxFit.fitWidth,
            BoxFit.fitHeight,
          ].map((fit) {
            return DropdownMenuItem(
              value: fit,
              child: Text(fit.toString().split('.').last),
            );
          }).toList(),
          onChanged: (newFit) {
            if (newFit != null) {
              element.nestedContent!.contentFit = newFit;
              onUpdate();
            }
          },
        ),
      ],
    );
  }

  Widget _buildContentAlignmentControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Content Alignment'),
        const SizedBox(height: 4),
        DropdownButton<Alignment>(
          value: element.nestedContent!.contentAlignment,
          isExpanded: true,
          items: [
            Alignment.center,
            Alignment.topLeft,
            Alignment.topRight,
            Alignment.bottomLeft,
            Alignment.bottomRight,
          ].map((alignment) {
            return DropdownMenuItem(
              value: alignment,
              child: Text(alignment.toString().split('.').last),
            );
          }).toList(),
          onChanged: (newAlignment) {
            if (newAlignment != null) {
              element.nestedContent!.contentAlignment = newAlignment;
              onUpdate();
            }
          },
        ),
      ],
    );
  }

  Widget _buildRemoveContentButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.delete),
      label: const Text('Remove Content'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        element.nestedContent = null;
        onUpdate();
      },
    );
  }

  Future<void> _addImage(BuildContext context) async {
    final url = await onSelectImage(context);
    element.nestedContent = NestedContent(
      content: TemplateElement(
        type: 'image',
        box: TemplateBox(
          xPercent: 0,
          yPercent: 0,
          widthPercent: 100,
          heightPercent: 100,
          alignment: 'center',
        ),
        content: {'url': url},
        style: TemplateStyle(
          fontSizeVw: 0,
          color: '#000000',
          imageFit: BoxFit.cover,
        ),
      ),
      contentFit: BoxFit.cover,
    );
    onUpdate();
  }

  void _addText() {
    element.nestedContent = NestedContent(
      content: TemplateElement(
        type: 'text',
        box: TemplateBox(
          xPercent: 0,
          yPercent: 0,
          widthPercent: 100,
          heightPercent: 100,
          alignment: 'center',
        ),
        content: {'text': 'New Text'},
        style: TemplateStyle(
          fontSizeVw: 4.0,
          color: '#000000',
          fontFamily: 'Roboto',
        ),
      ),
      contentFit: BoxFit.contain,
    );
    onUpdate();
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class ColorPickerButton extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerButton({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showColorPicker(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Text Color'),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color,
            onColorChanged: onColorChanged,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

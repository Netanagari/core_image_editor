import 'package:flutter/material.dart';
import '../../models/template_types.dart';
import 'color_picker.dart';
import 'number_input.dart';

class TextShadowControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const TextShadowControl({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Text Shadow'),
          const SizedBox(height: 4),
          CheckboxListTile(
            title: const Text('Enable Text Shadow'),
            value: element.style.textShadow != null,
            onChanged: (value) {
              if (value == true) {
                element.style.textShadow = {
                  'color': '#000000',
                  'offsetX': 0.0,
                  'offsetY': 2.0,
                  'blurRadius': 4.0,
                };
              } else {
                element.style.textShadow = null;
              }
              onUpdate();
            },
          ),
          if (element.style.textShadow != null) ...[
            NColorPicker(
              label: 'Shadow Color',
              color: element.style.textShadow!['color'] ?? '#000000',
              onColorChanged: (color) {
                element.style.textShadow!['color'] = color;
                onUpdate();
              },
            ),
            NumberInput(
              label: 'Offset X',
              value: element.style.textShadow!['offsetX'] ?? 0.0,
              onChanged: (value) {
                element.style.textShadow!['offsetX'] = value;
                onUpdate();
              },
              min: -50,
              max: 50,
            ),
            NumberInput(
              label: 'Offset Y',
              value: element.style.textShadow!['offsetY'] ?? 2.0,
              onChanged: (value) {
                element.style.textShadow!['offsetY'] = value;
                onUpdate();
              },
              min: -50,
              max: 50,
            ),
            NumberInput(
              label: 'Blur Radius',
              value: element.style.textShadow!['blurRadius'] ?? 4.0,
              onChanged: (value) {
                element.style.textShadow!['blurRadius'] = value;
                onUpdate();
              },
              min: 0,
              max: 50,
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/template_types.dart';
import 'color_picker.dart';
import 'number_input.dart';

class BoxShadowControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const BoxShadowControl({
    Key? key,
    required this.element,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Box Shadow'),
          const SizedBox(height: 4),
          CheckboxListTile(
            title: const Text('Enable Shadow'),
            value: element.style.boxShadow != null,
            onChanged: (value) {
              if (value == true) {
                element.style.boxShadow = {
                  'color': '#000000',
                  'offsetX': 0.0,
                  'offsetY': 2.0,
                  'blurRadius': 4.0,
                  'spreadRadius': 0.0,
                };
              } else {
                element.style.boxShadow = null;
              }
              onUpdate();
            },
          ),
          if (element.style.boxShadow != null) ...[
            ColorPicker(
              label: 'Shadow Color',
              color: element.style.boxShadow!['color'] ?? '#000000',
              onColorChanged: (color) {
                element.style.boxShadow!['color'] = color;
                onUpdate();
              },
            ),
            NumberInput(
              label: 'Offset X',
              value: element.style.boxShadow!['offsetX'] ?? 0.0,
              onChanged: (value) {
                element.style.boxShadow!['offsetX'] = value;
                onUpdate();
              },
              min: -50,
              max: 50,
            ),
            NumberInput(
              label: 'Offset Y',
              value: element.style.boxShadow!['offsetY'] ?? 2.0,
              onChanged: (value) {
                element.style.boxShadow!['offsetY'] = value;
                onUpdate();
              },
              min: -50,
              max: 50,
            ),
            NumberInput(
              label: 'Blur Radius',
              value: element.style.boxShadow!['blurRadius'] ?? 4.0,
              onChanged: (value) {
                element.style.boxShadow!['blurRadius'] = value;
                onUpdate();
              },
              min: 0,
              max: 50,
            ),
            NumberInput(
              label: 'Spread Radius',
              value: element.style.boxShadow!['spreadRadius'] ?? 0.0,
              onChanged: (value) {
                element.style.boxShadow!['spreadRadius'] = value;
                onUpdate();
              },
              min: -50,
              max: 50,
            ),
          ],
        ],
      ),
    );
  }
}
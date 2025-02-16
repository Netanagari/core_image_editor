import 'package:flutter/material.dart';
import '../../models/template_types.dart';
import 'color_picker.dart';
import 'number_input.dart';

class BorderControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const BorderControl({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Border Style'),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: element.style.borderStyle ?? 'none',
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'none', child: Text('None')),
            DropdownMenuItem(value: 'solid', child: Text('Solid')),
            DropdownMenuItem(value: 'dashed', child: Text('Dashed')),
            DropdownMenuItem(value: 'dotted', child: Text('Dotted')),
          ],
          onChanged: (String? newValue) {
            element.style.borderStyle = newValue;
            if (newValue == 'none') {
              element.style.borderWidth = 0;
              element.style.borderColor = null;
            } else {
              element.style.borderWidth ??= 1;
              element.style.borderColor ??= '#000000';
            }
            onUpdate();
          },
        ),
        if (element.style.borderStyle != null &&
            element.style.borderStyle != 'none') ...[
          NumberInput(
            label: 'Border Width',
            value: element.style.borderWidth ?? 1,
            onChanged: (value) {
              element.style.borderWidth = value;
              onUpdate();
            },
            min: 0.5,
            max: 20,
          ),
          NumberInput(
            label: 'Border Radius',
            value: element.style.borderRadius ?? 1,
            onChanged: (value) {
              element.style.borderRadius = value;
              onUpdate();
            },
            min: 1,
            max: 100,
          ),
          NColorPicker(
            label: 'Border Color',
            color: element.style.borderColor ?? '#000000',
            onColorChanged: (color) {
              element.style.borderColor = color;
              onUpdate();
            },
          ),
        ],
      ],
    );
  }
}

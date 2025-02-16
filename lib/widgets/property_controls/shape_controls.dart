import 'package:flutter/material.dart';
import '../../models/shape_types.dart';
import '../../models/template_types.dart';
import 'color_picker.dart';
import 'number_input.dart';

class ShapeControls extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const ShapeControls({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final shapeType = ShapeType.values.firstWhere(
      (type) => type.toString() == element.content['shapeType'],
      orElse: () => ShapeType.rectangle,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shape Properties'),
        const SizedBox(height: 8),
        // Fill Color
        NColorPicker(
          label: 'Fill Color',
          color: element.content['fillColor'] ?? '#FFFFFF',
          onColorChanged: (color) {
            element.content['fillColor'] = color;
            onUpdate();
          },
        ),
        // Stroke Color
        NColorPicker(
          label: 'Stroke Color',
          color: element.content['strokeColor'] ?? '#000000',
          onColorChanged: (color) {
            element.content['strokeColor'] = color;
            onUpdate();
          },
        ),
        // Stroke Width
        NumberInput(
          label: 'Stroke Width',
          value: element.content['strokeWidth']?.toDouble() ?? 2.0,
          onChanged: (value) {
            element.content['strokeWidth'] = value;
            onUpdate();
          },
          min: 0.5,
          max: 20,
        ),
        // Stroke Style
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Dashed Stroke'),
                  value: element.content['isStrokeDashed'] ?? false,
                  onChanged: (value) {
                    element.content['isStrokeDashed'] = value;
                    onUpdate();
                  },
                  dense: true,
                ),
              ),
            ],
          ),
        ),
        // Shape-specific properties
        if (shapeType == ShapeType.star) ...[
          NumberInput(
            label: 'Points',
            value: (element.content['points'] ?? 5).toDouble(),
            onChanged: (value) {
              element.content['points'] = value.toInt();
              onUpdate();
            },
            min: 3,
            max: 12,
          ),
          NumberInput(
            label: 'Inner Radius Ratio',
            value: element.content['innerRadiusRatio']?.toDouble() ?? 0.4,
            onChanged: (value) {
              element.content['innerRadiusRatio'] = value;
              onUpdate();
            },
            min: 0.1,
            max: 0.9,
          ),
        ] else if (shapeType == ShapeType.pentagon ||
            shapeType == ShapeType.hexagon) ...[
          NumberInput(
            label: 'Sides',
            value: (element.content['sides'] ??
                    (shapeType == ShapeType.pentagon ? 5 : 6))
                .toDouble(),
            onChanged: (value) {
              element.content['sides'] = value.toInt();
              onUpdate();
            },
            min: 3,
            max: 12,
          ),
        ] else if (shapeType == ShapeType.arrow) ...[
          NumberInput(
            label: 'Head Size',
            value: element.content['headSize']?.toDouble() ?? 0.3,
            onChanged: (value) {
              element.content['headSize'] = value;
              onUpdate();
            },
            min: 0.1,
            max: 0.5,
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/template_types.dart';
import 'number_input.dart';

class FontSizeControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const FontSizeControl({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Font Size'),
        const SizedBox(height: 8),
        // Row(
        //   children: [
        //     Expanded(
        //       child: NumberInput(
        //         label: 'Size (vw)',
        //         value: element.style.fontSizeVw,
        //         onChanged: (value) {
        //           element.style.fontSizeVw = value;
        //           onUpdate();
        //         },
        //         min: 0.5,
        //         max: 20,
        //         decimalPlaces: 1,
        //         stepSize: 0.5,
        //         suffix: 'vw',
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 8),
        // New: Font size in px input
        Row(
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  // Try to get the element width in px from the context
                  double? elementWidthPx;
                  final inherited =
                      context.findAncestorWidgetOfExactType<Container>();
                  if (inherited != null && inherited.constraints != null) {
                    elementWidthPx = inherited.constraints!.maxWidth;
                  }
                  // Fallback: use 100vw as 100% width
                  elementWidthPx ??= 1000;
                  return TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Font Size (px)',
                      suffixText: 'px',
                    ),
                    keyboardType: TextInputType.number,
                    initialValue:
                        ((element.style.fontSizeVw / 100) * elementWidthPx)
                            .toStringAsFixed(0),
                    onChanged: (value) {
                      final px = double.tryParse(value);
                      if (px != null && elementWidthPx! > 0) {
                        element.style.fontSizeVw = (px / elementWidthPx) * 100;
                        onUpdate();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Font size quick presets
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // _buildSizePresetButton(context, 'XS', 2.0),
            // _buildSizePresetButton(context, 'S', 3.0),
            // _buildSizePresetButton(context, 'M', 4.0),
            // _buildSizePresetButton(context, 'L', 5.0),
            // _buildSizePresetButton(context, 'XL', 6.0),
            // _buildSizePresetButton(context, '2XL', 7.0),
          ],
        ),
      ],
    );
  }

  Widget _buildSizePresetButton(
      BuildContext context, String label, double size) {
    final isSelected = (element.style.fontSizeVw - size).abs() < 0.1;

    return InkWell(
      onTap: () {
        element.style.fontSizeVw = size;
        onUpdate();
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Colors.grey[100],
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
          ),
        ),
      ),
    );
  }
}

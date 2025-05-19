import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/template_types.dart';
import '../../state/editor_state.dart';
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
    final editorState = context.watch<EditorState>();
    // Use originalWidthValue from EditorState for consistent calculations
    final double elementWidthPx = element.box.widthPx ??
        (element.box.widthPercent / 100.0) * editorState.originalWidthValue;

    // Calculate current font size in px for display
    // Ensure elementWidthPx is not zero to avoid division by zero
    final double currentFontSizePx = elementWidthPx > 0
        ? (element.style.fontSizeVw / 100.0) * elementWidthPx
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Font Size', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Row(
        //   children: [
        //     Expanded(
        //       child: NumberInput(
        //         label: 'Size',
        //         value: element.style.fontSizeVw,
        //         onChanged: (value) {
        //           element.style.fontSizeVw = value;
        //           onUpdate();
        //         },
        //         min: 0.5,
        //         max: 100, // Increased max for flexibility
        //         decimalPlaces: 1,
        //         stepSize: 0.1,
        //         suffix: 'vw',
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: NumberInput(
                label: 'Size (px)',
                value: currentFontSizePx,
                onChanged: (pxValue) {
                  if (elementWidthPx > 0) {
                    element.style.fontSizeVw =
                        (pxValue / elementWidthPx) * 100.0;
                    onUpdate();
                  }
                },
                min: 1, // Minimum 1px
                max: 1000, // Arbitrary large max
                decimalPlaces: 0,
                stepSize: 1,
                suffix: 'px',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
      BuildContext context, String label, double sizeVw) {
    // Check against element.style.fontSizeVw for selection
    final isSelected = (element.style.fontSizeVw - sizeVw).abs() < 0.01;

    return InkWell(
      onTap: () {
        element.style.fontSizeVw = sizeVw;
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

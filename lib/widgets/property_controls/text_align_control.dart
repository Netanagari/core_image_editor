import 'package:flutter/material.dart';
import '../../models/template_types.dart';

class TextAlignControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const TextAlignControl({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'left',
                  icon: Icon(Icons.format_align_left),
                ),
                ButtonSegment(
                  value: 'center',
                  icon: Icon(Icons.format_align_center),
                ),
                ButtonSegment(
                  value: 'right',
                  icon: Icon(Icons.format_align_right),
                ),
                ButtonSegment(
                  value: 'justify',
                  icon: Icon(Icons.format_align_justify),
                ),
              ],
              selected: {element.style.textAlign ?? 'left'},
              onSelectionChanged: (Set<String> newSelection) {
                element.style.textAlign = newSelection.first;
                onUpdate();
              },
            ),
          ),
        ],
      ),
    );
  }
}

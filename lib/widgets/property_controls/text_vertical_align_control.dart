import 'package:flutter/material.dart';
import '../../models/template_types.dart';

class TextVerticalAlignControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const TextVerticalAlignControl({
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
          const Text(
            'Vertical Alignment',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'top',
                      icon: Icon(Icons.vertical_align_top),
                    ),
                    ButtonSegment(
                      value: 'center',
                      icon: Icon(Icons.vertical_align_center),
                    ),
                    ButtonSegment(
                      value: 'bottom',
                      icon: Icon(Icons.vertical_align_bottom),
                    ),
                  ],
                  selected: {element.style.textVerticalAlign ?? 'center'},
                  onSelectionChanged: (Set<String> newSelection) {
                    element.style.textVerticalAlign = newSelection.first;
                    onUpdate();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

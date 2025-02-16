import 'package:flutter/material.dart';
import '../../models/template_types.dart';

class AlignmentControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const AlignmentControl({
    Key? key,
    required this.element,
    required this.onUpdate,
  }) : super(key: key);

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
              ],
              selected: {element.box.alignment},
              onSelectionChanged: (Set<String> newSelection) {
                element.box.alignment = newSelection.first;
                onUpdate();
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../models/template_types.dart';
import 'package:provider/provider.dart';
import '../../state/editor_state.dart';

class LayerControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const LayerControl({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();

    // Get sorted list of elements by z-index
    final sortedElements = [...editorState.elements]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    // Find current element index in sorted list
    final currentIndex = sortedElements.indexWhere((e) => e == element);

    // Find previous and next elements
    final hasElementAbove = currentIndex < sortedElements.length - 1;
    final hasElementBelow = currentIndex > 0;

    // Get z-indices for elements above and below if they exist
    final nearestAboveZIndex =
        hasElementAbove ? sortedElements[currentIndex + 1].zIndex : null;
    final nearestBelowZIndex =
        hasElementBelow ? sortedElements[currentIndex - 1].zIndex : null;

    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.flip_to_front),
          label: const Text('Bring Front'),
          onPressed: hasElementAbove
              ? () {
                  // Move just above the nearest element above
                  element.zIndex = nearestAboveZIndex! + 1;
                  onUpdate();
                }
              : null,
        ),
        SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.flip_to_back),
          label: const Text('Send Back'),
          onPressed: hasElementBelow
              ? () {
                  // Move just below the nearest element below
                  element.zIndex = nearestBelowZIndex! - 1;
                  onUpdate();
                }
              : null,
        ),
      ],
    );
  }
}

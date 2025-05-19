import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/template_types.dart';
import '../../state/editor_state.dart';
import 'number_input.dart';

class PositionControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const PositionControl({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final originalWidth = editorState.originalWidthValue;
    final originalHeight = editorState.originalHeightValue;

    // Ensure xPx and yPx are initialized if null, based on percentages
    // This helps in displaying a pixel value even if only percentages were set initially.
    // However, the source of truth for calculation should prioritize existing Px values if user edits them.
    double currentXPercent = element.box.xPercent;
    double currentYPercent = element.box.yPercent;

    double currentXPx =
        element.box.xPx ?? (currentXPercent / 100.0) * originalWidth;
    double currentYPx =
        element.box.yPx ?? (currentYPercent / 100.0) * originalHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Position", style: TextStyle(fontWeight: FontWeight.bold)),
        // NumberInput(
        //   label: 'X',
        //   value: currentXPercent,
        //   onChanged: (value) {
        //     element.box.xPercent = value;
        //     element.box.xPx = (value / 100.0) * originalWidth;
        //     onUpdate();
        //   },
        //   min: 0,
        //   // Ensure element doesn't go off-screen
        //   max: (100 - element.box.widthPercent).clamp(0.0, 100.0),
        //   suffix: '%',
        // ),
        // NumberInput(
        //   label: 'Y',
        //   value: currentYPercent,
        //   onChanged: (value) {
        //     element.box.yPercent = value;
        //     element.box.yPx = (value / 100.0) * originalHeight;
        //     onUpdate();
        //   },
        //   min: 0,
        //   // Ensure element doesn't go off-screen
        //   max: (100 - element.box.heightPercent).clamp(0.0, 100.0),
        //   suffix: '%',
        // ),
        // const SizedBox(height: 8),
        NumberInput(
          label: 'X',
          value: currentXPx,
          onChanged: (value) {
            element.box.xPx = value;
            if (originalWidth > 0) {
              element.box.xPercent = (value / originalWidth) * 100.0;
            }
            onUpdate();
          },
          min: 0,
          max: originalWidth -
              (element.box.widthPercent / 100.0 * originalWidth),
          suffix: 'px',
          decimalPlaces: 0,
        ),
        NumberInput(
          label: 'Y',
          value: currentYPx,
          onChanged: (value) {
            element.box.yPx = value;
            if (originalHeight > 0) {
              element.box.yPercent = (value / originalHeight) * 100.0;
            }
            onUpdate();
          },
          min: 0,
          max: originalHeight -
              (element.box.heightPercent / 100.0 * originalHeight),
          suffix: 'px',
          decimalPlaces: 0,
        ),
      ],
    );
  }
}

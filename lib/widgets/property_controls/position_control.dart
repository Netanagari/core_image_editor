import 'package:flutter/material.dart';
import '../../models/template_types.dart';
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
    return Column(
      children: [
        NumberInput(
          label: 'X Position',
          value: element.box.xPercent,
          onChanged: (value) {
            element.box.xPercent = value;
            onUpdate();
          },
          min: 0,
          max: 100 - element.box.widthPercent,
          suffix: '%',
        ),
        NumberInput(
          label: 'Y Position',
          value: element.box.yPercent,
          onChanged: (value) {
            element.box.yPercent = value;
            onUpdate();
          },
          min: 0,
          max: 100 - element.box.heightPercent,
          suffix: '%',
        ),
      ],
    );
  }
}

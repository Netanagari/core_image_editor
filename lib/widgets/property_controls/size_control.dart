import 'package:flutter/material.dart';
import '../../models/template_types.dart';
import 'number_input.dart';

class SizeControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const SizeControl({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumberInput(
          label: 'Width',
          value: element.box.widthPercent,
          onChanged: (value) {
            element.box.widthPercent = value;
            onUpdate();
          },
          min: 1,
          max: 100 - element.box.xPercent,
          suffix: '%',
        ),
        NumberInput(
          label: 'Height',
          value: element.box.heightPercent,
          onChanged: (value) {
            element.box.heightPercent = value;
            onUpdate();
          },
          min: 1,
          max: 100 - element.box.yPercent,
          suffix: '%',
        ),
      ],
    );
  }
}

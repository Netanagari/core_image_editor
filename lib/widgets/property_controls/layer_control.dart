import 'package:flutter/material.dart';
import '../../models/template_types.dart';
import 'number_input.dart';

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
    return NumberInput(
      label: 'Z-Index',
      value: element.zIndex.toDouble(),
      onChanged: (value) {
        element.zIndex = value.toInt();
        onUpdate();
      },
      min: 0,
      max: 999,
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/template_types.dart';

class OpacityControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const OpacityControl({
    Key? key,
    required this.element,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opacity: ${(element.style.opacity * 100).toInt()}%'),
          Slider(
            value: element.style.opacity,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            onChanged: (value) {
              element.style.opacity = value;
              onUpdate();
            },
          ),
        ],
      ),
    );
  }
}
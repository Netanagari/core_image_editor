import 'package:flutter/material.dart';
import '../../models/template_types.dart';

class LineHeightControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const LineHeightControl({
    Key? key,
    required this.element,
    required this.onUpdate,
  }) : super(key: key);

  void _adjustLineHeight(double delta) {
    final newValue = (element.style.lineHeight + delta).clamp(0.8, 2.0);
    if (newValue != element.style.lineHeight) {
      element.style.lineHeight = newValue;
      onUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Line Height'),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _adjustLineHeight(-0.05),
                tooltip: 'Decrease line height',
              ),
              Expanded(
                child: Slider(
                  value: element.style.lineHeight,
                  min: 0.8,
                  max: 2.0,
                  divisions: 24,
                  label: element.style.lineHeight.toStringAsFixed(2),
                  onChanged: (double value) {
                    element.style.lineHeight = value;
                    onUpdate();
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _adjustLineHeight(0.05),
                tooltip: 'Increase line height',
              ),
              SizedBox(
                width: 40,
                child: Text(
                  element.style.lineHeight.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

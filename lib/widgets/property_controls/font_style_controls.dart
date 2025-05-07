import 'package:flutter/material.dart';
import '../../models/template_types.dart';
import '../../utils/text_measurement.dart';

class FontStyleControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const FontStyleControl({
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
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Italic'),
                  value: element.style.isItalic,
                  onChanged: (bool? value) {
                    element.style.isItalic = value ?? false;
                    TextMeasurement.adjustBoxHeightForAllLanguages(
                      element: element,
                      viewportSize: MediaQuery.of(context).size,
                      context: context,
                    );
                    onUpdate();
                  },
                  dense: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Underline'),
                  value: element.style.isUnderlined,
                  onChanged: (bool? value) {
                    element.style.isUnderlined = value ?? false;
                    TextMeasurement.adjustBoxHeightForAllLanguages(
                      element: element,
                      viewportSize: MediaQuery.of(context).size,
                      context: context,
                    );
                    onUpdate();
                  },
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FontWeightControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const FontWeightControl({
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
          const Text('Font Weight'),
          const SizedBox(height: 4),
          DropdownButtonFormField<FontWeight>(
            value: element.style.fontWeight,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: FontWeight.w100,
                child: Text(
                  'Thin (100)',
                  style: TextStyle(fontWeight: FontWeight.w100),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w200,
                child: Text(
                  'Extra-Light (200)',
                  style: TextStyle(fontWeight: FontWeight.w200),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w300,
                child: Text(
                  'Light (300)',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w400,
                child: Text(
                  'Regular (400)',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w500,
                child: Text(
                  'Medium (500)',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w600,
                child: Text(
                  'Semi-Bold (600)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w700,
                child: Text(
                  'Bold (700)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w800,
                child: Text(
                  'Extra-Bold (800)',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w900,
                child: Text(
                  'Black (900)',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
            onChanged: (FontWeight? newValue) {
              if (newValue != null) {
                element.style.fontWeight = newValue;
                TextMeasurement.adjustBoxHeightForAllLanguages(
                  element: element,
                  viewportSize: MediaQuery.of(context).size,
                  context: context,
                );
                onUpdate();
              }
            },
          ),
        ],
      ),
    );
  }
}

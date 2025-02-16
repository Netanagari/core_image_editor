import 'package:flutter/material.dart';
import '../../models/template_types.dart';

class TagSelector extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const TagSelector({
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
          Text(
            'Element Tag',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<TemplateElementTag>(
            value: element.tag,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: TemplateElementTag.values.map((tag) {
              return DropdownMenuItem(
                value: tag,
                child: Tooltip(
                  message: tag.description,
                  child: Text(tag.displayName),
                ),
              );
            }).toList(),
            onChanged: (TemplateElementTag? newTag) {
              if (newTag != null) {
                element.tag = newTag;
                onUpdate();
              }
            },
          ),
        ],
      ),
    );
  }
}

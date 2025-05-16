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
    // Get valid tags for the element's group
    final validTags = TemplateElementTag.getValidTagsForGroup(element.group);

    // Filter out hidden tags
    final visibleTags = validTags
        .where((tag) => !TemplateElementTag.hiddenTags.contains(tag))
        .toList();

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
            value: TemplateElementTag.hiddenTags.contains(element.tag)
                ? (visibleTags.isNotEmpty ? visibleTags.first : element.tag)
                : element.tag,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: visibleTags.map((tag) {
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

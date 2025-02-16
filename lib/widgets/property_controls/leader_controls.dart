import 'package:flutter/material.dart';
import '../../models/template_types.dart';
import '../../models/editor_config.dart';
import 'leader_edit_dialog.dart';

class LeaderControls extends StatelessWidget {
  final TemplateElement element;
  final Future<String> Function(BuildContext) onSelectImage;
  final VoidCallback onUpdate;
  final EditorConfiguration configuration;

  const LeaderControls({
    super.key,
    required this.element,
    required this.onSelectImage,
    required this.onUpdate,
    required this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    List<TemplateElement> leaders = element.getLeaders();
    double spacing = element.content['spacing']?.toDouble() ?? 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Leader Photos'),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Add button
                    InkWell(
                      onTap: () async {
                        final url = await onSelectImage(context);
                        leaders.add(TemplateElement.createLeader(url));
                        element.setLeaders(leaders);
                        onUpdate();
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Icon(Icons.add_photo_alternate, size: 32),
                        ),
                      ),
                    ),
                    // Leader thumbnails
                    ...leaders.asMap().entries.map((entry) {
                      final index = entry.key;
                      final leader = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                leader.style.imageShape == 'circle' ? 40 : 8,
                              ),
                              child: Image.network(
                                leader.content['url'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (index > 0)
                                    IconButton(
                                      icon: const Icon(Icons.arrow_left,
                                          size: 16),
                                      constraints: const BoxConstraints(
                                        minWidth: 24,
                                        minHeight: 24,
                                      ),
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        final temp = leaders[index];
                                        leaders[index] = leaders[index - 1];
                                        leaders[index - 1] = temp;
                                        element.setLeaders(leaders);
                                        onUpdate();
                                      },
                                    ),
                                  if (index < leaders.length - 1)
                                    IconButton(
                                      icon: const Icon(Icons.arrow_right,
                                          size: 16),
                                      constraints: const BoxConstraints(
                                        minWidth: 24,
                                        minHeight: 24,
                                      ),
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        final temp = leaders[index];
                                        leaders[index] = leaders[index + 1];
                                        leaders[index + 1] = temp;
                                        element.setLeaders(leaders);
                                        onUpdate();
                                      },
                                    ),
                                  // Add Edit button
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 16),
                                    constraints: const BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => LeaderEditDialog(
                                          leader: leader,
                                          onSelectImage: onSelectImage,
                                          onUpdate: () {
                                            element.setLeaders(leaders);
                                            onUpdate();
                                          },
                                          configuration: configuration,
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    constraints: const BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      leaders.removeAt(index);
                                      element.setLeaders(leaders);
                                      onUpdate();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Spacing Control
        const Text('Spacing'),
        Slider(
          value: spacing,
          min: 0,
          max: 40,
          divisions: 8,
          label: '${spacing.round()}px',
          onChanged: (value) {
            element.content['spacing'] = value;
            onUpdate();
          },
        ),
      ],
    );
  }
}

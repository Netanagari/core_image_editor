import 'package:flutter/material.dart';
import '../../models/editor_config.dart';
import '../../models/template_types.dart';
import 'image_controls.dart';

class LeaderEditDialog extends StatelessWidget {
  final TemplateElement leader;
  final Future<String> Function(BuildContext) onSelectImage;
  final VoidCallback onUpdate;
  final EditorConfiguration configuration;

  const LeaderEditDialog({
    super.key,
    required this.leader,
    required this.onSelectImage,
    required this.onUpdate,
    required this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Leader Image',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: ImageControls(
                  element: leader,
                  onSelectImage: onSelectImage,
                  onUpdate: onUpdate,
                  configuration: configuration,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

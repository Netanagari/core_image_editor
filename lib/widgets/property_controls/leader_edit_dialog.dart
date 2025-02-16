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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        child: Container(
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
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ImageControls(
                      element: leader,
                      onSelectImage: onSelectImage,
                      onUpdate: onUpdate,
                      configuration: configuration,
                    ),
                  ),
                ),
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

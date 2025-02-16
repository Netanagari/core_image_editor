import 'package:flutter/material.dart';
import '../../models/template_types.dart';

class ReadOnlyControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const ReadOnlyControl({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CheckboxListTile(
        title: const Text('Read Only'),
        subtitle: const Text('Prevent editing by end users'),
        value: element.style.isReadOnly,
        onChanged: (value) {
          element.style.isReadOnly = value ?? false;
          onUpdate();
        },
      ),
    );
  }
}

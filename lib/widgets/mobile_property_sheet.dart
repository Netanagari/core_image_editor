import 'package:core_image_editor/models/editor_config.dart';
import 'package:core_image_editor/models/template_types.dart';
import 'package:core_image_editor/widgets/property_sidebar.dart';
import 'package:flutter/material.dart';

class MobilePropertySheet extends StatelessWidget {
  final TemplateElement element;
  final Size viewportSize;
  final VoidCallback onUpdate;
  final VoidCallback onClose;
  final EditorConfiguration configuration;
  final Future<String> Function(BuildContext) onSelectImage;
  final Function(TemplateElement) onDelete;

  const MobilePropertySheet({
    super.key,
    required this.element,
    required this.viewportSize,
    required this.onUpdate,
    required this.onClose,
    required this.onDelete,
    required this.configuration,
    required this.onSelectImage,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: PropertySidebar(
            element: element,
            configuration: configuration,
            viewportSize: viewportSize,
            onUpdate: onUpdate,
            onSelectImage: onSelectImage,
            onDelete: onDelete,
            onClose: onClose,
          ),
        );
      },
    );
  }
}

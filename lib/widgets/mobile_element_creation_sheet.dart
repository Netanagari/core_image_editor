import 'package:flutter/material.dart';
import 'package:core_image_editor/models/shape_types.dart';
import 'package:core_image_editor/models/template_types.dart';

class MobileElementCreationSheet extends StatelessWidget {
  final Function(TemplateElement) onCreateElement;
  final Future<String?> Function(BuildContext) onUploadImage;
  final Size viewportSize;

  const MobileElementCreationSheet({
    super.key,
    required this.viewportSize,
    required this.onCreateElement,
    required this.onUploadImage,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
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
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Add Elements',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildElementButton(
                context: context,
                icon: Icons.title,
                label: 'Heading',
                onTap: () => onCreateElement(_createTextElement(
                  text: 'New Heading',
                  fontSizeVw: 6.0,
                  type: 'heading',
                )),
              ),
              const SizedBox(height: 8),
              _buildElementButton(
                context: context,
                icon: Icons.text_fields,
                label: 'Body Text',
                onTap: () => onCreateElement(_createTextElement(
                  text: 'New Text Block',
                  fontSizeVw: 4.0,
                  type: 'body',
                )),
              ),
              const SizedBox(height: 16),
              Text(
                'Shapes',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ShapeType.values.map((shapeType) {
                  return _buildElementButton(
                    context: context,
                    icon: shapeType.icon,
                    label: shapeType.displayName,
                    onTap: () =>
                        onCreateElement(_createShapeElement(shapeType)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _buildElementButton(
                context: context,
                icon: Icons.image,
                label: 'Image',
                onTap: () async {
                  final url = await onUploadImage(context);
                  if (url != null) {
                    final element = _createImageElement();
                    element.content['url'] = url;
                    onCreateElement(element);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  TemplateElement _createShapeElement(ShapeType shapeType) {
    return TemplateElement(
      type: 'shape',
      box: TemplateBox(
        xPercent: 10,
        yPercent: 10,
        widthPercent: 20,
        heightPercent: shapeType == ShapeType.line ? 1 : 20,
        alignment: 'center',
      ),
      content: {
        'shapeType': shapeType.toString(),
        'fillColor':
            shapeType == ShapeType.curvedLine ? '#00000000' : '#FFFFFF',
        'strokeColor': '#000000',
        'strokeWidth': 2.0,
        'isStrokeDashed': false,
        'points': shapeType == ShapeType.curvedLine ? <double>[] : null,
        'curvature': shapeType == ShapeType.line ? 0.0 : null,
      },
      style: TemplateStyle(
        fontSizeVw: 0,
        color: '#000000',
      ),
    );
  }

  TemplateElement _createTextElement({
    required String text,
    required double fontSizeVw,
    required String type,
  }) {
    return TemplateElement(
      type: 'text',
      box: TemplateBox(
        xPercent: 10,
        yPercent: 10,
        widthPercent: 80,
        heightPercent: 10,
        alignment: 'center',
      ),
      content: {'text': text},
      style: TemplateStyle(
        fontSizeVw: fontSizeVw,
        color: '#000000',
      ),
    );
  }

  TemplateElement _createImageElement() {
    return TemplateElement(
      type: 'image',
      box: TemplateBox(
        xPercent: 10,
        yPercent: 10,
        widthPercent: 30,
        heightPercent: 30,
        alignment: 'center',
      ),
      content: {
        'url': 'https://via.placeholder.com/200x200',
      },
      style: TemplateStyle(
        fontSizeVw: 0,
        color: '#000000',
      ),
    );
  }

  Widget _buildElementButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

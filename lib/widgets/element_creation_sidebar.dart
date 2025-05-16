import 'package:core_image_editor/widgets/groups_manager.dart';
import 'package:flutter/material.dart';
import 'package:core_image_editor/models/shape_types.dart';
import '../models/template_types.dart';

class ElementCreationSidebar extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(TemplateElement) onCreateElement;
  final Future<String?> Function(BuildContext) onUploadImage;
  final Size viewportSize;

  const ElementCreationSidebar({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onCreateElement,
    required this.viewportSize,
    required this.onUploadImage,
  });

  TemplateElement _createTextElement({
    required String text,
    required double fontSizeVw,
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
      tag: TemplateElementTag.keyVisual,
      content: {
        'url': 'https://via.placeholder.com/200x200',
      },
      style: TemplateStyle(
        fontSizeVw: 0,
        color: '#000000',
      ),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 250 : 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 8),
            leading: isExpanded ? const Icon(Icons.add_box) : null,
            title: isExpanded ? const Text('Add Elements') : null,
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.chevron_left : Icons.chevron_right),
              onPressed: onToggle,
            ),
          ),
          const Divider(),
          if (isExpanded)
            DefaultTabController(
              length: 2,
              child: Expanded(
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'Elements', icon: Icon(Icons.widgets)),
                        Tab(text: 'Groups', icon: Icon(Icons.folder)),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Elements Tab
                          ListView(
                            padding: EdgeInsets.all(16),
                            children: [
                              if (isExpanded) ...[
                                Text(
                                  'Text',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                              ],
                              _buildElementButton(
                                context: context,
                                icon: Icons.title,
                                label: 'Text',
                                onTap: () => onCreateElement(_createTextElement(
                                  text: 'New text',
                                  fontSizeVw: 6.0,
                                )),
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Shapes',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                              ],
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ShapeType.values.map((shapeType) {
                                  return _buildElementButton(
                                    context: context,
                                    icon: shapeType.icon,
                                    label: shapeType.displayName,
                                    onTap: () => onCreateElement(
                                        _createShapeElement(shapeType)),
                                  );
                                }).toList(),
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Media Elements',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                              ],
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
                              const SizedBox(height: 8),
                              _buildElementButton(
                                context: context,
                                icon: Icons.people,
                                label: 'Leader Strip',
                                onTap: () => onCreateElement(
                                    TemplateElement.createLeaderStrip()),
                              ),
                            ],
                          ),
                          // Groups Tab
                          GroupsManager(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(isExpanded ? 16 : 8),
                children: [
                  if (isExpanded) ...[
                    Text(
                      'Text Elements',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                  ],
                  _buildElementButton(
                    context: context,
                    icon: Icons.title,
                    label: 'Heading',
                    onTap: () => onCreateElement(_createTextElement(
                      text: 'New Heading',
                      fontSizeVw: 6.0,
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
                    )),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Shapes',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                  ],
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
                  if (isExpanded) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Media Elements',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                  ],
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
                  const SizedBox(height: 8),
                  _buildElementButton(
                    context: context,
                    icon: Icons.people,
                    label: 'Leader Strip',
                    onTap: () =>
                        onCreateElement(TemplateElement.createLeaderStrip()),
                  ),
                ],
              ),
            ),
        ],
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
        padding: EdgeInsets.all(isExpanded ? 12 : 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}

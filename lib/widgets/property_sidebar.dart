import 'package:core_image_editor/extensions/color_extensions.dart';
import 'package:core_image_editor/models/editor_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:core_image_editor/models/shape_types.dart';
import 'package:core_image_editor/utils/text_measurement.dart';
import '../models/template_types.dart';

class PropertySidebar extends StatelessWidget {
  final TemplateElement element;
  final Size viewportSize;
  final VoidCallback onUpdate;
  final VoidCallback onClose;
  final Function(TemplateElement) onDelete;
  final Future<String> Function(BuildContext) onSelectImage;
  final EditorConfiguration configuration;

  const PropertySidebar({
    super.key,
    required this.element,
    required this.viewportSize,
    required this.onUpdate,
    required this.onDelete,
    required this.onClose,
    required this.configuration,
    required this.onSelectImage,
  });

  Widget _buildOpacityControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Opacity: ${(element.style.opacity * 100).toInt()}%'),
          Slider(
            value: element.style.opacity,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            onChanged: (value) {
              element.style.opacity = value;
              onUpdate();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageShapeControl() {
    if (element.type != 'image') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Image Shape'),
          const SizedBox(height: 4),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'rectangle',
                icon: Icon(Icons.rectangle_outlined),
                label: Text('Rectangle'),
              ),
              ButtonSegment(
                value: 'circle',
                icon: Icon(Icons.circle_outlined),
                label: Text('Circle'),
              ),
            ],
            selected: {element.style.imageShape ?? 'rectangle'},
            onSelectionChanged: (Set<String> newSelection) {
              element.style.imageShape = newSelection.first;
              onUpdate();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBoxShadowControl(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Box Shadow'),
          const SizedBox(height: 4),
          CheckboxListTile(
            title: const Text('Enable Shadow'),
            value: element.style.boxShadow != null,
            onChanged: (value) {
              if (value == true) {
                element.style.boxShadow = {
                  'color': '#000000',
                  'offsetX': 0.0,
                  'offsetY': 2.0,
                  'blurRadius': 4.0,
                  'spreadRadius': 0.0,
                };
              } else {
                element.style.boxShadow = null;
              }
              onUpdate();
            },
          ),
          if (element.style.boxShadow != null) ...[
            // Shadow Color
            InkWell(
              onTap: () async {
                await _showColorPicker(
                    context,
                    Color(
                      int.parse(
                        (element.style.boxShadow!['color'] ?? '#000000')
                            .replaceFirst('#', '0xff'),
                      ),
                    ), (color) {
                  element.style.boxShadow!['color'] = color;
                });
              },
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(
                      (element.style.boxShadow!['color'] ?? '#000000')
                          .replaceFirst('#', '0xff'),
                    ),
                  ),
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Shadow Offset X
            _buildNumberInput(
              label: 'Offset X',
              value: element.style.boxShadow!['offsetX'],
              onChanged: (value) {
                element.style.boxShadow!['offsetX'] = value;
                onUpdate();
              },
              min: -50,
              max: 50,
            ),
            // Shadow Offset Y
            _buildNumberInput(
              label: 'Offset Y',
              value: element.style.boxShadow!['offsetY'],
              onChanged: (value) {
                element.style.boxShadow!['offsetY'] = value;
                onUpdate();
              },
              min: -50,
              max: 50,
            ),
            // Blur Radius
            _buildNumberInput(
              label: 'Blur Radius',
              value: element.style.boxShadow!['blurRadius'],
              onChanged: (value) {
                element.style.boxShadow!['blurRadius'] = value;
                onUpdate();
              },
              min: 0,
              max: 50,
            ),
            // Spread Radius
            _buildNumberInput(
              label: 'Spread Radius',
              value: element.style.boxShadow!['spreadRadius'],
              onChanged: (value) {
                element.style.boxShadow!['spreadRadius'] = value;
                onUpdate();
              },
              min: -50,
              max: 50,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadOnlyControl() {
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

  Widget _buildImageFitSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Image Fit'),
          const SizedBox(height: 4),
          DropdownButtonFormField<BoxFit>(
            value: _parseBoxFit(element.content['imageFit'] ?? 'contain'),
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: BoxFit.contain,
                child: Row(
                  children: [
                    const Icon(Icons.fit_screen, size: 16),
                    const SizedBox(width: 8),
                    const Text('Contain - Fit Within'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: BoxFit.cover,
                child: Row(
                  children: [
                    const Icon(Icons.crop, size: 16),
                    const SizedBox(width: 8),
                    const Text('Cover - Fill & Crop'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: BoxFit.fill,
                child: Row(
                  children: [
                    const Icon(Icons.expand, size: 16),
                    const SizedBox(width: 8),
                    const Text('Fill - Stretch'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: BoxFit.fitWidth,
                child: Row(
                  children: [
                    const Icon(Icons.trending_flat, size: 16),
                    const SizedBox(width: 8),
                    const Text('Fit Width'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: BoxFit.fitHeight,
                child: Row(
                  children: [
                    const Icon(Icons.height, size: 16),
                    const SizedBox(width: 8),
                    const Text('Fit Height'),
                  ],
                ),
              ),
            ],
            onChanged: (BoxFit? newValue) {
              if (newValue != null) {
                element.style.imageFit = newValue;
                onUpdate();
              }
            },
          ),
        ],
      ),
    );
  }

  BoxFit _parseBoxFit(String value) {
    switch (value) {
      case 'BoxFit.contain':
        return BoxFit.contain;
      case 'BoxFit.cover':
        return BoxFit.cover;
      case 'BoxFit.fill':
        return BoxFit.fill;
      case 'BoxFit.fitWidth':
        return BoxFit.fitWidth;
      case 'BoxFit.fitHeight':
        return BoxFit.fitHeight;
      default:
        return BoxFit.contain;
    }
  }

  Widget _buildFontFamilySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Font Family'),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: element.style.fontFamily,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: configuration.availableFonts.map((String font) {
              return DropdownMenuItem<String>(
                value: font,
                child: Text(
                  font,
                  style: GoogleFonts.getFont(font),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                element.style.fontFamily = newValue;
                onUpdate();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildShapeStyleControls(BuildContext context) {
    // Get the shape type from content
    final shapeType = ShapeType.values.firstWhere(
      (type) => type.toString() == element.content['shapeType'],
      orElse: () => ShapeType.rectangle,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Shape Properties'),

        // Fill Color
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fill Color'),
              const SizedBox(height: 4),
              InkWell(
                onTap: () async {
                  await _showColorPicker(
                      context,
                      Color(
                        int.parse(
                          (element.content['fillColor'] ?? '#FFFFFF')
                              .replaceFirst('#', '0xff'),
                        ),
                      ), (color) {
                    element.content['fillColor'] = color;
                  });
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(
                        (element.content['fillColor'] ?? '#FFFFFF')
                            .replaceFirst('#', '0xff'),
                      ),
                    ),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Stroke Color
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Stroke Color'),
              const SizedBox(height: 4),
              InkWell(
                onTap: () async {
                  await _showColorPicker(
                      context,
                      Color(
                        int.parse(
                          (element.content['strokeColor'] ?? '#000000')
                              .replaceFirst('#', '0xff'),
                        ),
                      ), (color) {
                    element.content['strokeColor'] = color;
                  });
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(
                        (element.content['strokeColor'] ?? '#000000')
                            .replaceFirst('#', '0xff'),
                      ),
                    ),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Stroke Width
        _buildNumberInput(
          label: 'Stroke Width',
          value: element.content['strokeWidth']?.toDouble() ?? 2.0,
          onChanged: (value) {
            element.content['strokeWidth'] = value;
            onUpdate();
          },
          min: 0.5,
          max: 20,
        ),

        // Stroke Style (Dashed/Solid)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Dashed Stroke'),
                  value: element.content['isStrokeDashed'] ?? false,
                  onChanged: (value) {
                    element.content['isStrokeDashed'] = value;
                    onUpdate();
                  },
                  dense: true,
                ),
              ),
            ],
          ),
        ),

        // Shape-specific properties
        if (shapeType == ShapeType.star) ...[
          _buildNumberInput(
            label: 'Points',
            value: (element.content['points'] ?? 5).toDouble(),
            onChanged: (value) {
              element.content['points'] = value.toInt();
              onUpdate();
            },
            min: 3,
            max: 12,
          ),
          _buildNumberInput(
            label: 'Inner Radius Ratio',
            value: element.content['innerRadiusRatio']?.toDouble() ?? 0.4,
            onChanged: (value) {
              element.content['innerRadiusRatio'] = value;
              onUpdate();
            },
            min: 0.1,
            max: 0.9,
          ),
        ] else if (shapeType == ShapeType.pentagon ||
            shapeType == ShapeType.hexagon) ...[
          _buildNumberInput(
            label: 'Sides',
            value: (element.content['sides'] ??
                    (shapeType == ShapeType.pentagon
                        ? 5
                        : shapeType == ShapeType.hexagon
                            ? 6
                            : 3))
                .toDouble(),
            onChanged: (value) {
              element.content['sides'] = value.toInt();
              onUpdate();
            },
            min: 3,
            max: 12,
          ),
        ] else if (shapeType == ShapeType.arrow) ...[
          _buildNumberInput(
            label: 'Head Size',
            value: element.content['headSize']?.toDouble() ?? 0.3,
            onChanged: (value) {
              element.content['headSize'] = value;
              onUpdate();
            },
            min: 0.1,
            max: 0.5,
          ),
        ],
      ],
    );
  }

  Widget _buildNumberInput({
    required String label,
    required double value,
    required Function(double) onChanged,
    double? min,
    double? max,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label${suffix != null ? ' ($suffix)' : ''}'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: value.toStringAsFixed(2),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    double? newValue = double.tryParse(text);
                    if (newValue != null) {
                      if (min != null) {
                        newValue = newValue.clamp(min, max ?? double.infinity);
                      }
                      onChanged(newValue);
                      onUpdate();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  double newValue = value - 1;
                  if (min != null) {
                    newValue = newValue.clamp(min, max ?? double.infinity);
                  }
                  onChanged(newValue);
                  onUpdate();
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  double newValue = value + 1;
                  if (max != null) {
                    newValue =
                        newValue.clamp(min ?? double.negativeInfinity, max);
                  }
                  onChanged(newValue);
                  onUpdate();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'left',
                  icon: Icon(Icons.format_align_left),
                ),
                ButtonSegment(
                  value: 'center',
                  icon: Icon(Icons.format_align_center),
                ),
                ButtonSegment(
                  value: 'right',
                  icon: Icon(Icons.format_align_right),
                ),
              ],
              selected: {element.box.alignment},
              onSelectionChanged: (Set<String> newSelection) {
                element.box.alignment = newSelection.first;
                onUpdate();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPicker(
    BuildContext context,
    Color pickerColor,
    Function(String) onColorChosen,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add transparent color option
            InkWell(
              onTap: () {
                onColorChosen('#00000000');
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAGElEQVQYlWNgYGCQwoKxgqGgcJA5h3yFAAs8BRWVSwooAAAAAElFTkSuQmCC'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Transparent',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            BlockPicker(
              pickerColor: pickerColor,
              availableColors: [
                Colors.white,
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
                Colors.brown,
                Colors.grey,
                Colors.blueGrey,
                Colors.black,
              ],
              onColorChanged: (color) {
                onColorChosen(color.hexString);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    Function(String) onColorChosen,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Color'),
          const SizedBox(height: 4),
          InkWell(
            onTap: () async {
              await _showColorPicker(
                context,
                Color(
                  int.parse(element.style.color.replaceFirst('#', '0xff')),
                ),
                onColorChosen,
              );
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Color(
                  int.parse(element.style.color.replaceFirst('#', '0xff')),
                ),
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
                image: element.style.color == '#00000000'
                    ? const DecorationImage(
                        image: NetworkImage(
                            'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAGElEQVQYlWNgYGCQwoKxgqGgcJA5h3yFAAs8BRWVSwooAAAAAElFTkSuQmCC'),
                        repeat: ImageRepeat.repeat,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSelector(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Element Properties',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    if (configuration.can(EditorCapability.deleteElements))
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete(element),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        onClose();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle(context, 'Tag'),
                _buildTagSelector(context),

                _buildSectionTitle(context, 'Position & Size'),
                // repositionElements capability is required to show position controls
                if (configuration.can(EditorCapability.repositionElements)) ...[
                  _buildNumberInput(
                    label: 'X Position',
                    value: element.box.xPercent,
                    onChanged: (value) => element.box.xPercent = value,
                    min: 0,
                    max: 100 - element.box.widthPercent,
                    suffix: '%',
                  ),
                  _buildNumberInput(
                    label: 'Y Position',
                    value: element.box.yPercent,
                    onChanged: (value) => element.box.yPercent = value,
                    min: 0,
                    max: 100 - element.box.heightPercent,
                    suffix: '%',
                  ),
                ],
                //
                if (configuration.can(EditorCapability.resizeElements)) ...[
                  _buildNumberInput(
                    label: 'Width',
                    value: element.box.widthPercent,
                    onChanged: (value) => element.box.widthPercent = value,
                    min: 1,
                    max: 100 - element.box.xPercent,
                    suffix: '%',
                  ),
                  _buildNumberInput(
                    label: 'Height',
                    value: element.box.heightPercent,
                    onChanged: (value) => element.box.heightPercent = value,
                    min: 1,
                    max: 100 - element.box.yPercent,
                    suffix: '%',
                  ),
                ],
                //
                if (configuration.can(EditorCapability.rotateElements))
                  _buildNumberInput(
                    label: 'Rotation',
                    value: element.box.rotation,
                    onChanged: (value) => element.box.rotation = value % 360,
                    min: 0,
                    max: 360,
                    suffix: '°',
                  ),
                //

                if (configuration.can(EditorCapability.changeAlignment)) ...[
                  _buildSectionTitle(context, 'Alignment'),
                  _buildAlignmentSelector(),
                ],
                //

                if (configuration.can(EditorCapability.changeBorders)) ...[
                  _buildBorderControls(context),
                ],

                _buildOpacityControl(),
                _buildBoxShadowControl(context),
                _buildReadOnlyControl(),

                if (element.type == 'text') ...[
                  _buildTextStyleControls(context),
                ] else if (element.type == 'image') ...[
                  _buildSectionTitle(context, 'Image Properties'),
                  _buildImageShapeControl(),
                  _buildTextInput(
                    context,
                    'Image URL',
                    element.content['url'] ?? '',
                    (value) {
                      element.content['url'] = value;
                      onUpdate();
                    },
                  ),
                  if (configuration.can(EditorCapability.uploadNewImage))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: () async {
                          final newImageUrl = await onSelectImage(context);
                          element.content['url'] = newImageUrl;
                          onUpdate();
                        },
                        child: const Text('Change Image'),
                      ),
                    ),
                  _buildImageFitSelector(),
                ] else if (element.type == 'shape') ...[
                  _buildShapeStyleControls(context),
                ],
                _buildSectionTitle(context, 'Layer'),
                _buildNumberInput(
                  label: 'Z-Index',
                  value: element.zIndex.toDouble(),
                  onChanged: (value) {
                    element.zIndex = value.toInt();
                    onUpdate();
                  },
                  min: 0,
                  max: 999,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(
    BuildContext context,
    String label,
    String value,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (newValue) {
              // First update the text content
              element.content['text'] = newValue;

              // Auto-adjust height for text elements
              if (element.type == 'text') {
                TextMeasurement.adjustBoxHeight(
                  element: element,
                  newText: newValue,
                  viewportSize: viewportSize,
                  context: context,
                );
              }

              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFontWeightSelector(BuildContext context) {
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

                if (element.type == 'text') {
                  TextMeasurement.adjustBoxHeight(
                    element: element,
                    newText: element.content['text'] ?? '',
                    viewportSize: viewportSize,
                    context: context,
                  );
                }

                onUpdate();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextDecorations() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Text Style'),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Italic'),
                selected: element.style.isItalic,
                onSelected: (bool selected) {
                  element.style.isItalic = selected;
                  onUpdate();
                },
              ),
              FilterChip(
                label: const Text('Underline'),
                selected: element.style.isUnderlined,
                onSelected: (bool selected) {
                  element.style.isUnderlined = selected;
                  onUpdate();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBorderControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Border'),
        // Border Style Selector
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Border Style'),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: element.style.borderStyle ?? 'none',
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('None')),
                  DropdownMenuItem(value: 'solid', child: Text('Solid')),
                  DropdownMenuItem(value: 'dashed', child: Text('Dashed')),
                  DropdownMenuItem(value: 'dotted', child: Text('Dotted')),
                ],
                onChanged: (String? newValue) {
                  element.style.borderStyle = newValue;
                  if (newValue == 'none') {
                    element.style.borderWidth = 0;
                    element.style.borderColor = null;
                  } else {
                    element.style.borderWidth ??= 1;
                    element.style.borderColor ??= '#000000';
                  }

                  onUpdate();
                },
              ),
            ],
          ),
        ),

        // Only show these controls if a border style is selected
        if (element.style.borderStyle != null &&
            element.style.borderStyle != 'none') ...[
          // Border Width Control
          _buildNumberInput(
            label: 'Border Width',
            value: element.style.borderWidth ?? 1,
            onChanged: (value) {
              element.style.borderWidth = value;
              onUpdate();
            },
            min: 0.5,
            max: 20,
          ),

          // Border Radius Control
          _buildNumberInput(
            label: 'Border Radius',
            value: element.style.borderRadius ?? 1,
            onChanged: (value) {
              element.style.borderRadius = value;
              onUpdate();
            },
            min: 1,
            max: 100,
          ),

          // Border Color Control
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Border Color'),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    await _showColorPicker(
                        context,
                        Color(
                          int.parse(
                            (element.style.borderColor ?? '#000000')
                                .replaceFirst('#', '0xff'),
                          ),
                        ), (color) {
                      element.style.borderColor = color;
                    });
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          (element.style.borderColor ?? '#000000')
                              .replaceFirst('#', '0xff'),
                        ),
                      ),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextStyleControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Text Style'),
        if (configuration.can(EditorCapability.changeFonts))
          _buildFontFamilySelector(),
        _buildNumberInput(
          label: 'Font Size',
          value: element.style.fontSizeVw,
          onChanged: (value) => element.style.fontSizeVw = value,
          min: 0.1,
          max: 20,
          suffix: 'vw',
        ),
        if (configuration.can(EditorCapability.changeFonts))
          _buildFontWeightSelector(context),
        if (configuration.can(EditorCapability.changeFonts))
          _buildTextDecorations(),
        if (configuration.can(EditorCapability.changeColors))
          _buildColorPicker(context, (color) {
            element.style.color = color;
            onUpdate();
          }),
        if (configuration.can(EditorCapability.changeTextContent))
          _buildTextInput(
            context,
            'Text Content',
            element.content['text'] ?? '',
            (value) {
              element.content['text'] = value;
              onUpdate();
            },
          ),
      ],
    );
  }
}

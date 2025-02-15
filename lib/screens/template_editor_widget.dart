import 'dart:math';

import 'package:core_image_editor/models/editor_config.dart';
import 'package:core_image_editor/widgets/rotation_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:core_image_editor/models/shape_types.dart';
import 'package:core_image_editor/utils/text_measurement.dart';
import 'package:core_image_editor/widgets/dashed_border_painter.dart';
import 'package:core_image_editor/widgets/mobile_element_creation_sheet.dart';
import 'package:core_image_editor/widgets/mobile_property_sheet.dart';
import 'package:core_image_editor/widgets/resize_handle.dart';
import 'package:core_image_editor/widgets/responsive_builder.dart';
import 'package:core_image_editor/widgets/shape_painter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:widgets_to_image/widgets_to_image.dart';
import '../models/template_types.dart';
import '../utils/responsive_utils.dart';
import '../utils/history_manager.dart';
import '../widgets/element_creation_sidebar.dart';
import '../widgets/property_sidebar.dart';

class CoreImageEditor extends StatefulWidget {
  final Map<String, dynamic> template;
  final EditorConfiguration configuration;
  final Future<String> Function(BuildContext) onSelectImage;
  final Function(Map<String, dynamic>, Uint8List? canvasCapture) onSave;

  const CoreImageEditor({
    super.key,
    required this.onSave,
    required this.template,
    required this.configuration,
    required this.onSelectImage,
  });

  @override
  _CoreImageEditorState createState() => _CoreImageEditorState();
}

class _CoreImageEditorState extends State<CoreImageEditor> {
  late List<TemplateElement> elements;
  bool isCreationSidebarExpanded = true;
  TemplateElement? selectedElement;
  late final TransformationController transformationController;
  late final WidgetsToImageController controller;
  final GlobalKey _stackKey = GlobalKey();
  late double _canvasAspectRatio;
  late Size _viewportSize;
  bool _isRotating = false;
  final HistoryManager _historyManager = HistoryManager();

  @override
  void initState() {
    super.initState();
    html.document.onContextMenu.listen((event) => event.preventDefault());
    controller = WidgetsToImageController();
    transformationController = TransformationController();
    _canvasAspectRatio =
        widget.template['original_width'] / widget.template['original_height'];

    elements = (widget.template['content_json'] as List? ?? [])
        .map((e) => TemplateElement.fromJson(e))
        .toList();

    // Add initial state to history
    _pushHistory();

    // Add keyboard shortcuts
    _setupKeyboardShortcuts();
  }

  void _setupKeyboardShortcuts() {
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.isControlPressed || event.isMetaPressed) {
        if (event.logicalKey == LogicalKeyboardKey.keyZ) {
          if (event.isShiftPressed) {
            _handleRedo();
          } else {
            _handleUndo();
          }
        } else if (selectedElement != null && selectedElement!.type == 'text') {
          // Text styling shortcuts
          if (event.logicalKey == LogicalKeyboardKey.keyB) {
            setState(() {
              selectedElement!.style.fontWeight =
                  selectedElement!.style.fontWeight == FontWeight.bold
                      ? FontWeight.normal
                      : FontWeight.bold;
              _pushHistory();
            });
          } else if (event.logicalKey == LogicalKeyboardKey.keyI) {
            setState(() {
              selectedElement!.style.isItalic =
                  !selectedElement!.style.isItalic;
              _pushHistory();
            });
          } else if (event.logicalKey == LogicalKeyboardKey.keyU) {
            setState(() {
              selectedElement!.style.isUnderlined =
                  !selectedElement!.style.isUnderlined;
              _pushHistory();
            });
          }
        }
      } else if (event.logicalKey == LogicalKeyboardKey.delete ||
          event.logicalKey == LogicalKeyboardKey.backspace) {
        // Logic to delete selected element can be added here
      }
    }
  }

  void _pushHistory() {
    _historyManager.pushState(
      HistoryState.fromElements(elements, selectedElement),
    );
  }

  void _handleUndo() {
    final state = _historyManager.undo();
    if (state != null) {
      setState(() {
        elements = state.elements;
        selectedElement = state.selectedElement;
      });
    }
  }

  void _handleRedo() {
    final state = _historyManager.redo();
    if (state != null) {
      setState(() {
        elements = state.elements;
        selectedElement = state.selectedElement;
      });
    }
  }

  void _handleNewElement(TemplateElement element) {
    setState(() {
      elements.add(element);
      selectedElement = element;
      _pushHistory();
    });
  }

  void _handleDeleteElement(TemplateElement element) {
    setState(() {
      elements.remove(element);
      selectedElement = null;
      _pushHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          if (widget.configuration.can(EditorCapability.undoRedo)) ...[
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _historyManager.canUndo ? _handleUndo : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: _historyManager.canRedo ? _handleRedo : null,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _saveChanges,
          ),
        ],
      ),
      floatingActionButton: ResponsiveLayoutBuilder(
        builder: (context, isMobile) {
          if (!isMobile ||
              selectedElement != null ||
              !widget.configuration.can(EditorCapability.addElements)) {
            return const SizedBox();
          }
          return FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => MobileElementCreationSheet(
                  onUploadImage: widget.onSelectImage,
                  onCreateElement: (element) {
                    Navigator.pop(context);
                    _handleNewElement(element);
                  },
                  viewportSize: _viewportSize,
                ),
              );
            },
          );
        },
      ),
      body: ResponsiveLayoutBuilder(builder: (context, isMobile) {
        return LayoutBuilder(
          builder: (context, constraints) {
            _viewportSize = ResponsiveUtils.calculateViewportSize(
              constraints,
              _canvasAspectRatio,
            );

            if (isMobile) {
              return Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      transformationController: transformationController,
                      minScale: 0.1,
                      maxScale: 4.0,
                      constrained: false,
                      child: WidgetsToImage(
                        controller: controller,
                        child: SizedBox(
                          width: _viewportSize.width,
                          height: _viewportSize.height,
                          child: Stack(
                            key: _stackKey,
                            children: [
                              Image.network(
                                widget.template['base_image'],
                                width: _viewportSize.width,
                                height: _viewportSize.height,
                                fit: BoxFit.contain,
                              ),
                              ...(() {
                                final sortedElements =
                                    List<TemplateElement>.from(elements);
                                sortedElements.sort(
                                    (a, b) => a.zIndex.compareTo(b.zIndex));
                                return sortedElements.map(_buildBoxedElement);
                              })(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (selectedElement != null)
                    Positioned.fill(
                      child: MobilePropertySheet(
                        configuration: widget.configuration,
                        onSelectImage: widget.onSelectImage,
                        element: selectedElement!,
                        viewportSize: _viewportSize,
                        onClose: () => setState(() => selectedElement = null),
                        onUpdate: () => setState(() => _pushHistory()),
                        onDelete: widget.configuration
                                .can(EditorCapability.deleteElements)
                            ? _handleDeleteElement
                            : (_) {},
                      ),
                    ),
                ],
              );
            }

            return Row(
              children: [
                ElementCreationSidebar(
                  isExpanded: isCreationSidebarExpanded,
                  onCreateElement: _handleNewElement,
                  onUploadImage: widget.onSelectImage,
                  viewportSize: _viewportSize,
                  onToggle: () => setState(() {
                    isCreationSidebarExpanded = !isCreationSidebarExpanded;
                  }),
                ),
                Expanded(
                  child: Center(
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      transformationController: transformationController,
                      minScale: 0.1,
                      maxScale: 4.0,
                      constrained: false,
                      child: WidgetsToImage(
                        controller: controller,
                        child: SizedBox(
                          width: _viewportSize.width,
                          height: _viewportSize.height,
                          child: Stack(
                            key: _stackKey,
                            children: [
                              Image.network(
                                widget.template['base_image'],
                                width: _viewportSize.width,
                                height: _viewportSize.height,
                                fit: BoxFit.contain,
                              ),
                              ...(() {
                                final sortedElements =
                                    List<TemplateElement>.from(elements);
                                sortedElements.sort(
                                    (a, b) => a.zIndex.compareTo(b.zIndex));
                                return sortedElements.map(_buildBoxedElement);
                              })()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (selectedElement != null)
                  PropertySidebar(
                    configuration: widget.configuration,
                    onSelectImage: widget.onSelectImage,
                    element: selectedElement!,
                    viewportSize: _viewportSize,
                    onClose: () {
                      setState(() {
                        selectedElement = null;
                      });
                    },
                    onUpdate: () {
                      setState(() {
                        _pushHistory();
                      });
                    },
                    onDelete: widget.configuration
                            .can(EditorCapability.deleteElements)
                        ? _handleDeleteElement
                        : (_) {},
                  ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildBoxedElement(TemplateElement element) {
    bool isSelected = selectedElement == element;
    double x = ResponsiveUtils.percentToPixelX(
      element.box.xPercent,
      _viewportSize.width,
    );
    double y = ResponsiveUtils.percentToPixelY(
      element.box.yPercent,
      _viewportSize.height,
    );
    double width = ResponsiveUtils.percentToPixelX(
      element.box.widthPercent,
      _viewportSize.width,
    );
    double height = ResponsiveUtils.percentToPixelY(
      element.box.heightPercent,
      _viewportSize.height,
    );

    // Build border decoration based on style
    BoxDecoration? borderDecoration;
    if (element.style.borderStyle != null &&
        element.style.borderStyle != 'none') {
      BorderStyle borderStyle;
      switch (element.style.borderStyle) {
        case 'dashed':
          borderStyle = BorderStyle.none; // We'll use a custom dash pattern
          break;
        case 'dotted':
          borderStyle = BorderStyle.none; // We'll use a custom dash pattern
          break;
        default:
          borderStyle = BorderStyle.solid;
      }

      final borderColor = Color(
        int.parse(
            (element.style.borderColor ?? '#000000').replaceFirst('#', '0xff')),
      );

      borderDecoration = BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: element.style.borderWidth ?? 1,
          style: borderStyle,
        ),
        borderRadius: BorderRadius.circular(element.style.borderRadius ?? 1),
      );
    }

    Widget elementContent = Transform.rotate(
      angle: element.box.rotation * pi / 180,
      child: Container(
        width: width,
        height: height,
        decoration: borderDecoration?.copyWith(
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : borderDecoration.border,
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.5),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Align(
                alignment: element.box.alignment == 'center'
                    ? Alignment.center
                    : element.box.alignment == 'right'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                child: _buildElementContent(element, Size(width, height)),
              ),
            ),
          ],
        ),
      ),
    );

    // Apply dashed or dotted border if needed
    if (element.style.borderStyle == 'dashed' ||
        element.style.borderStyle == 'dotted') {
      elementContent = CustomPaint(
        painter: DashedBorderPainter(
          color: Color(
            int.parse((element.style.borderColor ?? '#000000')
                .replaceFirst('#', '0xff')),
          ),
          strokeWidth: element.style.borderWidth ?? 1,
          gap: element.style.borderStyle == 'dashed' ? 5.0 : 2.0,
        ),
        child: elementContent,
      );
    }

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => setState(() => selectedElement = element),
        onSecondaryTapDown: (details) {
          // Handle right-click
          setState(() => selectedElement = element);
          _showContextMenu(context, element, details.globalPosition);
        },
        onPanStart: (details) {
          setState(() => selectedElement = element);
        },
        onPanUpdate:
            widget.configuration.can(EditorCapability.repositionElements)
                ? (details) {
                    setState(() {
                      // Convert pixel delta to percentage delta
                      double deltaXPercent = ResponsiveUtils.pixelToPercentX(
                        details.delta.dx,
                        _viewportSize.width,
                      );
                      double deltaYPercent = ResponsiveUtils.pixelToPercentY(
                        details.delta.dy,
                        _viewportSize.height,
                      );

                      // Calculate new positions
                      double newX = element.box.xPercent + deltaXPercent;
                      double newY = element.box.yPercent + deltaYPercent;

                      // Apply bounds checking
                      newX = newX.clamp(0.0, 100.0 - element.box.widthPercent);
                      newY = newY.clamp(0.0, 100.0 - element.box.heightPercent);

                      // Update element position
                      element.box.xPercent = newX;
                      element.box.yPercent = newY;
                    });
                  }
                : null,
        onPanEnd: (details) {
          _pushHistory(); // Save state after drag
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            elementContent,
            if (!_isRotating &&
                isSelected &&
                widget.configuration.can(EditorCapability.resizeElements)) ...[
              ResizeHandle(
                position: HandlePosition.topLeft,
                element: element,
                viewportSize: _viewportSize,
                onUpdate: () => setState(() => _pushHistory()),
              ),
              ResizeHandle(
                position: HandlePosition.topRight,
                element: element,
                viewportSize: _viewportSize,
                onUpdate: () => setState(() => _pushHistory()),
              ),
              ResizeHandle(
                position: HandlePosition.bottomLeft,
                element: element,
                viewportSize: _viewportSize,
                onUpdate: () => setState(() => _pushHistory()),
              ),
              ResizeHandle(
                position: HandlePosition.bottomRight,
                element: element,
                viewportSize: _viewportSize,
                onUpdate: () => setState(() => _pushHistory()),
              ),
            ],

            // Rotation handle
            if (isSelected &&
                widget.configuration.can(EditorCapability.rotateElements))
              RotationHandle(
                element: element,
                viewportSize: _viewportSize,
                onRotationStart: () => setState(() => _isRotating = true),
                onRotationEnd: () => setState(() {
                  _isRotating = false;
                  _pushHistory();
                }),
                onUpdate: () => setState(() => _pushHistory()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementContent(TemplateElement element, Size elementSize) {
    if (element.type == 'leader_strip') {
    final leaders = element.getLeaders();
    
    if (leaders.isEmpty) {
      return const Center(
        child: Text('Add leaders to the strip'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = constraints.maxHeight;
        final spacing = 8.0;
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: leaders.map((leader) {
              return Padding(
                padding: EdgeInsets.only(
                  right: leader != leaders.last ? spacing : 0,
                ),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: _buildElementContent(leader, Size(imageSize, imageSize)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
  
    // Create the base content widget
    Widget content;

    if (element.type == 'shape') {
      content = CustomPaint(
        painter: ShapePainter(
          shapeType: ShapeType.values.firstWhere(
            (type) => type.toString() == element.content['shapeType'],
          ),
          fillColor: Color(
            int.parse(
              (element.content['fillColor'] ?? '#FFFFFF')
                  .replaceFirst('#', '0xff'),
            ),
          ),
          strokeColor: Color(
            int.parse(
              (element.content['strokeColor'] ?? '#000000')
                  .replaceFirst('#', '0xff'),
            ),
          ),
          strokeWidth: element.content['strokeWidth']?.toDouble() ?? 2.0,
          isStrokeDashed: element.content['isStrokeDashed'] ?? false,
        ),
        size: elementSize,
      );
    } else if (element.type == 'image') {
      Widget imageWidget = Image.network(
        element.content['url'] ?? '',
        width: elementSize.width,
        height: elementSize.height,
        fit: element.style.imageFit,
      );

      // Apply image shape clipping if specified
      if (element.style.imageShape == 'circle') {
        content = ClipOval(child: imageWidget);
      } else {
        content = ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: imageWidget,
        );
      }
    } else {
      // Text elements
      // Convert font size from vw to pixels
      double fontSizePixels = ResponsiveUtils.vwToPixels(
        element.style.fontSizeVw,
        _viewportSize.width,
      );

      // Apply text decorations
      List<TextDecoration> decorations = [];
      if (element.style.isUnderlined) {
        decorations.add(TextDecoration.underline);
      }

      content = Text(
        element.content['text'] ?? 'Default Text',
        style: GoogleFonts.getFont(
          element.style.fontFamily,
          fontSize: fontSizePixels,
          color:
              Color(int.parse(element.style.color.replaceFirst('#', '0xff'))),
          fontWeight: element.style.fontWeight,
          fontStyle:
              element.style.isItalic ? FontStyle.italic : FontStyle.normal,
          decoration:
              decorations.isEmpty ? null : TextDecoration.combine(decorations),
        ),
      );
    }

    // Apply opacity
    if (element.style.opacity != 1.0) {
      content = Opacity(
        opacity: element.style.opacity,
        child: content,
      );
    }

    // Apply box shadow if specified
    if (element.style.boxShadow != null) {
      content = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(
                int.parse(
                  (element.style.boxShadow!['color'] ?? '#000000')
                      .replaceFirst('#', '0xff'),
                ),
              ),
              offset: Offset(
                element.style.boxShadow!['offsetX']?.toDouble() ?? 0.0,
                element.style.boxShadow!['offsetY']?.toDouble() ?? 2.0,
              ),
              blurRadius:
                  element.style.boxShadow!['blurRadius']?.toDouble() ?? 4.0,
              spreadRadius:
                  element.style.boxShadow!['spreadRadius']?.toDouble() ?? 0.0,
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }

  void _showContextMenu(
    BuildContext context,
    TemplateElement element,
    Offset position,
  ) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect positionRect = RelativeRect.fromRect(
      Rect.fromPoints(position, position),
      Offset.zero & overlay.size,
    );

    await showMenu<dynamic>(
      context: context,
      position: positionRect,
      items: [
        if (element.type == 'text' &&
            widget.configuration.can(EditorCapability.changeFonts)) ...[
          PopupMenuItem(
            child: StatefulBuilder(
              builder: (context, setState) => CheckboxListTile(
                title: const Text('Bold'),
                value: element.style.fontWeight == FontWeight.bold,
                onChanged: (bool? value) {
                  element.style.fontWeight =
                      value == true ? FontWeight.bold : FontWeight.normal;

                  TextMeasurement.adjustBoxHeight(
                    element: element,
                    newText: element.content['text'] ?? '',
                    viewportSize: _viewportSize,
                    context: context,
                  );

                  _pushHistory();
                  Navigator.pop(context);
                },
                dense: true,
              ),
            ),
          ),
          PopupMenuItem(
            child: StatefulBuilder(
              builder: (context, setState) => CheckboxListTile(
                title: const Text('Italic'),
                value: element.style.isItalic,
                onChanged: (bool? value) {
                  element.style.isItalic = value ?? false;

                  TextMeasurement.adjustBoxHeight(
                    element: element,
                    newText: element.content['text'] ?? '',
                    viewportSize: _viewportSize,
                    context: context,
                  );

                  _pushHistory();
                  Navigator.pop(context);
                },
                dense: true,
              ),
            ),
          ),
          PopupMenuItem(
            child: StatefulBuilder(
              builder: (context, setState) => CheckboxListTile(
                title: const Text('Underline'),
                value: element.style.isUnderlined,
                onChanged: (bool? value) {
                  element.style.isUnderlined = value ?? false;

                  TextMeasurement.adjustBoxHeight(
                    element: element,
                    newText: element.content['text'] ?? '',
                    viewportSize: _viewportSize,
                    context: context,
                  );

                  _pushHistory();
                  Navigator.pop(context);
                },
                dense: true,
              ),
            ),
          ),
          const PopupMenuDivider(),
        ],
        if (widget.configuration.can(EditorCapability.changeBorders))
          PopupMenuItem(
            child: ListTile(
              title: const Text('Add Border'),
              trailing: const Icon(Icons.border_style),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                _showBorderDialog(context, element);
              },
            ),
          ),
        if (widget.configuration.can(EditorCapability.changeZIndex))
          PopupMenuItem(
            child: ListTile(
              title: const Text('Bring to Front'),
              trailing: const Icon(Icons.flip_to_front),
              dense: true,
              onTap: () {
                setState(() {
                  // Find the highest z-index
                  int maxZ = elements.fold(
                    0,
                    (max, e) => e.zIndex > max ? e.zIndex : max,
                  );
                  element.zIndex = maxZ + 1;
                  _pushHistory();
                });
                Navigator.pop(context);
              },
            ),
          ),
        if (widget.configuration.can(EditorCapability.changeZIndex))
          PopupMenuItem(
            child: ListTile(
              title: const Text('Send to Back'),
              trailing: const Icon(Icons.flip_to_back),
              dense: true,
              onTap: () {
                setState(() {
                  // Find the lowest z-index
                  int minZ = elements.fold(
                    0,
                    (min, e) => e.zIndex < min ? e.zIndex : min,
                  );
                  element.zIndex = minZ - 1;
                  _pushHistory();
                });
                Navigator.pop(context);
              },
            ),
          ),
        const PopupMenuDivider(),
        if (widget.configuration.can(EditorCapability.deleteElements))
          PopupMenuItem(
            child: ListTile(
              title: const Text('Delete'),
              trailing: const Icon(Icons.delete, color: Colors.red),
              dense: true,
              onTap: () {
                Navigator.pop(context);
                _handleDeleteElement(element);
              },
            ),
          ),
      ],
    ).whenComplete(() {
      setState(() {});
    });
  }

  void _showBorderDialog(BuildContext context, TemplateElement element) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Border Style'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: element.style.borderStyle ?? 'none',
                decoration: const InputDecoration(labelText: 'Style'),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('None')),
                  DropdownMenuItem(value: 'solid', child: Text('Solid')),
                  DropdownMenuItem(value: 'dashed', child: Text('Dashed')),
                  DropdownMenuItem(value: 'dotted', child: Text('Dotted')),
                ],
                onChanged: (value) {
                  setState(() {
                    element.style.borderStyle = value;
                    if (value == 'none') {
                      element.style.borderWidth = 0;
                      element.style.borderColor = null;
                    } else {
                      element.style.borderWidth ??= 1;
                      element.style.borderColor ??= '#000000';
                    }
                  });
                },
              ),
              if (element.style.borderStyle != null &&
                  element.style.borderStyle != 'none') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue:
                            (element.style.borderWidth ?? 1).toString(),
                        decoration: const InputDecoration(labelText: 'Width'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            element.style.borderWidth =
                                double.tryParse(value) ?? 1;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Border Color'),
                            content: BlockPicker(
                              pickerColor: Color(
                                int.parse(
                                  (element.style.borderColor ?? '#000000')
                                      .replaceFirst('#', '0xff'),
                                ),
                              ),
                              onColorChanged: (color) {
                                setState(() {
                                  element.style.borderColor =
                                      '#${color.value.toRadixString(16).substring(2)}';
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
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
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _pushHistory();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    ).whenComplete(() {
      setState(() {});
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      selectedElement = null;
    });

    await Future.delayed(Duration(milliseconds: 300));

    final original = widget.template;
    original['edited_content'] = elements.map((e) => e.toJson()).toList();
    original['viewport'] = {
      'width': _viewportSize.width,
      'height': _viewportSize.height,
    };

    final imgBytes = await controller.capture(
      pixelRatio: widget.configuration.pixelRatio,
    );

    await widget.onSave(original, imgBytes);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    transformationController.dispose();
    super.dispose();
  }
}

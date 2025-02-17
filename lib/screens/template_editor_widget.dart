import 'package:core_image_editor/widgets/editor_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../models/editor_config.dart';
import '../models/template_types.dart';
import '../state/editor_state.dart';
import '../state/history_state.dart';
import '../utils/responsive_utils.dart';
import '../widgets/element_creation_sidebar.dart';
import '../widgets/mobile_element_creation_sheet.dart';
import '../widgets/mobile_property_sheet.dart';
import '../widgets/property_sidebar.dart';
import '../widgets/responsive_builder.dart';

class CoreImageEditor extends StatelessWidget {
  final Map<String, dynamic> template;
  final EditorConfiguration configuration;
  final Future<String> Function(BuildContext) onSelectImage;
  final Function(Map<String, dynamic>, Uint8List? canvasCapture) onSave;

  const CoreImageEditor({
    super.key,
    required this.template,
    required this.configuration,
    required this.onSelectImage,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => EditorState(
            initialElements: (template['content_json'] as List? ?? [])
                .map((e) => TemplateElement.fromJson(e))
                .toList(),
            configuration: configuration,
            canvasAspectRatio:
                template['original_width'] / template['original_height'],
            initialViewportSize: Size.zero,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HistoryState(),
        ),
      ],
      child: _CoreImageEditorContent(
        template: template,
        onSelectImage: onSelectImage,
        onSave: onSave,
      ),
    );
  }
}

class _CoreImageEditorContent extends StatefulWidget {
  final Map<String, dynamic> template;
  final Future<String> Function(BuildContext) onSelectImage;
  final Function(Map<String, dynamic>, Uint8List? canvasCapture) onSave;

  const _CoreImageEditorContent({
    required this.template,
    required this.onSelectImage,
    required this.onSave,
  });

  @override
  _CoreImageEditorContentState createState() => _CoreImageEditorContentState();
}

class _CoreImageEditorContentState extends State<_CoreImageEditorContent> {
  late final TransformationController transformationController;
  late final WidgetsToImageController controller;
  final GlobalKey _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = WidgetsToImageController();
    transformationController = TransformationController();
    _setupKeyboardShortcuts();
  }

  void _setupKeyboardShortcuts() {
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    final editorState = context.read<EditorState>();
    final historyState = context.read<HistoryState>();
    final selectedElement = editorState.selectedElement;

    if (event.isControlPressed || event.isMetaPressed) {
      if (event.logicalKey == LogicalKeyboardKey.keyZ) {
        if (event.isShiftPressed) {
          _handleRedo(context);
        } else {
          _handleUndo(context);
        }
      } else if (selectedElement != null && selectedElement.type == 'text') {
        if (event.logicalKey == LogicalKeyboardKey.keyB) {
          selectedElement.style.fontWeight =
              selectedElement.style.fontWeight == FontWeight.bold
                  ? FontWeight.normal
                  : FontWeight.bold;
          editorState.updateElement(selectedElement);
          historyState.pushState(editorState.elements, selectedElement);
        } else if (event.logicalKey == LogicalKeyboardKey.keyI) {
          selectedElement.style.isItalic = !selectedElement.style.isItalic;
          editorState.updateElement(selectedElement);
          historyState.pushState(editorState.elements, selectedElement);
        } else if (event.logicalKey == LogicalKeyboardKey.keyU) {
          selectedElement.style.isUnderlined =
              !selectedElement.style.isUnderlined;
          editorState.updateElement(selectedElement);
          historyState.pushState(editorState.elements, selectedElement);
        }
      }
    }
  }

  void _handleUndo(BuildContext context) {
    final historyState = context.read<HistoryState>();
    final editorState = context.read<EditorState>();

    final state = historyState.undo();
    if (state != null) {
      editorState.setElements(state.elements);
      editorState.setSelectedElement(state.selectedElement);
    }
  }

  void _handleRedo(BuildContext context) {
    final historyState = context.read<HistoryState>();
    final editorState = context.read<EditorState>();

    final state = historyState.redo();
    if (state != null) {
      editorState.setElements(state.elements);
      editorState.setSelectedElement(state.selectedElement);
    }
  }

  void _handleNewElement(BuildContext context, TemplateElement element) {
    final editorState = context.read<EditorState>();
    final historyState = context.read<HistoryState>();

    editorState.addElement(element);
    historyState.pushState(editorState.elements, element);
  }

  Future<void> _saveChanges(BuildContext context) async {
    final editorState = context.read<EditorState>();
    editorState.setSelectedElement(null);

    await Future.delayed(const Duration(milliseconds: 300));

    final original = widget.template;
    original['edited_content'] =
        editorState.elements.map((e) => e.toJson()).toList();
    original['viewport'] = {
      'width': editorState.viewportSize.width,
      'height': editorState.viewportSize.height,
    };

    final imgBytes = await controller.capture(
      pixelRatio: editorState.configuration.pixelRatio,
    );

    await widget.onSave(original, imgBytes);
  }

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final historyState = context.watch<HistoryState>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          if (editorState.configuration.can(EditorCapability.undoRedo)) ...[
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed:
                  historyState.canUndo ? () => _handleUndo(context) : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed:
                  historyState.canRedo ? () => _handleRedo(context) : null,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveChanges(context),
          ),
        ],
      ),
      floatingActionButton: ResponsiveLayoutBuilder(
        builder: (context, isMobile) {
          if (!isMobile ||
              editorState.selectedElement != null ||
              !editorState.configuration.can(EditorCapability.addElements)) {
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
                    _handleNewElement(context, element);
                  },
                  viewportSize: editorState.viewportSize,
                ),
              );
            },
          );
        },
      ),
      body: ResponsiveLayoutBuilder(
        builder: (context, isMobile) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final viewportSize = ResponsiveUtils.calculateViewportSize(
                constraints,
                editorState.canvasAspectRatio,
              );

              if (viewportSize != editorState.viewportSize) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  editorState.setViewportSize(viewportSize);
                });
              }

              if (isMobile) {
                return _buildMobileLayout(context, viewportSize);
              }
              return _buildDesktopLayout(context, viewportSize);
            },
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, Size viewportSize) {
    final editorState = context.watch<EditorState>();

    return Stack(
      children: [
        Center(
          child: _buildCanvas(context, viewportSize),
        ),
        if (editorState.selectedElement != null)
          Positioned.fill(
            child: MobilePropertySheet(
              configuration: editorState.configuration,
              onSelectImage: widget.onSelectImage,
              element: editorState.selectedElement!,
              viewportSize: viewportSize,
              onClose: () => editorState.setSelectedElement(null),
              onUpdate: () {
                final historyState = context.read<HistoryState>();
                historyState.pushState(
                  editorState.elements,
                  editorState.selectedElement,
                );
              },
              onDelete:
                  editorState.configuration.can(EditorCapability.deleteElements)
                      ? (element) {
                          editorState.removeElement(element);
                          final historyState = context.read<HistoryState>();
                          historyState.pushState(editorState.elements, null);
                        }
                      : (_) {},
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Size viewportSize) {
    final editorState = context.watch<EditorState>();

    return Row(
      children: [
        ElementCreationSidebar(
          isExpanded: editorState.isCreationSidebarExpanded,
          onCreateElement: (element) => _handleNewElement(context, element),
          onUploadImage: widget.onSelectImage,
          viewportSize: viewportSize,
          onToggle: () => editorState.toggleCreationSidebar(),
        ),
        Expanded(
          child: Center(
            child: _buildCanvas(context, viewportSize),
          ),
        ),
        if (editorState.selectedElement != null)
          PropertySidebar(
            onSelectImage: widget.onSelectImage,
            onClose: () => editorState.setSelectedElement(null),
          ),
      ],
    );
  }

  Widget _buildCanvas(BuildContext context, Size viewportSize) {
    final editorState = context.watch<EditorState>();

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      transformationController: transformationController,
      minScale: 0.1,
      maxScale: 4.0,
      constrained: false,
      child: WidgetsToImage(
        controller: controller,
        child: SizedBox(
          width: viewportSize.width,
          height: viewportSize.height,
          child: Stack(
            key: _stackKey,
            children: [
              Image.network(
                widget.template['base_image_url'],
                width: viewportSize.width,
                height: viewportSize.height,
                fit: BoxFit.contain,
              ),
              ...(() {
                final sortedElements =
                    List<TemplateElement>.from(editorState.elements);
                sortedElements.sort((a, b) => a.zIndex.compareTo(b.zIndex));
                return sortedElements.map(
                  (element) => EditorElement(
                    key: ValueKey(element),
                    element: element,
                  ),
                );
              })(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    transformationController.dispose();
    super.dispose();
  }
}

import 'dart:io';

import 'package:core_image_editor/models/language_support.dart';
import 'package:core_image_editor/screens/mobile_textEdit_bottomsheet.dart';
import 'package:core_image_editor/screens/profile_editor_view.dart';
import 'package:core_image_editor/utils/app_color.dart';
import 'package:core_image_editor/utils/app_text_style.dart';
import 'package:core_image_editor/widgets/editor_element.dart';
import 'package:core_image_editor/widgets/language_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../models/editor_config.dart';
import '../models/template_types.dart';
import '../state/editor_state.dart';
import '../state/history_state.dart';
import '../utils/responsive_utils.dart';
import '../widgets/element_creation_sidebar.dart';
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
          create: (context) => LanguageManager(),
        ),
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
  int selectedIndex = 0;
  bool isBottomSheetVisible = false;

  // A list of the screens

  // Method to handle index change
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = WidgetsToImageController();
    transformationController = TransformationController();
    _setupKeyboardShortcuts();
  }

  List<Widget> bottomContent = [
    MobileTextEditBottomSheet(),
    ImageDisplayScreen(),
    ProfileEditorScreen(),
    ProfileEditorScreen(),
  ];
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

    // Save the elements with proper multilingual content
    original['content_json'] =
        editorState.elements.map((e) => e.toJson()).toList();

    original['viewport'] = {
      'width': editorState.viewportSize.width,
      'height': editorState.viewportSize.height,
    };

    // Add language settings to the template
    final languageManager = context.read<LanguageManager>();
    original['language_settings'] = {
      'default_language': LanguageManager.defaultLanguageCode,
      'enabled_languages': languageManager.enabledLanguages,
      'current_language': languageManager.currentLanguage,
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
        backgroundColor: AppColors.bg100,
        title: Text(
          'Edit Poster',
          style: AppTextStyles.labelMdMedium
              .copyWith(color: AppColors.secondary100),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          const LanguageSwitcher(),
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
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primary100,
              border: Border(
                top: BorderSide(
                  color: AppColors.secondary100,
                  width: 0.75,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  isSelected: selectedIndex == 0,
                  icon: Icons.abc,
                  label: 'Text',
                  onTap: () => onItemTapped(0),
                ),
                _buildNavItem(
                  isSelected: selectedIndex == 1,
                  icon: Icons.image,
                  label: 'Image',
                  onTap: () => onItemTapped(1),
                ),
                _buildNavItem(
                  isSelected: selectedIndex == 2,
                  icon: Icons.plus_one,
                  label: 'Calendar',
                  onTap: () => onItemTapped(2),
                ),
                _buildNavItem(
                  isSelected: selectedIndex == 3,
                  icon: Icons.person,
                  label: 'You',
                  onTap: () => onItemTapped(3),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Container(
              child: bottomContent[selectedIndex],
            )),
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

    return Container(
      color: AppColors.bg100,
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(double.infinity),
        transformationController: transformationController,
        minScale: 0.1,
        maxScale: 4.0,
        constrained: false,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 24),
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
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required bool isSelected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary100 : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary100 : AppColors.secondary100,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: isSelected
                ? AppTextStyles.labelSmMedium.copyWith(
                    color: AppColors.secondary100,
                  )
                : AppTextStyles.labelSmRegular.copyWith(
                    color: AppColors.tertiary100,
                  ),
          ),
        ],
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

class MobileBottomContentArea extends StatefulWidget {
  const MobileBottomContentArea({super.key, required this.childrens});
  final List<Widget> childrens;

  @override
  State<MobileBottomContentArea> createState() =>
      _MobileBottomContentAreaState();
}

class _MobileBottomContentAreaState extends State<MobileBottomContentArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      child: Column(
        children: widget.childrens,
      ),
    );
  }
}

class ImageDisplayScreen extends StatefulWidget {
  const ImageDisplayScreen({super.key});

  @override
  State<ImageDisplayScreen> createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  // For handling the selected image
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool hasImage = false;

  // Function to pick image from gallery
  Future<void> _getImageFromGallery() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          hasImage = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _deleteImage() {
    setState(() {
      _image = null;
      hasImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.tertiary100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: hasImage && _image != null
                  ? Image.file(
                      _image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Error loading image',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons row - Wrapped with LayoutBuilder to handle overflow
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Delete button
              OutlinedButton.icon(
                onPressed: hasImage ? _deleteImage : null,
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.secondary100),
                label: Text('Delete',
                    style: AppTextStyles.labelSmMedium
                        .copyWith(color: AppColors.secondary100)),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                  side: const BorderSide(color: AppColors.secondary100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Upload button
              ElevatedButton.icon(
                onPressed: _getImageFromGallery,
                icon: const Icon(Icons.upload,
                    size: 18, color: AppColors.primary100),
                label: Text('Upload',
                    style: AppTextStyles.labelSmMedium
                        .copyWith(color: AppColors.primary100)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                  backgroundColor: AppColors.secondary100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

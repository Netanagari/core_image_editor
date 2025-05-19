import 'package:core_image_editor/models/editor_config.dart';
import 'package:core_image_editor/widgets/property_controls/font_size_controls.dart';
import 'package:core_image_editor/widgets/property_controls/group_selector.dart';
import 'package:core_image_editor/widgets/property_controls/nested_content_controls.dart';
import 'package:core_image_editor/widgets/property_controls/number_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template_types.dart';
import '../state/editor_state.dart';
import '../state/history_state.dart';
import '../widgets/property_controls/alignment_control.dart';
import '../widgets/property_controls/border_control.dart';
import '../widgets/property_controls/box_shadow_control.dart';
import '../widgets/property_controls/color_picker.dart';
import '../widgets/property_controls/font_controls.dart';
import '../widgets/property_controls/image_controls.dart';
import '../widgets/property_controls/layer_control.dart';
import '../widgets/property_controls/leader_controls.dart';
import '../widgets/property_controls/line_height_control.dart';
import '../widgets/property_controls/opacity_control.dart';
import '../widgets/property_controls/position_control.dart';
import '../widgets/property_controls/shape_controls.dart';
import '../widgets/property_controls/size_control.dart';
import '../widgets/property_controls/tag_selector.dart';
import '../widgets/property_controls/text_content_control.dart';
import '../widgets/property_controls/text_align_control.dart';
import '../widgets/property_controls/text_shadow_control.dart';

class PropertySidebar extends StatelessWidget {
  final Future<String> Function(BuildContext) onSelectImage;
  final VoidCallback onClose;

  const PropertySidebar({
    super.key,
    required this.onSelectImage,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final element = editorState.selectedElement;

    if (element == null) return const SizedBox.shrink();

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
          _buildHeader(context, element),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildControls(context, element),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TemplateElement element) {
    final editorState = context.read<EditorState>();

    return Container(
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
              if (editorState.configuration
                  .can(EditorCapability.deleteElements))
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    editorState.removeElement(element);
                    final historyState = context.read<HistoryState>();
                    historyState.pushState(editorState.elements, null);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, TemplateElement element) {
    final editorState = context.read<EditorState>();
    final historyState = context.read<HistoryState>();
    final originalWidth = editorState.originalWidthValue;
    final originalHeight = editorState.originalHeightValue;
    double currentHeightPercent = element.box.heightPercent;
    double currentWidthPercent = element.box.widthPercent;

    double currentHeightPx =
        element.box.heightPx ?? (currentHeightPercent / 100.0) * originalHeight;
    double currentWidthPx =
        element.box.widthPx ?? (currentWidthPercent / 100.0) * originalWidth;

    void pushHistory() {
      historyState.pushState(editorState.elements, element);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (element.type == 'leader_strip')
          LeaderControls(
            element: element,
            onSelectImage: onSelectImage,
            onUpdate: pushHistory,
            configuration: editorState.configuration,
          ),
        const SectionTitle(title: 'Tag'),
        TagSelector(
          element: element,
          onUpdate: pushHistory,
        ),
        const SectionTitle(title: 'Group'),
        GroupSelector(
          element: element,
          onUpdate: pushHistory,
          availableGroups: editorState.availableGroups,
        ),
        const SectionTitle(title: 'Position & Size'),
        if (editorState.configuration.can(EditorCapability.repositionElements))
          PositionControl(
            element: element,
            onUpdate: pushHistory,
          ),
        if (editorState.configuration.can(EditorCapability.resizeElements))
          SizeControl(
            element: element,
            onUpdate: pushHistory,
          ),
        // New: Pixel-based controls for position and size
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
              NumberInput(
                label: 'Width',
                value: currentWidthPx,
                onChanged: (value) {
                  element.box.widthPx = value;
                  pushHistory();
                },
                min: 0,
                max: originalWidth -
                    (element.box.widthPercent / 100.0 * originalWidth),
                suffix: 'px',
                decimalPlaces: 0,
              ),
              const SizedBox(height: 8),
              NumberInput(
                label: 'Height',
                value: currentHeightPx,
                onChanged: (value) {
                  element.box.heightPx = value;
                  pushHistory();
                },
                min: 0,
                max: originalHeight -
                    (element.box.heightPercent / 100.0 * originalHeight),
                suffix: 'px',
                decimalPlaces: 0,
              ),
            ],
          ),
        ),
        if (editorState.configuration
            .can(EditorCapability.changeAlignment)) ...[
          const SectionTitle(title: 'Alignment'),
          AlignmentControl(
            element: element,
            onUpdate: pushHistory,
          ),
        ],
        if (editorState.configuration.can(EditorCapability.changeBorders))
          BorderControl(
            element: element,
            onUpdate: pushHistory,
          ),
        OpacityControl(
          element: element,
          onUpdate: pushHistory,
        ),
        BoxShadowControl(
          element: element,
          onUpdate: pushHistory,
        ),
        if (element.type == 'text') ...[
          KeyedSubtree(
            key: ValueKey(element),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Text Style'),
                FontSizeControl(
                  element: element,
                  onUpdate: pushHistory,
                ),
                FontFamilyControl(
                  element: element,
                  availableFonts: editorState.configuration.availableFonts,
                  onUpdate: pushHistory,
                ),
                FontWeightControl(
                  element: element,
                  onUpdate: pushHistory,
                ),
                FontStyleControl(
                  element: element,
                  onUpdate: pushHistory,
                ),
                LineHeightControl(
                  element: element,
                  onUpdate: pushHistory,
                ),
                TextShadowControl(
                  element: element,
                  onUpdate: pushHistory,
                ),
              ],
            ),
          ),
          if (editorState.configuration.can(EditorCapability.changeColors))
            NColorPicker(
              label: 'Color',
              color: element.style.color,
              onColorChanged: (color) {
                element.style.color = color;
                pushHistory();
              },
            ),
          if (editorState.configuration.can(EditorCapability.changeAlignment))
            TextAlignControl(
              element: element,
              onUpdate: pushHistory,
            ),
          if (editorState.configuration.can(EditorCapability.changeTextContent))
            TextContentControl(
              element: element,
              viewportSize: editorState.viewportSize,
              onUpdate: pushHistory,
            ),
        ] else if (element.type == 'image') ...[
          const SectionTitle(title: 'Image Properties'),
          ImageControls(
            element: element,
            onSelectImage: onSelectImage,
            onUpdate: pushHistory,
            configuration: editorState.configuration,
          ),
        ] else if (element.type == 'shape') ...[
          ShapeControls(
            element: element,
            onUpdate: pushHistory,
          ),
          if (element.canContainNestedContent)
            NestedContentControls(
              element: element,
              onSelectImage: onSelectImage,
              onUpdate: pushHistory,
              configuration: editorState.configuration,
            ),
        ],
        const SectionTitle(title: 'Layer Order'),
        LayerControl(
          element: element,
          onUpdate: pushHistory,
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
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
}

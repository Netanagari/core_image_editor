import 'package:core_image_editor/models/editor_config.dart';
import 'package:core_image_editor/models/language_support.dart';
import 'package:core_image_editor/widgets/nested_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template_types.dart';
import '../models/shape_types.dart';
import '../state/editor_state.dart';
import '../state/history_state.dart';
import 'rotation_handle.dart';
import 'resize_handle.dart';

class EditorElement extends StatelessWidget {
  final TemplateElement element;

  const EditorElement({
    super.key,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final historyState = context.read<HistoryState>();
    final viewportSize = editorState.viewportSize;
    final isSelected = editorState.selectedElement == element;

    bool isRotating = false;

    // Use pixel values if provided, otherwise fallback to percent-based values
    final originalWidth = editorState.originalWidthValue;
    final originalHeight = editorState.originalHeightValue;
    double x = element.box.xPx != null
        ? (element.box.xPx! / originalWidth) * viewportSize.width
        : (element.box.xPercent * viewportSize.width / 100);
    double y = element.box.yPx != null
        ? (element.box.yPx! / originalHeight) * viewportSize.height
        : (element.box.yPercent * viewportSize.height / 100);
    double width = element.box.widthPx != null
        ? (element.box.widthPx! / originalWidth) * viewportSize.width
        : (element.box.widthPercent * viewportSize.width / 100);
    double height = element.box.heightPx != null
        ? (element.box.heightPx! / originalHeight) * viewportSize.height
        : (element.box.heightPercent * viewportSize.height / 100);

    // Build border decoration based on style
    BoxDecoration? borderDecoration;
    if (element.style.borderStyle != null &&
        element.style.borderStyle != 'none') {
      BorderStyle borderStyle;
      switch (element.style.borderStyle) {
        case 'dashed':
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
      angle: element.box.rotation * 3.14159 / 180,
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
                child:
                    _buildElementContent(context, element, Size(width, height)),
              ),
            ),
            // LanguageIndicator(element: element),
          ],
        ),
      ),
    );

    void pushHistory() {
      historyState.pushState(editorState.elements, element);
    }

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => editorState.setSelectedElement(element),
        onSecondaryTapDown: (details) {
          editorState.setSelectedElement(element);
          // Add context menu if needed
        },
        onPanStart: (details) {
          editorState.setSelectedElement(element);
        },
        onPanUpdate:
            editorState.configuration.can(EditorCapability.repositionElements)
                ? (details) {
                    double deltaXPercent =
                        details.delta.dx / viewportSize.width * 100;
                    double deltaYPercent =
                        details.delta.dy / viewportSize.height * 100;

                    double newX = element.box.xPercent + deltaXPercent;
                    double newY = element.box.yPercent + deltaYPercent;

                    newX = newX.clamp(0.0, 100.0 - element.box.widthPercent);
                    newY = newY.clamp(0.0, 100.0 - element.box.heightPercent);

                    element.box.xPercent = newX;
                    element.box.yPercent = newY;

                    // Always update xPx/yPx based on the new percentage values
                    element.box.xPx = (newX / 100.0) * originalWidth;
                    element.box.yPx = (newY / 100.0) * originalHeight;

                    // Width and height percentages (and their corresponding pixel values)
                    // do not change during a pan/drag operation, so no need to update them here.
                    // However, if they were null, they should be initialized based on current percentages
                    // to ensure the JSON output is complete.
                    // This is more robustly handled by ResizeHandle for size changes
                    // and by the property controls when values are manually entered.
                    // For consistency, let's ensure they are at least calculated if null,
                    // but primary updates for size are via ResizeHandle.
                    if (element.box.widthPx == null && originalWidth > 0) {
                      element.box.widthPx =
                          (element.box.widthPercent / 100.0) * originalWidth;
                    }
                    if (element.box.heightPx == null && originalHeight > 0) {
                      element.box.heightPx =
                          (element.box.heightPercent / 100.0) * originalHeight;
                    }

                    editorState.updateElement(element);
                  }
                : null,
        onPanEnd: (details) => pushHistory(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            elementContent,
            if (!isRotating &&
                isSelected &&
                editorState.configuration
                    .can(EditorCapability.resizeElements)) ...[
              ResizeHandle(
                position: HandlePosition.topLeft,
                element: element,
                viewportSize: viewportSize,
                onUpdate: pushHistory,
              ),
              ResizeHandle(
                position: HandlePosition.topRight,
                element: element,
                viewportSize: viewportSize,
                onUpdate: pushHistory,
              ),
              ResizeHandle(
                position: HandlePosition.bottomLeft,
                element: element,
                viewportSize: viewportSize,
                onUpdate: pushHistory,
              ),
              ResizeHandle(
                position: HandlePosition.bottomRight,
                element: element,
                viewportSize: viewportSize,
                onUpdate: pushHistory,
              ),
            ],
            if (isSelected &&
                editorState.configuration.can(EditorCapability.rotateElements))
              RotationHandle(
                element: element,
                viewportSize: viewportSize,
                onRotationStart: () => isRotating = true,
                onRotationEnd: () {
                  isRotating = false;
                  pushHistory();
                },
                onUpdate: pushHistory,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementContent(
    BuildContext context,
    TemplateElement element,
    Size elementSize,
  ) {
    if (element.type == 'leader_strip') {
      return _buildLeaderStrip(element, elementSize);
    }

    Widget content;
    switch (element.type) {
      case 'shape':
        content = NestedContentWidget(
          element: element,
          elementSize: elementSize,
        );
        break;
      case 'image':
        Widget imageWidget = Image.network(
          element.content['url'] ?? '',
          width: elementSize.width,
          height: elementSize.height,
          fit: element.style.imageFit,
        );

        if (element.style.imageShape == 'circle') {
          content = ClipPath(
            clipper: ShapeClipper(
              shapeType: ShapeType.circle,
            ),
            child: imageWidget,
          );
        } else {
          content = ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: imageWidget,
          );
        }
        break;
      default:
        // Get the language manager from the context
        final languageManager =
            Provider.of<LanguageManager>(context, listen: true);
        final currentLanguage = languageManager.currentLanguage;
        final currentLanguageModel = languageManager.currentLanguageModel;

        final displayText = element.getTextContent(currentLanguage);
        double fontSizePixels =
            element.style.fontSizeVw * elementSize.width / 100;

        List<TextDecoration> decorations = [];
        if (element.style.isUnderlined) {
          decorations.add(TextDecoration.underline);
        }

        final textDirection = languageManager.isRtl(currentLanguage)
            ? TextDirection.rtl
            : TextDirection.ltr;

        content = Text(
          displayText,
          style: TextStyle(
            fontFamily: currentLanguageModel.fontFamily,
            package: 'core_image_editor',
            fontSize: fontSizePixels,
            color:
                Color(int.parse(element.style.color.replaceFirst('#', '0xff'))),
            fontWeight: element.style.fontWeight,
            fontStyle:
                element.style.isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: decorations.isEmpty
                ? null
                : TextDecoration.combine(decorations),
            height: element.style.lineHeight, // Apply line height from style
            shadows: element.style.textShadow != null
                ? [
                    Shadow(
                      color: Color(
                        int.parse(
                          (element.style.textShadow!['color'] ?? '#000000')
                              .replaceFirst('#', '0xff'),
                        ),
                      ),
                      offset: Offset(
                        element.style.textShadow!['offsetX']?.toDouble() ?? 0.0,
                        element.style.textShadow!['offsetY']?.toDouble() ?? 2.0,
                      ),
                      blurRadius:
                          element.style.textShadow!['blurRadius']?.toDouble() ??
                              4.0,
                    ),
                  ]
                : null,
          ),
          textDirection: textDirection,
          textAlign: _parseTextAlign(element.style.textAlign),
        );
        break;
    }

    if (element.style.opacity != 1.0) {
      content = Opacity(
        opacity: element.style.opacity,
        child: content,
      );
    }

    // Apply box shadow if specified
    if (element.style.boxShadow != null) {
      // Get shadow params
      final shadowColor = Color(
        int.parse((element.style.boxShadow!['color'] ?? '#000000')
            .replaceFirst('#', '0xff')),
      );
      final offsetX = element.style.boxShadow!['offsetX']?.toDouble() ?? 0.0;
      final offsetY = element.style.boxShadow!['offsetY']?.toDouble() ?? 2.0;
      final blurRadius =
          element.style.boxShadow!['blurRadius']?.toDouble() ?? 4.0;
      final spreadRadius =
          element.style.boxShadow!['spreadRadius']?.toDouble() ?? 0.0;

      // For shapes and circular images
      if (element.type == 'shape' ||
          (element.type == 'image' && element.style.imageShape == 'circle')) {
        final clipShape = element.type == 'shape'
            ? ShapeType.values.firstWhere(
                (type) => type.toString() == element.content['shapeType'],
                orElse: () => ShapeType.rectangle)
            : ShapeType.circle;

        content = Container(
          child: Stack(
            children: [
              // Shadow container
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: clipShape == ShapeType.circle
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        offset: Offset(offsetX, offsetY),
                        blurRadius: blurRadius,
                        spreadRadius: spreadRadius,
                      ),
                    ],
                  ),
                ),
              ),
              // Content with clip
              ClipPath(
                clipper: ShapeClipper(
                  shapeType: clipShape,
                  points: element.content['points'],
                  innerRadiusRatio: element.content['innerRadiusRatio'],
                ),
                child: content,
              ),
            ],
          ),
        );
      } else {
        // For regular elements, use standard BoxDecoration shadow
        content = Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: Offset(offsetX, offsetY),
                blurRadius: blurRadius,
                spreadRadius: spreadRadius,
              ),
            ],
          ),
          child: content,
        );
      }
    }

    return content;
  }

  // Widget _buildLeaderStrip(TemplateElement element, Size elementSize) {
  //   final leaders = element.getLeaders();
  //   final spacing = element.content['spacing']?.toDouble() ?? 8.0;

  //   if (leaders.isEmpty) {
  //     return const Center(
  //       child: Text(
  //         'Add leader photos',
  //         style: TextStyle(color: Colors.grey),
  //       ),
  //     );
  //   }

  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       final imageSize = elementSize.height;
  //       return Wrap(
  //         children: [
  //           for (int i = 0; i < leaders.length; i++) ...[
  //             ClipRRect(
  //               borderRadius: BorderRadius.circular(
  //                 leaders[i].style.imageShape == 'circle' ? imageSize / 2 : 0,
  //               ),
  //               child: SizedBox(
  //                 width: imageSize,
  //                 height: imageSize,
  //                 child: Image.network(
  //                   leaders[i].content['url'],
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //             ),
  //             if (i < leaders.length - 1) SizedBox(width: spacing),
  //           ],
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildLeaderStrip(TemplateElement element, Size elementSize) {
    final leaders = element.getLeaders();
    final horizontalSpacing = element.content['spacing']?.toDouble() ?? 8.0;
    final verticalSpacing =
        element.content['verticalSpacing']?.toDouble() ?? 8.0;
    final justifyContent = element.content['justifyContent'] ?? 'start';

    if (leaders.isEmpty) {
      return const Center(
        child: Text(
          'Add leader photos',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = elementSize.height;

        // Convert justifyContent to WrapAlignment
        WrapAlignment alignment;
        switch (justifyContent) {
          case 'center':
            alignment = WrapAlignment.center;
            break;
          case 'end':
            alignment = WrapAlignment.end;
            break;
          case 'space-between':
            alignment = WrapAlignment.spaceBetween;
            break;
          case 'space-around':
            alignment = WrapAlignment.spaceAround;
            break;
          case 'space-evenly':
            alignment = WrapAlignment.spaceEvenly;
            break;
          default:
            alignment = WrapAlignment.start;
        }

        return Container(
          // decoration: borderDecoration,
          padding: EdgeInsets.all((element.style.borderWidth ?? 0) + 4),
          child: Wrap(
            alignment: alignment,
            spacing: horizontalSpacing,
            runSpacing: verticalSpacing,
            children: leaders.map((leader) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(
                  leader.style.imageShape == 'circle' ? imageSize / 2 : 0,
                ),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Image.network(
                    leader.content['url'],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Helper to parse string to TextAlign
  TextAlign _parseTextAlign(String? align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }
}

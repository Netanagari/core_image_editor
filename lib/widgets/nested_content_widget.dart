import 'package:core_image_editor/models/language_support.dart';
import 'package:core_image_editor/models/shape_types.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template_types.dart';
import '../state/editor_state.dart';
import 'shape_painter.dart';
import 'curve_point_editor.dart';

class NestedContentWidget extends StatelessWidget {
  final TemplateElement element;
  final Size elementSize;

  const NestedContentWidget({
    super.key,
    required this.element,
    required this.elementSize,
  });

  @override
  Widget build(BuildContext context) {
    final shapeType = ShapeType.values.firstWhere(
      (type) => type.toString() == element.content['shapeType'],
      orElse: () => ShapeType.rectangle,
    );

    // Handle curved lines specially
    if (shapeType == ShapeType.curvedLine) {
      return Stack(
        children: [
          _buildShape(),
          Consumer<EditorState>(
            builder: (context, editorState, child) {
              if (editorState.selectedElement == element) {
                return CurvePointEditor(
                  element: element,
                  elementSize: elementSize,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      );
    }

    // Handle all other cases
    if (!element.canContainNestedContent ||
        element.nestedContent?.content == null) {
      return _buildShape();
    }

    return Stack(
      children: [
        _buildShape(),
        ClipPath(
          clipper: ShapeClipper(
            shapeType: ShapeType.values.firstWhere(
              (type) => type.toString() == element.content['shapeType'],
            ),
            points: element.content['points'] != null
                ? (element.content['points'] as List).cast<double>()
                : null,
            innerRadiusRatio: element.content['innerRadiusRatio'],
          ),
          child: Container(
            width: elementSize.width,
            height: elementSize.height,
            alignment: element.nestedContent!.contentAlignment,
            child: _buildNestedContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildShape() {
    return CustomPaint(
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
        curvature: element.content['curvature']?.toDouble(),
        strokeWidth: element.content['strokeWidth']?.toDouble() ?? 2.0,
        isStrokeDashed: element.content['isStrokeDashed'] ?? false,
        lineShadow: element.content['lineShadow'] != null
            ? LineShadow(
                color: Color(
                  int.parse(
                    (element.content['lineShadow']['color'] ?? '#000000')
                        .replaceFirst('#', '0xff'),
                  ),
                ),
                offsetX:
                    element.content['lineShadow']['offsetX']?.toDouble() ?? 0.0,
                offsetY:
                    element.content['lineShadow']['offsetY']?.toDouble() ?? 2.0,
                blurRadius:
                    element.content['lineShadow']['blurRadius']?.toDouble() ??
                        4.0,
                spreadRadius:
                    element.content['lineShadow']['spreadRadius']?.toDouble() ??
                        0.0,
              )
            : null,
      ),
      size: elementSize,
    );
  }

  Widget _buildNestedContent(BuildContext context) {
    final nestedElement = element.nestedContent!.content!;

    switch (nestedElement.type) {
      case 'image':
        return Image.network(
          nestedElement.content['url'] ?? '',
          width: elementSize.width,
          height: elementSize.height,
          fit: element.nestedContent!.contentFit,
        );

      case 'text':
        final languageManager =
            Provider.of<LanguageManager>(context, listen: false);
        final currentLanguage = languageManager.currentLanguageModel;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            fit: element.nestedContent!.contentFit,
            alignment: element.nestedContent!.contentAlignment,
            child: Text(
              nestedElement.content['text'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: currentLanguage.fontFamily,
                package: 'core_image_editor',
                fontSize:
                    nestedElement.style.fontSizeVw * elementSize.width / 100,
                color: Color(
                  int.parse(
                      nestedElement.style.color.replaceFirst('#', '0xff')),
                ),
                fontWeight: nestedElement.style.fontWeight,
                fontStyle: nestedElement.style.isItalic
                    ? FontStyle.italic
                    : FontStyle.normal,
                decoration: nestedElement.style.isUnderlined
                    ? TextDecoration.underline
                    : null,
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class ShapeClipper extends CustomClipper<Path> {
  final ShapeType shapeType;
  final List<double>? points;
  final double? innerRadiusRatio;

  ShapeClipper({
    required this.shapeType,
    this.points,
    this.innerRadiusRatio,
  });

  @override
  Path getClip(Size size) {
    final painter = ShapePainter(
      shapeType: shapeType,
      fillColor: Colors.transparent,
      strokeColor: Colors.transparent,
      points: points,
      innerRadiusRatio: innerRadiusRatio,
    );

    return painter.getClipPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    if (oldClipper is ShapeClipper) {
      return oldClipper.shapeType != shapeType ||
          oldClipper.points != points ||
          oldClipper.innerRadiusRatio != innerRadiusRatio;
    }
    return true;
  }
}

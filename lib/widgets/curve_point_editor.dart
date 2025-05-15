import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template_types.dart';
import '../state/editor_state.dart';
import '../state/history_state.dart';

class CurvePointEditor extends StatefulWidget {
  final TemplateElement element;
  final Size elementSize;

  const CurvePointEditor({
    super.key,
    required this.element,
    required this.elementSize,
  });

  @override
  State<CurvePointEditor> createState() => _CurvePointEditorState();
}

class _CurvePointEditorState extends State<CurvePointEditor> {
  int? activePointIndex;

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final historyState = context.read<HistoryState>();

    return GestureDetector(
      onTapDown: (details) {
        // Don't add point if we're too close to an existing point
        if (_isNearExistingPoint(details.localPosition)) {
          return;
        }

        // Convert tap position to relative coordinates (0-1)
        final xPercent = details.localPosition.dx / widget.elementSize.width;
        final yPercent = details.localPosition.dy / widget.elementSize.height;

        // Initialize points list if needed
        if (widget.element.content['points'] == null) {
          widget.element.content['points'] = <double>[];
        }

        // Add new point
        widget.element.content['points'].addAll([xPercent, yPercent]);

        editorState.updateElement(widget.element);
        historyState.pushState(editorState.elements, widget.element);
      },
      child: Stack(
        children: [
          // Draw curve preview
          if (widget.element.content['points'] != null)
            CustomPaint(
              size: widget.elementSize,
              painter: _CurvePreviewPainter(
                points: widget.element.content['points'],
                elementSize: widget.elementSize,
              ),
            ),
          // Draw existing points
          if (widget.element.content['points'] != null)
            ..._buildPointHandles(context),
        ],
      ),
    );
  }

  List<Widget> _buildPointHandles(BuildContext context) {
    final points = widget.element.content['points'] as List<dynamic>;
    final handles = <Widget>[];

    for (int i = 0; i < points.length; i += 2) {
      if (i + 1 >= points.length) break;

      final xPos = (points[i] as num).toDouble() * widget.elementSize.width;
      final yPos =
          (points[i + 1] as num).toDouble() * widget.elementSize.height;
      final pointIndex = i ~/ 2;

      handles.add(
        Positioned(
          left: xPos - 6,
          top: yPos - 6,
          child: GestureDetector(
            onPanStart: (_) => setState(() => activePointIndex = pointIndex),
            onPanUpdate: (details) => _handlePointDrag(pointIndex, details),
            onPanEnd: (_) => _handleDragEnd(),
            onLongPress: () => _handlePointDelete(pointIndex),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color:
                      activePointIndex == pointIndex ? Colors.red : Colors.blue,
                  width: activePointIndex == pointIndex ? 2 : 1,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: activePointIndex == pointIndex
                  ? const Icon(Icons.close, size: 8, color: Colors.red)
                  : null,
            ),
          ),
        ),
      );
    }

    return handles;
  }

  bool _isNearExistingPoint(Offset tapPosition) {
    if (widget.element.content['points'] == null) return false;

    final points = widget.element.content['points'] as List<dynamic>;
    final threshold = 20.0; // pixels

    for (int i = 0; i < points.length; i += 2) {
      if (i + 1 >= points.length) break;

      final xPos = (points[i] as num).toDouble() * widget.elementSize.width;
      final yPos =
          (points[i + 1] as num).toDouble() * widget.elementSize.height;
      final distance = (Offset(xPos, yPos) - tapPosition).distance;

      if (distance < threshold) {
        return true;
      }
    }

    return false;
  }

  void _handlePointDrag(int index, DragUpdateDetails details) {
    final editorState = context.read<EditorState>();
    final points = widget.element.content['points'] as List<dynamic>;

    // Convert the drag delta to relative coordinates
    double newX = (points[index * 2] as num).toDouble() +
        (details.delta.dx / widget.elementSize.width);
    double newY = (points[index * 2 + 1] as num).toDouble() +
        (details.delta.dy / widget.elementSize.height);

    // Clamp values to stay within bounds
    newX = newX.clamp(0.0, 1.0);
    newY = newY.clamp(0.0, 1.0);

    points[index * 2] = newX;
    points[index * 2 + 1] = newY;

    editorState.updateElement(widget.element);
  }

  void _handleDragEnd() {
    final historyState = context.read<HistoryState>();
    historyState.pushState(
        context.read<EditorState>().elements, widget.element);
    setState(() => activePointIndex = null);
  }

  void _handlePointDelete(int index) {
    final editorState = context.read<EditorState>();
    final historyState = context.read<HistoryState>();
    final points = widget.element.content['points'] as List<dynamic>;

    // Remove the point
    points.removeRange(index * 2, index * 2 + 2);

    editorState.updateElement(widget.element);
    historyState.pushState(editorState.elements, widget.element);
  }
}

class _CurvePreviewPainter extends CustomPainter {
  final List<dynamic> points;
  final Size elementSize;

  _CurvePreviewPainter({required this.points, required this.elementSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final firstX = (points[0] as num).toDouble() * size.width;
    final firstY = (points[1] as num).toDouble() * size.height;
    path.moveTo(firstX, firstY);

    for (int i = 2; i < points.length; i += 2) {
      if (i + 1 >= points.length) break;

      final x = (points[i] as num).toDouble() * size.width;
      final y = (points[i + 1] as num).toDouble() * size.height;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvePreviewPainter oldDelegate) {
    return true; // Always repaint for smooth updates
  }
}

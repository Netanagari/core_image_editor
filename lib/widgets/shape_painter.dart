import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/shape_types.dart';

class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final bool isStrokeDashed;
  final int? points;
  final double? innerRadiusRatio;
  final int? sides;
  final double? headSize;

  ShapePainter({
    required this.shapeType,
    required this.fillColor,
    required this.strokeColor,
    this.strokeWidth = 2.0,
    this.isStrokeDashed = false,
    this.points,
    this.innerRadiusRatio,
    this.sides,
    this.headSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (isStrokeDashed) {
      strokePaint.shader = _createDashPattern(size);
    }

    switch (shapeType) {
      case ShapeType.rectangle:
        _drawRectangle(canvas, size, paint, strokePaint);
        break;
      case ShapeType.circle:
        _drawCircle(canvas, size, paint, strokePaint);
        break;
      case ShapeType.triangle:
        _drawTriangle(canvas, size, paint, strokePaint);
        break;
      case ShapeType.line:
        _drawLine(canvas, size, strokePaint);
        break;
      case ShapeType.arrow:
        _drawArrow(canvas, size, paint, strokePaint);
        break;
      case ShapeType.diamond:
        _drawDiamond(canvas, size, paint, strokePaint);
        break;
      case ShapeType.pentagon:
        _drawPolygon(canvas, size, paint, strokePaint, customSides: 5);
        break;
      case ShapeType.hexagon:
        _drawPolygon(canvas, size, paint, strokePaint, customSides: 6);
        break;
      case ShapeType.star:
        _drawStar(canvas, size, paint, strokePaint);
        break;
    }
  }

  void _drawRectangle(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, stroke);
  }

  void _drawCircle(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, stroke);
  }

  void _drawTriangle(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawLine(Canvas canvas, Size size, Paint stroke) {
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      stroke,
    );
  }

  void _drawArrow(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final arrowHeadSize = headSize ?? 0.3;
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width - size.height * arrowHeadSize, size.height / 2)
      ..lineTo(size.width - size.height * arrowHeadSize,
          size.height * (0.5 - arrowHeadSize))
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - size.height * arrowHeadSize,
          size.height * (0.5 + arrowHeadSize))
      ..lineTo(size.width - size.height * arrowHeadSize, size.height / 2)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawDiamond(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawPolygon(
    Canvas canvas,
    Size size,
    Paint fill,
    Paint stroke, {
    int? customSides,
  }) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final numSides = customSides ??
        sides ??
        (shapeType == ShapeType.pentagon
            ? 5
            : shapeType == ShapeType.hexagon
                ? 6
                : 3);

    for (int i = 0; i < numSides; i++) {
      final angle = (i * 2 * math.pi / numSides) - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawStar(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * (innerRadiusRatio ?? 0.4);
    final numPoints = points ?? 5;

    for (int i = 0; i < numPoints * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi / numPoints) - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  Shader _createDashPattern(Size size) {
    const dashWidth = 5.0;
    const dashSpace = 5.0;

    return const LinearGradient(
      colors: [Colors.black, Colors.transparent],
      stops: [0.5, 0.5],
      tileMode: TileMode.repeated,
    ).createShader(
      Rect.fromLTWH(0, 0, dashWidth + dashSpace, dashWidth + dashSpace),
    );
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    return oldDelegate.shapeType != shapeType ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.isStrokeDashed != isStrokeDashed;
  }
}

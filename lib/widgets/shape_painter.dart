import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/shape_types.dart';

// Define the line shadow properties
class LineShadow {
  final Color color;
  final double offsetX;
  final double offsetY;
  final double blurRadius;
  final double spreadRadius;

  const LineShadow({
    required this.color,
    required this.offsetX,
    required this.offsetY,
    required this.blurRadius,
    this.spreadRadius = 0.0,
  });
}

class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final bool isStrokeDashed;
  final List<double>? points;
  final double? innerRadiusRatio;
  final int? sides;
  final double? headSize;
  final double? curvature;
  final LineShadow? lineShadow; // Added line shadow property

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
    this.curvature,
    this.lineShadow, // Added line shadow parameter
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
      case ShapeType.curvedLine:
        _drawCurvedLine(canvas, size, strokePaint);
        break;
    }
  }

  Path getClipPath(Size size) {
    switch (shapeType) {
      case ShapeType.rectangle:
        return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

      case ShapeType.circle:
        return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

      case ShapeType.triangle:
        return Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();

      case ShapeType.diamond:
        return Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();

      case ShapeType.pentagon:
        return _getPolygonPath(size, 5);

      case ShapeType.hexagon:
        return _getPolygonPath(size, 6);

      case ShapeType.curvedLine:
        return _getCurvedLinePath(size);

      case ShapeType.star:
        return _getStarPath(size);

      default:
        return Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }
  }

  Path _getPolygonPath(Size size, int sides) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2;
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

    return path..close();
  }

  Path _getStarPath(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * (innerRadiusRatio ?? 0.4);
    final numPoints = (points?.isNotEmpty == true ? points![0] : 5.0).toInt();

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

    return path..close();
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
    final Path path = Path();
    Paint? shadowPaint;

    if (curvature == null || curvature == 0) {
      // Draw straight line
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
    } else {
      // Draw curved line using quadratic bezier curve
      path.moveTo(0, size.height / 2);

      // Control point is placed above or below the midpoint based on curvature
      // curvature ranges from -0.5 to 0.5, positive curves up, negative curves down
      final controlPoint = Offset(
        size.width / 2,
        size.height / 2 - (size.height * curvature!),
      );

      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        size.width,
        size.height / 2,
      );
    }

    // Create path effect for line width
    final pathMetrics = path.computeMetrics();
    final widePath = Path();

    for (final metric in pathMetrics) {
      var dist = 0.0;
      while (dist < metric.length) {
        final pos = metric.getTangentForOffset(dist)?.position;
        if (pos != null) {
          widePath.addOval(
            Rect.fromCenter(
              center: pos,
              width: strokeWidth,
              height: strokeWidth,
            ),
          );
        }
        dist += strokeWidth / 2;
      }
    }

    // Draw shadow if shadow parameters are provided
    if (lineShadow != null) {
      shadowPaint = Paint()
        ..color = lineShadow!.color
        ..strokeWidth = stroke.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          lineShadow!.blurRadius,
        );

      canvas.save();
      canvas.translate(lineShadow!.offsetX, lineShadow!.offsetY);
      canvas.drawPath(widePath, shadowPaint);
      canvas.restore();
    }

    // Draw the line
    canvas.drawPath(widePath, stroke);
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
    final numPoints = (points?.isNotEmpty == true ? points![0] : 5.0).toInt();

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

  void _drawCurvedLine(Canvas canvas, Size size, Paint strokePaint) {
    if (points == null || points!.isEmpty) return;

    final path = Path();
    List<Offset> curvePoints = [];

    // Convert points array to Offset list
    for (int i = 0; i < points!.length; i += 2) {
      if (i + 1 < points!.length) {
        curvePoints.add(Offset(
          points![i] * size.width,
          points![i + 1] * size.height,
        ));
      }
    }

    if (curvePoints.isEmpty) return;

    path.moveTo(curvePoints[0].dx, curvePoints[0].dy);

    if (curvePoints.length == 2) {
      // Draw straight line if only 2 points
      path.lineTo(curvePoints[1].dx, curvePoints[1].dy);
    } else {
      // Draw smooth curve through points using cubic Bezier curves
      for (int i = 0; i < curvePoints.length - 1; i++) {
        final p0 = i > 0 ? curvePoints[i - 1] : curvePoints[i];
        final p1 = curvePoints[i];
        final p2 = curvePoints[i + 1];
        final p3 = i < curvePoints.length - 2 ? curvePoints[i + 2] : p2;

        // Calculate control points for smooth curve
        final cp1 = Offset(
          p1.dx + (p2.dx - p0.dx) / 6,
          p1.dy + (p2.dy - p0.dy) / 6,
        );
        final cp2 = Offset(
          p2.dx - (p3.dx - p1.dx) / 6,
          p2.dy - (p3.dy - p1.dy) / 6,
        );

        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
      }
    }

    // Create a stroke-like path by creating a thin rectangle along the curve
    final strokePath = Path();
    final strokeWidth = size.width * 0.01; // 1% of width for stroke
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final tangent = metric.getTangentForOffset(dist)!;
        final point = tangent.position;

        strokePath.addRect(Rect.fromCenter(
          center: point,
          width: strokeWidth,
          height: strokeWidth,
        ));

        dist += strokeWidth / 2;
      }
    }

    canvas.drawPath(strokePath, strokePaint);
  }

  Path _getCurvedLinePath(Size size) {
    if (points == null || points!.isEmpty) return Path();

    final path = Path();
    List<Offset> curvePoints = [];

    // Convert points array to Offset list
    for (int i = 0; i < points!.length; i += 2) {
      if (i + 1 < points!.length) {
        curvePoints.add(Offset(
          points![i] * size.width,
          points![i + 1] * size.height,
        ));
      }
    }

    if (curvePoints.isEmpty) return Path();

    path.moveTo(curvePoints[0].dx, curvePoints[0].dy);

    if (curvePoints.length == 2) {
      // Draw straight line if only 2 points
      path.lineTo(curvePoints[1].dx, curvePoints[1].dy);
    } else {
      // Draw smooth curve through points using cubic Bezier curves
      for (int i = 0; i < curvePoints.length - 1; i++) {
        final p0 = i > 0 ? curvePoints[i - 1] : curvePoints[i];
        final p1 = curvePoints[i];
        final p2 = curvePoints[i + 1];
        final p3 = i < curvePoints.length - 2 ? curvePoints[i + 2] : p2;

        // Calculate control points for smooth curve
        final cp1 = Offset(
          p1.dx + (p2.dx - p0.dx) / 6,
          p1.dy + (p2.dy - p0.dy) / 6,
        );
        final cp2 = Offset(
          p2.dx - (p3.dx - p1.dx) / 6,
          p2.dy - (p3.dy - p1.dy) / 6,
        );

        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
      }
    }

    return path;
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
        oldDelegate.isStrokeDashed != isStrokeDashed ||
        oldDelegate.curvature != curvature;
  }
}

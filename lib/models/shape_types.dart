import 'package:flutter/material.dart';

enum HandlePosition { topLeft, topRight, bottomLeft, bottomRight }

enum ShapeType {
  rectangle,
  circle,
  triangle,
  line,
  arrow,
  diamond,
  pentagon,
  hexagon,
  star,
  curvedLine,
}

extension ShapeTypeExtension on ShapeType {
  String get displayName {
    switch (this) {
      case ShapeType.rectangle:
        return 'Rectangle';
      case ShapeType.circle:
        return 'Circle';
      case ShapeType.triangle:
        return 'Triangle';
      case ShapeType.line:
        return 'Line';
      case ShapeType.arrow:
        return 'Arrow';
      case ShapeType.diamond:
        return 'Diamond';
      case ShapeType.pentagon:
        return 'Pentagon';
      case ShapeType.hexagon:
        return 'Hexagon';
      case ShapeType.star:
        return 'Star';
      case ShapeType.curvedLine:
        return 'Curved Line';
    }
  }

  IconData get icon {
    switch (this) {
      case ShapeType.rectangle:
        return Icons.rectangle_outlined;
      case ShapeType.circle:
        return Icons.circle_outlined;
      case ShapeType.triangle:
        return Icons.change_history_outlined;
      case ShapeType.line:
        return Icons.horizontal_rule;
      case ShapeType.arrow:
        return Icons.arrow_right_alt;
      case ShapeType.diamond:
        return Icons.diamond_outlined;
      case ShapeType.pentagon:
        return Icons.pentagon_outlined;
      case ShapeType.hexagon:
        return Icons.hexagon_outlined;
      case ShapeType.star:
        return Icons.star_border;
      case ShapeType.curvedLine:
        return Icons.gesture; // Using gesture icon for curved line
    }
  }
}

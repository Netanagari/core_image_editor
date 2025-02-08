import 'package:flutter/widgets.dart';

class TemplateBox {
  double xPercent;
  double yPercent;
  double widthPercent;
  double heightPercent;
  String alignment;
  double rotation;

  TemplateBox({
    required this.xPercent,
    required this.yPercent,
    required this.widthPercent,
    required this.heightPercent,
    this.alignment = 'left',
    this.rotation = 0,
  });

  factory TemplateBox.fromJson(Map<String, dynamic> json) {
    return TemplateBox(
      xPercent: json['x_percent']?.toDouble() ?? 0.0,
      yPercent: json['y_percent']?.toDouble() ?? 0.0,
      widthPercent: json['width_percent']?.toDouble() ?? 0.0,
      heightPercent: json['height_percent']?.toDouble() ?? 0.0,
      alignment: json['alignment'] ?? 'left',
      rotation: json['rotation']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x_percent': xPercent,
      'y_percent': yPercent,
      'width_percent': widthPercent,
      'height_percent': heightPercent,
      'alignment': alignment,
      'rotation': rotation,
    };
  }
}

class TemplateStyle {
  double fontSizeVw;
  String color;
  String fontFamily;
  FontWeight fontWeight;
  BoxFit imageFit;
  bool isItalic;
  bool isUnderlined;
  List<String>?
      decorations; // For multiple text decorations (underline, linethrough, etc)
  String? borderStyle;
  String? borderColor;
  double? borderWidth;

  TemplateStyle({
    required this.fontSizeVw,
    required this.color,
    this.fontFamily = 'Roboto',
    this.imageFit = BoxFit.contain,
    this.fontWeight = FontWeight.normal,
    this.isItalic = false,
    this.isUnderlined = false,
    this.decorations,
    this.borderStyle,
    this.borderColor,
    this.borderWidth,
  });

  factory TemplateStyle.fromJson(Map<String, dynamic> json) {
    return TemplateStyle(
      fontSizeVw: json['font_size']?.toDouble() ?? 4.0,
      color: json['color'] ?? '#000000',
      fontFamily: json['font_family'] ?? 'Roboto',
      fontWeight: _parseFontWeight(json['font_weight']),
      imageFit: _parseBoxFit(json['imageFit']),
      isItalic: json['is_italic'] ?? false,
      isUnderlined: json['is_underlined'] ?? false,
      decorations: json['decorations']?.cast<String>(),
      borderStyle: json['border_style'],
      borderColor: json['border_color'],
      borderWidth: json['border_width']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'font_size': fontSizeVw,
      'color': color,
      'font_family': fontFamily,
      'font_weight': fontWeight.toString(),
      'is_italic': isItalic,
      'imageFit': imageFit.toString(),
      'is_underlined': isUnderlined,
      'decorations': decorations,
      'border_style': borderStyle,
      'border_color': borderColor,
      'border_width': borderWidth,
    };
  }

  static BoxFit _parseBoxFit(String value) {
    switch (value) {
      case 'BoxFit.contain':
        return BoxFit.contain;
      case 'BoxFit.cover':
        return BoxFit.cover;
      case 'BoxFit.fill':
        return BoxFit.fill;
      case 'BoxFit.fitWidth':
        return BoxFit.fitWidth;
      case 'BoxFit.fitHeight':
        return BoxFit.fitHeight;
      default:
        return BoxFit.contain;
    }
  }

  static FontWeight _parseFontWeight(String? weight) {
    switch (weight) {
      case 'FontWeight.w100':
        return FontWeight.w100;
      case 'FontWeight.w200':
        return FontWeight.w200;
      case 'FontWeight.w300':
        return FontWeight.w300;
      case 'FontWeight.w400':
        return FontWeight.w400;
      case 'FontWeight.w500':
        return FontWeight.w500;
      case 'FontWeight.w600':
        return FontWeight.w600;
      case 'FontWeight.w700':
        return FontWeight.w700;
      case 'FontWeight.w800':
        return FontWeight.w800;
      case 'FontWeight.w900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  @override
  String toString() {
    return 'TemplateStyle(fontSizeVw: $fontSizeVw, color: $color, fontFamily: $fontFamily, fontWeight: $fontWeight, isItalic: $isItalic, isUnderlined: $isUnderlined, decorations: $decorations, borderStyle: $borderStyle, borderColor: $borderColor, borderWidth: $borderWidth)';
  }
}

class TemplateElement {
  String type;
  TemplateBox box;
  Map<String, dynamic> content;
  TemplateStyle style;
  int zIndex;

  TemplateElement({
    required this.type,
    required this.box,
    required this.content,
    required this.style,
    this.zIndex = 0,
  });

  factory TemplateElement.fromJson(Map<String, dynamic> json) {
    return TemplateElement(
      type: json['type'] ?? 'text',
      box: TemplateBox.fromJson(json['box'] ?? {}),
      content: json['content'] ?? {},
      style: TemplateStyle.fromJson(json['style'] ?? {}),
      zIndex: json['z_index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'box': box.toJson(),
      'content': content,
      'style': style.toJson(),
      'z_index': zIndex,
    };
  }

  @override
  String toString() {
    return 'TemplateElement(type: $type, box: $box, content: $content, style: $style, zIndex: $zIndex)';
  }
}

import 'package:core_image_editor/models/shape_types.dart';
import 'package:flutter/widgets.dart';

enum LeaderStripSize {
  small,
  medium,
  large;

  double get heightPercent {
    switch (this) {
      case LeaderStripSize.small:
        return 15.0;
      case LeaderStripSize.medium:
        return 20.0;
      case LeaderStripSize.large:
        return 25.0;
    }
  }
}

enum TemplateElementTag {
  bgImage,
  image,
  title,
  subtitle,
  userPicture,
  partySymbol,
  userName,
  userDesignation,
  userParty,
  leaderPhotoStrip,
  leader,
  defaulty;

  String get displayName {
    switch (this) {
      case TemplateElementTag.bgImage:
        return 'Background Image';
      case TemplateElementTag.image:
        return 'Image';
      case TemplateElementTag.title:
        return 'Title';
      case TemplateElementTag.subtitle:
        return 'Subtitle';
      case TemplateElementTag.userPicture:
        return 'User Picture';
      case TemplateElementTag.partySymbol:
        return 'Party Symbol';
      case TemplateElementTag.leaderPhotoStrip:
        return 'Leader Photo Strip';
      case TemplateElementTag.leader:
        return 'Leader';
      case TemplateElementTag.userName:
        return 'User Name';
      case TemplateElementTag.userDesignation:
        return 'User Designation';
      case TemplateElementTag.userParty:
        return 'User Party';
      case TemplateElementTag.defaulty:
        return 'Default';
    }
  }

  String get description {
    switch (this) {
      case TemplateElementTag.bgImage:
        return 'Main background image of the poster';
      case TemplateElementTag.image:
        return 'Relevant image related to event or content';
      case TemplateElementTag.title:
        return 'Main title or heading text';
      case TemplateElementTag.subtitle:
        return 'Secondary or descriptive text';
      case TemplateElementTag.userPicture:
        return 'Picture of the user/candidate';
      case TemplateElementTag.partySymbol:
        return 'Political party symbol or logo';
      case TemplateElementTag.leaderPhotoStrip:
        return 'Strip of leader photos';
      case TemplateElementTag.leader:
        return 'Leader photo';
      case TemplateElementTag.userName:
        return 'The name of the user/candidate';
      case TemplateElementTag.userDesignation:
        return 'Job title or position of the user/candidate';
      case TemplateElementTag.userParty:
        return 'Political party of the user/candidate';
      case TemplateElementTag.defaulty:
        return 'Standard element with no special handling';
    }
  }
}

class NestedContent {
  TemplateElement? content;
  BoxFit contentFit;
  Alignment contentAlignment;

  NestedContent({
    this.content,
    this.contentFit = BoxFit.contain,
    this.contentAlignment = Alignment.center,
  });

  factory NestedContent.fromJson(Map<String, dynamic> json) {
    return NestedContent(
      content: json['content'] != null
          ? TemplateElement.fromJson(json['content'])
          : null,
      contentFit: _parseBoxFit(json['contentFit'] ?? 'BoxFit.contain'),
      contentAlignment: _parseAlignment(json['contentAlignment'] ?? 'center'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content?.toJson(),
      'contentFit': contentFit.toString(),
      'contentAlignment': contentAlignment.toString(),
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

  static Alignment _parseAlignment(String value) {
    switch (value) {
      case 'center':
        return Alignment.center;
      case 'topLeft':
        return Alignment.topLeft;
      case 'topRight':
        return Alignment.topRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return Alignment.center;
    }
  }
}

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
  List<String>? decorations;
  String? borderStyle;
  String? borderColor;
  double? borderWidth;
  double? borderRadius;
  // New fields
  double opacity;
  String? imageShape; // 'rectangle' or 'circle'
  bool isReadOnly;
  Map<String, dynamic>?
      boxShadow; // Contains color, offsetX, offsetY, blurRadius, spreadRadius

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
    this.borderRadius,
    this.opacity = 1.0,
    this.imageShape,
    this.isReadOnly = false,
    this.boxShadow,
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
      borderRadius: json['border_radius']?.toDouble(),
      opacity: json['opacity']?.toDouble() ?? 1.0,
      imageShape: json['image_shape'],
      isReadOnly: json['is_read_only'] ?? false,
      boxShadow: json['box_shadow'],
    );
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
      'border_radius': borderRadius,
      'opacity': opacity,
      'image_shape': imageShape,
      'is_read_only': isReadOnly,
      'box_shadow': boxShadow,
    };
  }
}

class TemplateElement {
  String type;
  TemplateBox box;
  Map<String, dynamic> content;
  TemplateStyle style;
  int zIndex;
  TemplateElementTag tag;
  NestedContent? nestedContent;

  TemplateElement({
    required this.type,
    required this.box,
    required this.content,
    required this.style,
    this.zIndex = 0,
    this.nestedContent,
    this.tag = TemplateElementTag.defaulty,
  });

  factory TemplateElement.createUserName() {
    return TemplateElement(
      type: 'text',
      tag: TemplateElementTag.userName,
      box: TemplateBox(
        xPercent: 10,
        yPercent: 10,
        widthPercent: 80,
        heightPercent: 10,
        alignment: 'center',
      ),
      content: {'text': 'Candidate Name'},
      style: TemplateStyle(
        fontSizeVw: 5.0,
        color: '#000000',
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
      ),
    );
  }

  factory TemplateElement.createUserDesignation() {
    return TemplateElement(
      type: 'text',
      tag: TemplateElementTag.userDesignation,
      box: TemplateBox(
        xPercent: 10,
        yPercent: 20,
        widthPercent: 80,
        heightPercent: 6,
        alignment: 'center',
      ),
      content: {'text': 'Candidate Designation'},
      style: TemplateStyle(
        fontSizeVw: 3.5,
        color: '#444444',
        fontFamily: 'Poppins',
        fontWeight: FontWeight.normal,
      ),
    );
  }

  factory TemplateElement.createUserParty() {
    return TemplateElement(
      type: 'text',
      tag: TemplateElementTag.userParty,
      box: TemplateBox(
        xPercent: 10,
        yPercent: 26,
        widthPercent: 80,
        heightPercent: 6,
        alignment: 'center',
      ),
      content: {'text': 'Political Party'},
      style: TemplateStyle(
        fontSizeVw: 3.5,
        color: '#333333',
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  factory TemplateElement.createUserPicture() {
    return TemplateElement(
      type: 'image',
      tag: TemplateElementTag.userPicture,
      box: TemplateBox(
        xPercent: 10,
        yPercent: 35,
        widthPercent: 30,
        heightPercent: 30,
        alignment: 'center',
      ),
      content: {
        'url': 'https://via.placeholder.com/200x200',
      },
      style: TemplateStyle(
        fontSizeVw: 0,
        color: '#000000',
        imageShape: 'circle',
        imageFit: BoxFit.cover,
      ),
    );
  }

  factory TemplateElement.createLeader(String imageUrl) {
    return TemplateElement(
      type: 'image',
      tag: TemplateElementTag.leader,
      box: TemplateBox(
        xPercent: 0, // Position will be handled by leader strip
        yPercent: 0,
        widthPercent: 100, // Will be adjusted by strip
        heightPercent: 100,
        alignment: 'center',
      ),
      content: {
        'url': imageUrl,
      },
      style: TemplateStyle(
        fontSizeVw: 0,
        color: '#000000',
        imageShape: 'circle', // Default shape
        imageFit: BoxFit.cover,
      ),
    );
  }

  factory TemplateElement.createLeaderStrip() {
    return TemplateElement(
      type: 'leader_strip',
      tag: TemplateElementTag.leaderPhotoStrip,
      box: TemplateBox(
        xPercent: 10,
        yPercent: 10,
        widthPercent: 80,
        heightPercent: LeaderStripSize.medium.heightPercent,
        alignment: 'center',
      ),
      content: {
        'leaders':
            <Map<String, dynamic>>[], // List of serialized leader elements
        'stripSize': 'medium',
        'spacing': 8.0,
      },
      style: TemplateStyle(
        fontSizeVw: 0,
        color: '#000000',
      ),
    );
  }

  List<TemplateElement> getLeaders() {
    if (type != 'leader_strip') return [];

    return (content['leaders'] as List? ?? [])
        .map((leaderJson) => TemplateElement.fromJson(leaderJson))
        .toList();
  }

  void setLeaders(List<TemplateElement> leaders) {
    if (type != 'leader_strip') return;
    content['leaders'] = leaders.map((e) => e.toJson()).toList();
  }

  factory TemplateElement.fromJson(Map<String, dynamic> json) {
    return TemplateElement(
      type: json['type'] ?? 'text',
      box: TemplateBox.fromJson(json['box'] ?? {}),
      content: json['content'] ?? {},
      style: TemplateStyle.fromJson(json['style'] ?? {}),
      zIndex: json['z_index'] ?? 0,
      nestedContent: json['nested_content'] != null
          ? NestedContent.fromJson(json['nested_content'])
          : null,
      tag: _parseTag(json['tag']),
    );
  }

  static TemplateElementTag _parseTag(String? tagStr) {
    if (tagStr == null) return TemplateElementTag.defaulty;
    try {
      return TemplateElementTag.values.firstWhere(
        (tag) => tag.toString() == tagStr,
        orElse: () => TemplateElementTag.defaulty,
      );
    } catch (e) {
      return TemplateElementTag.defaulty;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'box': box.toJson(),
      'content': content,
      'style': style.toJson(),
      'z_index': zIndex,
      'tag': tag.toString(),
      'nested_content': nestedContent?.toJson(),
    };
  }

  bool get canContainNestedContent {
    if (type != 'shape') return false;
    final shapeType = ShapeType.values.firstWhere(
      (type) => type.toString() == content['shapeType'],
      orElse: () => ShapeType.rectangle,
    );
    return shapeType != ShapeType.line && shapeType != ShapeType.arrow;
  }

  @override
  String toString() {
    return 'TemplateElement(type: $type, box: $box, content: $content, style: $style, zIndex: $zIndex)';
  }
}

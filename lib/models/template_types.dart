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
  background,
  keyVisual,
  heading,
  subheading,
  messaging,
  userPicture,
  partySymbol,
  userName,
  userDesignation,
  userParty,
  leaderStrip,
  leader,
  facebookHandle,
  instaHandle,
  twitterHandle,
  defaulty;

  // Method to get valid tags for a specific group
  static List<TemplateElementTag> getValidTagsForGroup(String? group) {
    if (group == null) {
      return TemplateElementTag.values;
    }

    switch (group) {
      case 'user_strip':
        return [
          userPicture,
          partySymbol,
          userName,
          userDesignation,
          userParty,
          facebookHandle,
          instaHandle,
          twitterHandle,
          defaulty,
        ];
      default:
        return TemplateElementTag.values;
    }
  }

  // Check if this tag is valid for a given group
  bool isValidForGroup(String? group) {
    return getValidTagsForGroup(group).contains(this);
  }

  String get displayName {
    switch (this) {
      case TemplateElementTag.background:
        return 'Background Image';
      case TemplateElementTag.keyVisual:
        return 'Key visual';
      case TemplateElementTag.heading:
        return 'Heading';
      case TemplateElementTag.subheading:
        return 'Sub heading';
      case TemplateElementTag.messaging:
        return 'Messaging';
      case TemplateElementTag.userPicture:
        return 'User Picture';
      case TemplateElementTag.partySymbol:
        return 'Party Symbol';
      case TemplateElementTag.leaderStrip:
        return 'Leader Strip';
      case TemplateElementTag.leader:
        return 'Leader';
      case TemplateElementTag.userName:
        return 'User Name';
      case TemplateElementTag.userDesignation:
        return 'User Designation';
      case TemplateElementTag.userParty:
        return 'User Party';
      case TemplateElementTag.facebookHandle:
        return 'Facebook Handle';
      case TemplateElementTag.instaHandle:
        return 'Instagram Handle';
      case TemplateElementTag.twitterHandle:
        return 'Twitter Handle';
      case TemplateElementTag.defaulty:
        return 'Default';
    }
  }

  String get description {
    switch (this) {
      case TemplateElementTag.background:
        return 'Main background image of the poster';
      case TemplateElementTag.keyVisual:
        return 'Relevant image related to event or content';
      case TemplateElementTag.heading:
        return 'Main title or heading text';
      case TemplateElementTag.subheading:
        return 'Secondary or descriptive text';
      case TemplateElementTag.messaging:
        return 'Tertiery or more descriptive text';
      case TemplateElementTag.userPicture:
        return 'Picture of the user/candidate';
      case TemplateElementTag.partySymbol:
        return 'Political party symbol or logo';
      case TemplateElementTag.leaderStrip:
        return 'Strip of leader photos';
      case TemplateElementTag.leader:
        return 'Leader photo';
      case TemplateElementTag.userName:
        return 'The name of the user/candidate';
      case TemplateElementTag.userDesignation:
        return 'Job title or position of the user/candidate';
      case TemplateElementTag.userParty:
        return 'Political party of the user/candidate';
      case TemplateElementTag.facebookHandle:
        return 'Facebook handle of the user/candidate';
      case TemplateElementTag.instaHandle:
        return 'Instagram handle of the user/candidate';
      case TemplateElementTag.twitterHandle:
        return 'Twitter handle of the user/candidate';
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
  // New pixel-based fields
  double? xPx;
  double? yPx;
  double? widthPx;
  double? heightPx;
  String alignment;
  double rotation;

  TemplateBox({
    required this.xPercent,
    required this.yPercent,
    required this.widthPercent,
    required this.heightPercent,
    this.xPx,
    this.yPx,
    this.widthPx,
    this.heightPx,
    this.alignment = 'left',
    this.rotation = 0,
  });

  factory TemplateBox.fromJson(Map<String, dynamic> json) {
    return TemplateBox(
      xPercent: json['x_percent']?.toDouble() ?? 0.0,
      yPercent: json['y_percent']?.toDouble() ?? 0.0,
      widthPercent: json['width_percent']?.toDouble() ?? 0.0,
      heightPercent: json['height_percent']?.toDouble() ?? 0.0,
      xPx: json['x_px'] != null ? (json['x_px'] as num).toDouble() : null,
      yPx: json['y_px'] != null ? (json['y_px'] as num).toDouble() : null,
      widthPx: json['width_px'] != null
          ? (json['width_px'] as num).toDouble()
          : null,
      heightPx: json['height_px'] != null
          ? (json['height_px'] as num).toDouble()
          : null,
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
      if (xPx != null) 'x_px': xPx,
      if (yPx != null) 'y_px': yPx,
      if (widthPx != null) 'width_px': widthPx,
      if (heightPx != null) 'height_px': heightPx,
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
  // Added textAlign for text-based elements
  String? textAlign; // 'left', 'center', 'right', 'justify'

  TemplateStyle({
    required this.fontSizeVw,
    required this.color,
    this.fontFamily = 'English',
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
    this.textAlign, // new
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
      textAlign: json['text_align'], // new
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
      'text_align': textAlign, // new
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
  String? group;

  TemplateElement({
    required this.type,
    required this.box,
    required this.content,
    required this.style,
    this.zIndex = 0,
    this.nestedContent,
    this.group,
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
      content: {
        'fallback': 'Candidate Name',
        'en': {'text': 'Candidate Name'},
      },
      style: TemplateStyle(
        fontSizeVw: 5.0,
        color: '#000000',
        fontFamily: 'English',
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
      content: {
        'fallback': 'Candidate Designation',
        'en': {'text': 'Candidate Designation'},
      },
      style: TemplateStyle(
        fontSizeVw: 3.5,
        color: '#444444',
        fontFamily: 'English',
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
      content: {
        'fallback': 'Political party',
        'en': {'text': 'Political party'},
      },
      style: TemplateStyle(
        fontSizeVw: 3.5,
        color: '#333333',
        fontFamily: 'English',
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
      tag: TemplateElementTag.leaderStrip,
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
      group: json['group'],
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
      'group': group,
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

extension MultilingualContent on TemplateElement {
  // Get text content for a specific language, fallback to default if not available
  String getTextContent(String languageCode) {
    if (type != 'text') return '';

    // Check if we have content for the requested language directly
    if (content.containsKey(languageCode) &&
        content[languageCode] is Map &&
        content[languageCode]['text'] != null) {
      return content[languageCode]['text'] as String;
    }

    // If not found, try fallback if available
    if (content.containsKey('fallback')) {
      return content['fallback'] as String;
    }

    // Finally try legacy format
    return content['text'] as String? ?? '';
  }

  // Set text content for a specific language
  void setTextContent(String languageCode, String text) {
    if (type != 'text') return;

    // If we're updating to the multilingual format for the first time
    if (!content.containsKey('fallback')) {
      // Save the existing text as the fallback
      final fallbackText = content['text'] as String? ?? '';

      // Convert simple format to multilingual format
      final Map<String, dynamic> newContent = {
        'fallback': fallbackText,
      };

      // Replace the content
      content = newContent;
    }

    // Create language map if it doesn't exist
    if (!content.containsKey(languageCode)) {
      content[languageCode] = {};
    } else if (content[languageCode] is! Map) {
      content[languageCode] = {};
    }

    // Set the text for this language
    (content[languageCode] as Map)['text'] = text;
  }

  // Check if element has multilingual content
  bool get hasMultilingualContent {
    return type == 'text' && content.containsKey('fallback');
  }

  // Convert legacy content to multilingual format
  void convertToMultilingual() {
    if (type != 'text' || hasMultilingualContent) return;

    final fallbackText = content['text'] as String? ?? '';

    // Create new multilingual content structure
    final Map<String, dynamic> newContent = {
      'fallback': fallbackText,
      'en': {'text': fallbackText},
    };

    // Replace the content
    content = newContent;
  }
}

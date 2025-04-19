import 'dart:convert';
import 'dart:developer';

import 'package:core_image_editor/models/editor_config.dart';
import 'package:core_image_editor/screens/template_editor_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

void main() {
  runApp(const MyApp());
}

final exampleJson = {
  "id": 5,
  "poster": 5,
  "base_image_url":
      "https://netanagri-bucket.s3.amazonaws.com/poster_base_images/gradient.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250419%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250419T064529Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=5a343caad37dbe9406112423ed0a9c956749b18b88378b5a75512118b44ea735",
  "thumbnail_url":
      "https://netanagri-bucket.s3.amazonaws.com/https%3A//netanagri-bucket.s3.amazonaws.com/poster/5/content/1745044989025?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250419%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250419T064529Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=555c0cce49a36ff1802ca395c709d9e7bc16a27bbacd76448f26b7722d334893",
  "original_width": 1200,
  "original_height": 1200,
  "aspect_ratio": 1.0,
  "content_json": [
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 10,
        "y_percent": 10,
        "width_percent": 80,
        "height_percent": 10
      },
      "tag": "TemplateElementTag.title",
      "type": "text",
      "group": null,
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 6,
        "is_italic": false,
        "box_shadow": null,
        "decorations": null,
        "font_family": "Roboto",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false
      },
      "content": {
        "be": {"text": "শুভ হোলি!"},
        "en": {"text": "Happy Holi!"},
        "hi": {"text": "होली मुबारक!"},
        "fallback": "New Heading"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 8.154342156105104,
        "y_percent": 16.99381761978362,
        "width_percent": 80,
        "height_percent": 10
      },
      "tag": "TemplateElementTag.subtitle",
      "type": "text",
      "group": null,
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 4,
        "is_italic": false,
        "box_shadow": null,
        "decorations": null,
        "font_family": "Roboto",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false
      },
      "content": {
        "be": {"text": "আনন্দ আর ঐক্যের রঙে রাঙিয়ে তুলুন দিনটা!"},
        "en": {"text": "Celebrate the colors of joy and togetherness!"},
        "hi": {"text": "खुशियों और मिलन के रंगों का जश्न मनाएं!"},
        "fallback": "New Text Block"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 82.68479061447812,
        "y_percent": 0,
        "width_percent": 17.31520938552189,
        "height_percent": 13.921638257575758
      },
      "tag": "TemplateElementTag.leaderPhotoStrip",
      "type": "leader_strip",
      "group": null,
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 0,
        "is_italic": false,
        "box_shadow": null,
        "decorations": null,
        "font_family": "Roboto",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false
      },
      "content": {
        "leaders": [
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 0,
              "y_percent": 0,
              "width_percent": 100,
              "height_percent": 100
            },
            "tag": "TemplateElementTag.leader",
            "type": "image",
            "group": null,
            "style": {
              "color": "#000000",
              "opacity": 1,
              "imageFit": "BoxFit.contain",
              "font_size": 0,
              "is_italic": false,
              "box_shadow": null,
              "decorations": null,
              "font_family": "Roboto",
              "font_weight": "FontWeight.w400",
              "image_shape": "circle",
              "border_color": null,
              "border_style": null,
              "border_width": null,
              "is_read_only": false,
              "border_radius": null,
              "is_underlined": false
            },
            "content": {
              "url":
                  "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1744220679313"
            },
            "z_index": 0,
            "nested_content": null
          }
        ],
        "spacing": 0,
        "stripSize": "medium",
        "justifyContent": "end",
        "verticalSpacing": 10
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 52.88936215795684,
        "y_percent": 87.18174139530579,
        "width_percent": 25.92881949283663,
        "height_percent": 8.400433833084508
      },
      "tag": "TemplateElementTag.userName",
      "type": "text",
      "group": "user_strip",
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 12,
        "is_italic": false,
        "box_shadow": null,
        "decorations": null,
        "font_family": "Poppins",
        "font_weight": "FontWeight.w700",
        "image_shape": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false
      },
      "content": {
        "en": {"text": "Deepak"},
        "fallback": "Candidate Name"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 72.28541246540945,
        "y_percent": 73.9731055739256,
        "width_percent": 26.770428297577297,
        "height_percent": 25.213548349681098
      },
      "tag": "TemplateElementTag.userPicture",
      "type": "shape",
      "group": null,
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 0,
        "is_italic": false,
        "box_shadow": null,
        "decorations": null,
        "font_family": "Roboto",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "border_color": null,
        "border_style": "none",
        "border_width": 0,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false
      },
      "content": {
        "fillColor": "#FFFFFF",
        "shapeType": "ShapeType.circle",
        "strokeColor": "#ffffff",
        "strokeWidth": 4,
        "isStrokeDashed": false
      },
      "z_index": 0,
      "nested_content": {
        "content": {
          "box": {
            "rotation": 0,
            "alignment": "center",
            "x_percent": 0,
            "y_percent": 0,
            "width_percent": 100,
            "height_percent": 100
          },
          "tag": "TemplateElementTag.defaulty",
          "type": "image",
          "group": null,
          "style": {
            "color": "#000000",
            "opacity": 1,
            "imageFit": "BoxFit.cover",
            "font_size": 0,
            "is_italic": false,
            "box_shadow": null,
            "decorations": null,
            "font_family": "Roboto",
            "font_weight": "FontWeight.w400",
            "image_shape": null,
            "border_color": null,
            "border_style": null,
            "border_width": null,
            "is_read_only": false,
            "border_radius": null,
            "is_underlined": false
          },
          "content": {
            "url":
                "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1744437924093"
          },
          "z_index": 0,
          "nested_content": null
        },
        "contentFit": "BoxFit.cover",
        "contentAlignment": "Alignment.center"
      }
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 21.522404100529084,
        "y_percent": 25.5077091600529,
        "width_percent": 57.36152447089947,
        "height_percent": 57.30985449735451
      },
      "tag": "TemplateElementTag.image",
      "type": "shape",
      "group": null,
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 0,
        "is_italic": false,
        "box_shadow": null,
        "decorations": null,
        "font_family": "Roboto",
        "font_weight": "FontWeight.w400",
        "image_shape": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false
      },
      "content": {
        "fillColor": "#FFFFFF",
        "shapeType": "ShapeType.circle",
        "strokeColor": "#ffffff",
        "strokeWidth": 4,
        "isStrokeDashed": false
      },
      "z_index": 0,
      "nested_content": {
        "content": {
          "box": {
            "rotation": 0,
            "alignment": "center",
            "x_percent": 0,
            "y_percent": 0,
            "width_percent": 100,
            "height_percent": 100
          },
          "tag": "TemplateElementTag.defaulty",
          "type": "image",
          "group": null,
          "style": {
            "color": "#000000",
            "opacity": 1,
            "imageFit": "BoxFit.cover",
            "font_size": 0,
            "is_italic": false,
            "box_shadow": null,
            "decorations": null,
            "font_family": "Roboto",
            "font_weight": "FontWeight.w400",
            "image_shape": null,
            "border_color": null,
            "border_style": null,
            "border_width": null,
            "is_read_only": false,
            "border_radius": null,
            "is_underlined": false
          },
          "content": {
            "url":
                "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1744438151656"
          },
          "z_index": 0,
          "nested_content": null
        },
        "contentFit": "BoxFit.cover",
        "contentAlignment": "Alignment.center"
      }
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 0,
        "y_percent": 86.46421519108024,
        "width_percent": 33.56434970790945,
        "height_percent": 9.37956959784821
      },
      "tag": "TemplateElementTag.userDesignation",
      "type": "text",
      "group": "user_strip",
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 8,
        "is_italic": false,
        "box_shadow": null,
        "decorations": null,
        "font_family": "Poppins",
        "font_weight": "FontWeight.w700",
        "image_shape": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false
      },
      "content": {
        "en": {"text": "Some designation"},
        "fallback": "Candidate Name"
      },
      "z_index": 0,
      "nested_content": null
    }
  ],
  "language_settings": {
    "current_language": "en",
    "default_language": {
      "code": "en",
      "name": "English",
      "flagEmoji": "🇬🇧",
      "nativeName": "English",
      "textDirection": "TextDirection.ltr"
    },
    "enabled_languages": [
      {
        "code": "en",
        "name": "English",
        "flagEmoji": "🇬🇧",
        "nativeName": "English",
        "textDirection": "TextDirection.ltr"
      },
      {
        "code": "hi",
        "name": "Hindi",
        "flagEmoji": "🇮🇳",
        "nativeName": "हिन्दी",
        "textDirection": "TextDirection.ltr"
      },
      {
        "code": "be",
        "name": "Bangla",
        "flagEmoji": null,
        "nativeName": "Bangla",
        "textDirection": "TextDirection.ltr"
      }
    ]
  }
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return CoreImageEditor(
      onSave: (json, imageBytes) async {
        log(json.toString());
        final base64Data = base64Encode(imageBytes ?? Uint8List.fromList([]));
        final anchor =
            html.AnchorElement(href: 'data:image/png;base64,$base64Data');
        anchor.download = 'image.png';
        anchor.click();
      },
      template: exampleJson,
      configuration: EditorConfiguration.admin,
      onSelectImage: (image) async {
        final img = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Select Image'),
              content: const Text('Select an image from gallery or camera'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("https://picsum.photos/200");
                  },
                  child: const Text('Random image 1'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop('https://picsum.photos/200/300');
                  },
                  child: const Text('Random image 2'),
                ),
              ],
            );
          },
        );
        print(img);
        return img;
      },
    );
  }
}

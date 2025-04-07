import 'dart:convert';

import 'package:core_image_editor/models/editor_config.dart';
import 'package:core_image_editor/screens/template_editor_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

void main() {
  runApp(const MyApp());
}

final exampleJson = {
  "multilingual_content": {
    "currentLanguage": "en",
    "contents": [
      {
        "language": "en",
        "content_json": [
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 10,
              "width_percent": 80,
              "height_percent": 15
            },
            "tag": "TemplateElementTag.title",
            "type": "text",
            "group": "header",
            "style": {
              "color": "#000000",
              "opacity": 1,
              "font_size": 6.0,
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
              "text": "Welcome to Our Event",
              "localizedText": {
                "translations": {"en": "Welcome to Our Event"},
                "defaultLanguage": "en"
              }
            },
            "z_index": 2,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 30,
              "width_percent": 80,
              "height_percent": 10
            },
            "tag": "TemplateElementTag.subtitle",
            "type": "text",
            "group": "header",
            "style": {
              "color": "#555555",
              "opacity": 1,
              "font_size": 4.0,
              "is_italic": false,
              "box_shadow": null,
              "decorations": null,
              "font_family": "Poppins",
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
              "text": "Join us for an amazing day of activities and fun",
              "localizedText": {
                "translations": {
                  "en": "Join us for an amazing day of activities and fun"
                },
                "defaultLanguage": "en"
              }
            },
            "z_index": 1,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 45,
              "width_percent": 80,
              "height_percent": 30
            },
            "tag": "TemplateElementTag.image",
            "type": "image",
            "group": "content",
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
              "image_shape": "rectangle",
              "border_color": "#000000",
              "border_style": "solid",
              "border_width": 1,
              "is_read_only": false,
              "border_radius": 8,
              "is_underlined": false
            },
            "content": {
              "url": "https://via.placeholder.com/800x400?text=Event+Image"
            },
            "z_index": 0,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 80,
              "width_percent": 80,
              "height_percent": 10
            },
            "tag": "TemplateElementTag.defaulty",
            "type": "text",
            "group": "footer",
            "style": {
              "color": "#0066CC",
              "opacity": 1,
              "font_size": 3.5,
              "is_italic": false,
              "box_shadow": null,
              "decorations": null,
              "font_family": "Poppins",
              "font_weight": "FontWeight.w500",
              "image_shape": null,
              "border_color": null,
              "border_style": null,
              "border_width": null,
              "is_read_only": false,
              "border_radius": null,
              "is_underlined": true
            },
            "content": {
              "text": "Register now at example.com",
              "localizedText": {
                "translations": {"en": "Register now at example.com"},
                "defaultLanguage": "en"
              }
            },
            "z_index": 3,
            "nested_content": null
          }
        ]
      },
      {
        "language": "es",
        "content_json": [
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 10,
              "width_percent": 80,
              "height_percent": 15
            },
            "tag": "TemplateElementTag.title",
            "type": "text",
            "group": "header",
            "style": {
              "color": "#000000",
              "opacity": 1,
              "font_size": 6.0,
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
              "text": "Bienvenido a Nuestro Evento",
              "localizedText": {
                "translations": {
                  "en": "Welcome to Our Event",
                  "es": "Bienvenido a Nuestro Evento"
                },
                "defaultLanguage": "en"
              }
            },
            "z_index": 2,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 30,
              "width_percent": 80,
              "height_percent": 10
            },
            "tag": "TemplateElementTag.subtitle",
            "type": "text",
            "group": "header",
            "style": {
              "color": "#555555",
              "opacity": 1,
              "font_size": 4.0,
              "is_italic": false,
              "box_shadow": null,
              "decorations": null,
              "font_family": "Poppins",
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
              "text":
                  "Únase a nosotros para un día increíble de actividades y diversión",
              "localizedText": {
                "translations": {
                  "en": "Join us for an amazing day of activities and fun",
                  "es":
                      "Únase a nosotros para un día increíble de actividades y diversión"
                },
                "defaultLanguage": "en"
              }
            },
            "z_index": 1,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 45,
              "width_percent": 80,
              "height_percent": 30
            },
            "tag": "TemplateElementTag.image",
            "type": "image",
            "group": "content",
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
              "image_shape": "rectangle",
              "border_color": "#000000",
              "border_style": "solid",
              "border_width": 1,
              "is_read_only": false,
              "border_radius": 8,
              "is_underlined": false
            },
            "content": {
              "url":
                  "https://via.placeholder.com/800x400?text=Imagen+del+Evento"
            },
            "z_index": 0,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 80,
              "width_percent": 80,
              "height_percent": 10
            },
            "tag": "TemplateElementTag.defaulty",
            "type": "text",
            "group": "footer",
            "style": {
              "color": "#0066CC",
              "opacity": 1,
              "font_size": 3.5,
              "is_italic": false,
              "box_shadow": null,
              "decorations": null,
              "font_family": "Poppins",
              "font_weight": "FontWeight.w500",
              "image_shape": null,
              "border_color": null,
              "border_style": null,
              "border_width": null,
              "is_read_only": false,
              "border_radius": null,
              "is_underlined": true
            },
            "content": {
              "text": "Regístrese ahora en example.com",
              "localizedText": {
                "translations": {
                  "en": "Register now at example.com",
                  "es": "Regístrese ahora en example.com"
                },
                "defaultLanguage": "en"
              }
            },
            "z_index": 3,
            "nested_content": null
          }
        ]
      },
      {
        "language": "hi",
        "content_json": [
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 10,
              "width_percent": 80,
              "height_percent": 15
            },
            "tag": "TemplateElementTag.title",
            "type": "text",
            "group": "header",
            "style": {
              "color": "#000000",
              "opacity": 1,
              "font_size": 6.0,
              "is_italic": false,
              "box_shadow": null,
              "decorations": null,
              "font_family": "Tiro Devanagari Hindi",
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
              "text": "हमारे कार्यक्रम में आपका स्वागत है",
              "localizedText": {
                "translations": {
                  "en": "Welcome to Our Event",
                  "hi": "हमारे कार्यक्रम में आपका स्वागत है"
                },
                "defaultLanguage": "en"
              }
            },
            "z_index": 2,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 30,
              "width_percent": 80,
              "height_percent": 10
            },
            "tag": "TemplateElementTag.subtitle",
            "type": "text",
            "group": "header",
            "style": {
              "color": "#555555",
              "opacity": 1,
              "font_size": 4.0,
              "is_italic": false,
              "box_shadow": null,
              "decorations": null,
              "font_family": "Tiro Devanagari Hindi",
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
              "text":
                  "गतिविधियों और मनोरंजन के एक अद्भुत दिन के लिए हमारे साथ जुड़ें",
              "localizedText": {
                "translations": {
                  "en": "Join us for an amazing day of activities and fun",
                  "hi":
                      "गतिविधियों और मनोरंजन के एक अद्भुत दिन के लिए हमारे साथ जुड़ें"
                },
                "defaultLanguage": "en"
              }
            },
            "z_index": 1,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 45,
              "width_percent": 80,
              "height_percent": 30
            },
            "tag": "TemplateElementTag.image",
            "type": "image",
            "group": "content",
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
              "image_shape": "rectangle",
              "border_color": "#000000",
              "border_style": "solid",
              "border_width": 1,
              "is_read_only": false,
              "border_radius": 8,
              "is_underlined": false
            },
            "content": {
              "url": "https://via.placeholder.com/800x400?text=इवेंट+इमेज"
            },
            "z_index": 0,
            "nested_content": null
          },
          {
            "box": {
              "rotation": 0,
              "alignment": "center",
              "x_percent": 10,
              "y_percent": 80,
              "width_percent": 80,
              "height_percent": 10
            },
            "tag": "TemplateElementTag.defaulty",
            "type": "text",
            "group": "footer",
            "style": {
              "color": "#0066CC",
              "opacity": 1,
              "font_size": 3.5,
              "is_italic": false,
              "box_shadow": null,
              "decorations": null,
              "font_family": "Tiro Devanagari Hindi",
              "font_weight": "FontWeight.w500",
              "image_shape": null,
              "border_color": null,
              "border_style": null,
              "border_width": null,
              "is_read_only": false,
              "border_radius": null,
              "is_underlined": true
            },
            "content": {
              "text": "अभी example.com पर रजिस्टर करें",
              "localizedText": {
                "translations": {
                  "en": "Register now at example.com",
                  "hi": "अभी example.com पर रजिस्टर करें"
                },
                "defaultLanguage": "en"
              }
            },
            "z_index": 3,
            "nested_content": null
          }
        ]
      }
    ]
  },
  "current_language": "en",
  "edited_content": [
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 10,
        "y_percent": 10,
        "width_percent": 80,
        "height_percent": 15
      },
      "tag": "TemplateElementTag.title",
      "type": "text",
      "group": "header",
      "style": {
        "color": "#000000",
        "opacity": 1,
        "font_size": 6.0,
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
        "text": "Welcome to Our Event",
        "localizedText": {
          "translations": {"en": "Welcome to Our Event"},
          "defaultLanguage": "en"
        }
      },
      "z_index": 2,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 10,
        "y_percent": 30,
        "width_percent": 80,
        "height_percent": 10
      },
      "tag": "TemplateElementTag.subtitle",
      "type": "text",
      "group": "header",
      "style": {
        "color": "#555555",
        "opacity": 1,
        "font_size": 4.0,
        "is_italic": false,
        "box_shadow": null,
        "decorations": null,
        "font_family": "Poppins",
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
        "text": "Join us for an amazing day of activities and fun",
        "localizedText": {
          "translations": {
            "en": "Join us for an amazing day of activities and fun"
          },
          "defaultLanguage": "en"
        }
      },
      "z_index": 1,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 10,
        "y_percent": 45,
        "width_percent": 80,
        "height_percent": 30
      },
      "tag": "TemplateElementTag.image",
      "type": "image",
      "group": "content",
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
        "image_shape": "rectangle",
        "border_color": "#000000",
        "border_style": "solid",
        "border_width": 1,
        "is_read_only": false,
        "border_radius": 8,
        "is_underlined": false
      },
      "content": {
        "url": "https://via.placeholder.com/800x400?text=Event+Image"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 10,
        "y_percent": 80,
        "width_percent": 80,
        "height_percent": 10
      },
      "tag": "TemplateElementTag.defaulty",
      "type": "text",
      "group": "footer",
      "style": {
        "color": "#0066CC",
        "opacity": 1,
        "font_size": 3.5,
        "is_italic": false,
        "box_shadow": null,
        "decorations": null,
        "font_family": "Poppins",
        "font_weight": "FontWeight.w500",
        "image_shape": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": true
      },
      "content": {
        "text": "Register now at example.com",
        "localizedText": {
          "translations": {"en": "Register now at example.com"},
          "defaultLanguage": "en"
        }
      },
      "z_index": 3,
      "nested_content": null
    }
  ],
  "viewport": {"width": 800, "height": 1200},
  "original_width": 800,
  "original_height": 1200,
  "base_image_url":
      "https://images.unsplash.com/photo-1597589827317-4c6d6e0a90bd?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8c3F1YXJlfGVufDB8fDB8fHww"
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
        final base64Data = base64Encode(imageBytes ?? Uint8List.fromList([]));
        final anchor =
            html.AnchorElement(href: 'data:image/png;base64,$base64Data');
        anchor.download = 'image.png';
        anchor.click();
        print(json);
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

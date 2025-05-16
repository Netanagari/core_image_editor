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
    "id": 4,
    "poster": 36,
    "base_image_url": "https://netanagri-bucket.s3.amazonaws.com/poster_base_images/BJP.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250515%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250515T115537Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=ae525710287243aace749e45c5673cee62ba9393f4bb00879b3d4e9a3603e83f",
    "thumbnail_url": "https://netanagri-bucket.s3.amazonaws.com/https%3A//netanagri-bucket.s3.amazonaws.com/poster/36/content/1746721969990?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250515%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250515T115537Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=4d9aaf2194b2e21ee4f4b0a72a701210f4ee2ecfa1cfe20cc989c7dde2aabdbc",
    "original_width": 1080,
    "original_height": 1080,
    "aspect_ratio": 1.0,
    "content_json": [
        {
            "box": {
                "rotation": 0,
                "alignment": "center",
                "x_percent": 0,
                "y_percent": 0,
                "width_percent": 100,
                "height_percent": 100
            },
            "tag": "TemplateElementTag.background",
            "type": "image",
            "group": null,
            "style": {
                "color": "#000000",
                "opacity": 0.25,
                "imageFit": "BoxFit.contain",
                "font_size": 0,
                "is_italic": false,
                "box_shadow": null,
                "text_align": null,
                "decorations": null,
                "font_family": "English",
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
                "url": "https://netanagri-bucket.s3.amazonaws.com/poster/36/content/1746549917602"
            },
            "z_index": 0,
            "nested_content": null
        },
        {
            "box": {
                "x_px": 315,
                "y_px": 151,
                "rotation": 0,
                "width_px": 450,
                "alignment": "center",
                "height_px": 450,
                "x_percent": 26.3388327383154,
                "y_percent": 10.270695493342368,
                "width_percent": 47.83266415505989,
                "height_percent": 46.718507027803554
            },
            "tag": "TemplateElementTag.keyVisual",
            "type": "shape",
            "group": null,
            "style": {
                "color": "#000000",
                "opacity": 1,
                "imageFit": "BoxFit.contain",
                "font_size": 0,
                "is_italic": false,
                "box_shadow": null,
                "text_align": null,
                "decorations": null,
                "font_family": "English",
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
                "url": "https://netanagri-bucket.s3.amazonaws.com/poster/36/content/1746549919078",
                "fillColor": "#FFFFFF",
                "shapeType": "ShapeType.circle",
                "strokeColor": "#00000000",
                "strokeWidth": 2,
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
                        "text_align": null,
                        "decorations": null,
                        "font_family": "English",
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
                        "url": "https://netanagri-bucket.s3.amazonaws.com/poster/36/content/1746549919078"
                    },
                    "z_index": 0,
                    "nested_content": null
                },
                "contentFit": "BoxFit.fill",
                "contentAlignment": "Alignment.center"
            }
        },
        {
            "box": {
                "y_px": 717,
                "rotation": 0,
                "alignment": "center",
                "x_percent": 10.515334894853924,
                "y_percent": 66.08904995590017,
                "width_percent": 80,
                "height_percent": 10
            },
            "tag": "TemplateElementTag.subheading",
            "type": "text",
            "group": null,
            "style": {
                "color": "#ffffff",
                "opacity": 1,
                "imageFit": "BoxFit.contain",
                "font_size": 5,
                "is_italic": false,
                "box_shadow": null,
                "text_align": "center",
                "decorations": null,
                "font_family": "English",
                "font_weight": "FontWeight.w600",
                "image_shape": null,
                "border_color": null,
                "border_style": null,
                "border_width": null,
                "is_read_only": false,
                "border_radius": null,
                "is_underlined": false
            },
            "content": {
                "bn-IN": {
                    "text": " তাঁর জন্মদিনে শ্রদ্ধাঞ্জলি"
                },
                "en-IN": {
                    "text": " Paying Tribute on His Birth Anniversary"
                },
                "hi-IN": {
                    "text": " उनकी जयंती पर श्रद्धांजलि"
                }
            },
            "z_index": 0,
            "nested_content": null
        },
        {
            "box": {
                "x_px": 165,
                "y_px": 625,
                "rotation": 0,
                "width_px": 750,
                "alignment": "center",
                "height_px": 68,
                "x_percent": 9.778249833123477,
                "y_percent": 59.2935004757599,
                "width_percent": 80,
                "height_percent": 14.444444444444445
            },
            "tag": "TemplateElementTag.heading",
            "type": "text",
            "group": null,
            "style": {
                "color": "#ffffff",
                "opacity": 1,
                "imageFit": "BoxFit.contain",
                "font_size": 7,
                "is_italic": false,
                "box_shadow": null,
                "text_align": "center",
                "decorations": null,
                "font_family": "English",
                "font_weight": "FontWeight.w900",
                "image_shape": null,
                "border_color": null,
                "border_style": null,
                "border_width": null,
                "is_read_only": false,
                "border_radius": null,
                "is_underlined": false
            },
            "content": {
                "bn-IN": {
                    "text": "কেশব বলিরাম হেডগেওয়ার "
                },
                "en-IN": {
                    "text": "Keshav Baliram Hedgewar "
                },
                "hi-IN": {
                    "text": "केशव बलिराम हेडगेवार "
                }
            },
            "z_index": 0,
            "nested_content": null
        },
        {
            "box": {
                "x_px": 115,
                "y_px": 808,
                "rotation": 0,
                "width_px": 850,
                "alignment": "center",
                "height_px": 120,
                "x_percent": 11.974513457737276,
                "y_percent": 71.92704907538395,
                "width_percent": 80,
                "height_percent": 19.047619047619044
            },
            "tag": "TemplateElementTag.messaging",
            "type": "text",
            "group": null,
            "style": {
                "color": "#ffffff",
                "opacity": 1,
                "imageFit": "BoxFit.contain",
                "font_size": 3,
                "is_italic": false,
                "box_shadow": null,
                "text_align": "center",
                "decorations": null,
                "font_family": "English",
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
                "bn-IN": {
                    "text": "কেশব বলিরাম হেডগেওয়ার ছিলেন ভারতীয় জাতীয়তাবাদের অন্যতম পথপ্রদর্শক। তাঁর নেতৃত্বে রাষ্ট্রীয় স্বয়ংসেবক সংঘ (RSS) গঠিত হয়, যা আজও জাতীয়তাবাদী ভাবনার ভিত্তি রক্ষা করে চলেছে।"
                },
                "en-IN": {
                    "text": "Keshav Baliram Hedgewar was a pioneering nationalist thinker who founded the Rashtriya Swayamsevak Sangh (RSS), laying the foundation for a strong cultural and nationalist movement in India."
                },
                "hi-IN": {
                    "text": "केशव बलिराम हेडगेवार भारतीय राष्ट्रवाद के एक प्रमुख विचारक थे। उनके नेतृत्व में राष्ट्रीय स्वयंसेवक संघ (RSS) की स्थापना हुई, जो आज भी राष्ट्रभक्ति और संस्कृति की रक्षा करता है।"
                }
            },
            "z_index": 0,
            "nested_content": null
        }
    ],
    "language_settings": {
        "current_language": "en-IN",
        "default_language": {
            "code": "en",
            "name": "English",
            "flagEmoji": "🇬🇧",
            "nativeName": "English",
            "textDirection": "TextDirection.ltr"
        },
        "enabled_languages": [
            {
                "code": "en-IN",
                "name": "English",
                "flagEmoji": null,
                "nativeName": "English",
                "textDirection": "TextDirection.ltr"
            },
            {
                "code": "bn-IN",
                "name": "Bengali",
                "flagEmoji": null,
                "nativeName": "Bengali",
                "textDirection": "TextDirection.ltr"
            },
            {
                "code": "hi-IN",
                "name": "Hindi",
                "flagEmoji": null,
                "nativeName": "Hindi",
                "textDirection": "TextDirection.ltr"
            }
        ]
    }
};

// final exampleJson = {
//   "id": 3,
//   "poster": 1,
//   "base_image_url":
//       "https://netanagri-bucket.s3.amazonaws.com/poster_base_images/1.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250505%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250505T165718Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=08dbc6b9ad2aee40e3cd46126a4c2340dddd63dceed518401eb4d4f268f00c87",
//   "thumbnail_url":
//       "https://netanagri-bucket.s3.amazonaws.com/https%3A//netanagri-bucket.s3.amazonaws.com/poster/1/content/1746461299024?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250505%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250505T165718Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=3017747e2fda42a0fd3ac3b48a6763987015c10dfad6bf4b4c10ef3bc24e08cf",
//   "original_width": 1080,
//   "original_height": 1080,
//   "aspect_ratio": 1.0,
//   "content_json": [
//     {
//       "box": {
//         "rotation": 0,
//         "alignment": "center",
//         "x_percent": 0,
//         "y_percent": 0,
//         "width_percent": 100,
//         "height_percent": 100
//       },
//       "tag": "TemplateElementTag.image",
//       "type": "image",
//       "group": null,
//       "style": {
//         "color": "#000000",
//         "opacity": 0.25,
//         "imageFit": "BoxFit.contain",
//         "font_size": 0,
//         "is_italic": false,
//         "box_shadow": null,
//         "decorations": null,
//         "font_family": "English",
//         "font_weight": "FontWeight.w400",
//         "image_shape": null,
//         "border_color": null,
//         "border_style": null,
//         "border_width": null,
//         "is_read_only": false,
//         "border_radius": null,
//         "is_underlined": false
//       },
//       "content": {
//         "url":
//             "https://netanagri-bucket.s3.amazonaws.com/poster/1/content/1746459443581"
//       },
//       "z_index": 0,
//       "nested_content": null
//     },
//     {
//       "box": {
//         "rotation": 0,
//         "alignment": "center",
//         "x_percent": 26.3388327383154,
//         "y_percent": 10.270695493342368,
//         "width_percent": 47.83266415505989,
//         "height_percent": 46.718507027803554
//       },
//       "tag": "TemplateElementTag.defaulty",
//       "type": "shape",
//       "group": null,
//       "style": {
//         "color": "#000000",
//         "opacity": 1,
//         "imageFit": "BoxFit.contain",
//         "font_size": 0,
//         "is_italic": false,
//         "box_shadow": null,
//         "decorations": null,
//         "font_family": "English",
//         "font_weight": "FontWeight.w400",
//         "image_shape": null,
//         "border_color": null,
//         "border_style": null,
//         "border_width": null,
//         "is_read_only": false,
//         "border_radius": null,
//         "is_underlined": false
//       },
//       "content": {
//         "fillColor": "#FFFFFF",
//         "shapeType": "ShapeType.circle",
//         "strokeColor": "#00000000",
//         "strokeWidth": 2,
//         "isStrokeDashed": false
//       },
//       "z_index": 0,
//       "nested_content": {
//         "content": {
//           "box": {
//             "rotation": 0,
//             "alignment": "center",
//             "x_percent": 0,
//             "y_percent": 0,
//             "width_percent": 100,
//             "height_percent": 100
//           },
//           "tag": "TemplateElementTag.defaulty",
//           "type": "image",
//           "group": null,
//           "style": {
//             "color": "#000000",
//             "opacity": 1,
//             "imageFit": "BoxFit.cover",
//             "font_size": 0,
//             "is_italic": false,
//             "box_shadow": null,
//             "decorations": null,
//             "font_family": "English",
//             "font_weight": "FontWeight.w400",
//             "image_shape": null,
//             "border_color": null,
//             "border_style": null,
//             "border_width": null,
//             "is_read_only": false,
//             "border_radius": null,
//             "is_underlined": false
//           },
//           "content": {
//             "url":
//                 "https://netanagri-bucket.s3.amazonaws.com/poster/1/content/1746459815383"
//           },
//           "z_index": 0,
//           "nested_content": null
//         },
//         "contentFit": "BoxFit.fill",
//         "contentAlignment": "Alignment.center"
//       }
//     },
//     {
//       "box": {
//         "rotation": 0,
//         "alignment": "center",
//         "x_percent": 10.515334894853924,
//         "y_percent": 66.08904995590017,
//         "width_percent": 80,
//         "height_percent": 10
//       },
//       "tag": "TemplateElementTag.subtitle",
//       "type": "text",
//       "group": null,
//       "style": {
//         "color": "#ffffff",
//         "opacity": 1,
//         "imageFit": "BoxFit.contain",
//         "font_size": 4,
//         "is_italic": false,
//         "box_shadow": null,
//         "decorations": null,
//         "font_family": "English",
//         "font_weight": "FontWeight.w600",
//         "image_shape": null,
//         "border_color": null,
//         "border_style": null,
//         "border_width": null,
//         "is_read_only": false,
//         "border_radius": null,
//         "is_underlined": false
//       },
//       "content": {
//         "en": {"text": " বাংলার কন্যাদের জন্য এক অনন্য পদক্ষেপ"},
//         "fallback": "New Text Block"
//       },
//       "z_index": 0,
//       "nested_content": null
//     },
//     {
//       "box": {
//         "rotation": 0,
//         "alignment": "center",
//         "x_percent": 9.778249833123477,
//         "y_percent": 59.2935004757599,
//         "width_percent": 80,
//         "height_percent": 14.444444444444445
//       },
//       "tag": "TemplateElementTag.title",
//       "type": "text",
//       "group": null,
//       "style": {
//         "color": "#ffffff",
//         "opacity": 1,
//         "imageFit": "BoxFit.contain",
//         "font_size": 9,
//         "is_italic": false,
//         "box_shadow": null,
//         "decorations": null,
//         "font_family": "English",
//         "font_weight": "FontWeight.w900",
//         "image_shape": null,
//         "border_color": null,
//         "border_style": null,
//         "border_width": null,
//         "is_read_only": false,
//         "border_radius": null,
//         "is_underlined": false
//       },
//       "content": {
//         "en": {"text": "রূপশ্রী প্রকল্প "},
//         "be-IN": {"text": "রূপশ্রী প্রকল্প "},
//         "fallback": "New Heading"
//       },
//       "z_index": 0,
//       "nested_content": null
//     },
//     {
//       "box": {
//         "rotation": 0,
//         "alignment": "center",
//         "x_percent": 11.974513457737276,
//         "y_percent": 71.92704907538395,
//         "width_percent": 80,
//         "height_percent": 19.047619047619044
//       },
//       "tag": "TemplateElementTag.message",
//       "type": "text",
//       "group": null,
//       "style": {
//         "color": "#ffffff",
//         "opacity": 1,
//         "imageFit": "BoxFit.contain",
//         "font_size": 4,
//         "is_italic": false,
//         "box_shadow": null,
//         "decorations": null,
//         "font_family": "English",
//         "font_weight": "FontWeight.w400",
//         "image_shape": null,
//         "border_color": null,
//         "border_style": null,
//         "border_width": null,
//         "is_read_only": false,
//         "border_radius": null,
//         "is_underlined": false
//       },
//       "content": {
//         "en": {
//           "text":
//               "মমতা বন্দ্যোপাধ্যায়ের নেতৃত্বে বাংলার কন্যাদের জন্য রূপশ্রী প্রকল্প চালু – কন্যাসন্তানদের বিবাহের জন্য আর্থিক সহায়তা প্রদান।"
//         },
//         "fallback": "New Text Block"
//       },
//       "z_index": 0,
//       "nested_content": null
//     }
//   ],
//   "language_settings": {
//     "current_language": "be-IN",
//     "default_language": {
//       "code": "en",
//       "name": "English",
//       "flagEmoji": "🇬🇧",
//       "nativeName": "English",
//       "textDirection": "TextDirection.ltr"
//     },
//     "enabled_languages": [
//       {
//         "code": "en",
//         "name": "English",
//         "flagEmoji": "🇬🇧",
//         "nativeName": "English",
//         "textDirection": "TextDirection.ltr"
//       },
//       {
//         "code": "be-IN",
//         "name": "Bengali",
//         "flagEmoji": null,
//         "nativeName": "Bengali",
//         "textDirection": "TextDirection.ltr"
//       }
//     ]
//   }
// };

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

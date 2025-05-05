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
  "content_json": [],
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

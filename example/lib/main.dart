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
  "id": 1,
  "poster": 1,
  "base_image_url":
      "https://netanagri-bucket.s3.amazonaws.com/poster_base_images/WhatsApp_Image_2025-02-10_at_11.11.21_536d6b58.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250217%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250217T023011Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=061d0dd99a634c56fb7e51570ddf4bed8b7d778cda7bafba2d9218d0d271f4f4",
  "thumbnail_url":
      "https://netanagri-bucket.s3.amazonaws.com/https%3A//netanagri-bucket.s3.amazonaws.com/poster/1/content/1739703549624?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250217%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250217T023011Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=967c1272534869c299a53c79584ea6158a054d64747aa3b844bc255acb144003",
  "original_width": 739,
  "original_height": 1600,
  "aspect_ratio": 0.461875,
  "content_json": []
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: CoreImageEditor(
          onSave: (json, imageBytes) async {
            final base64Data =
                base64Encode(imageBytes ?? Uint8List.fromList([]));
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
                        Navigator.of(context)
                            .pop('https://picsum.photos/200/300');
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
        ),
      ),
    );
  }
}

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
  "id": 1,
  "poster": 1,
  "base_image_url":
      "https://plus.unsplash.com/premium_photo-1661616016088-1964194c7728?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cG9zdGVyfGVufDB8fDB8fHww",
  "thumbnail_url":
      "https://plus.unsplash.com/premium_photo-1661616016088-1964194c7728?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cG9zdGVyfGVufDB8fDB8fHww",
  "original_width": 739,
  "original_height": 1600,
  "aspect_ratio": 0.461875,
  "content_json": [
    {
      "type": "text",
      "box": {
        "x_percent": 10.139908398428515,
        "y_percent": 5.2751196426138485,
        "width_percent": 80,
        "height_percent": 12.504201680672269,
        "alignment": "center",
        "rotation": 0
      },
      "content": {"text": "Sample image"},
      "style": {
        "font_size": 7,
        "color": "#000000",
        "font_family": "Poppins",
        "font_weight": "FontWeight.w700",
        "is_italic": false,
        "imageFit": "BoxFit.contain",
        "is_underlined": false,
        "decorations": null,
        "border_style": null,
        "border_color": null,
        "border_width": null
      },
      "z_index": 0
    },
    {
      "type": "shape",
      "box": {
        "x_percent": 0,
        "y_percent": 80,
        "width_percent": 20,
        "height_percent": 20,
        "alignment": "center",
        "rotation": 0
      },
      "content": {
        "shapeType": "ShapeType.diamond",
        "fillColor": "#FFFFFF",
        "strokeColor": "#000000",
        "strokeWidth": 2,
        "isStrokeDashed": false
      },
      "style": {
        "font_size": 0,
        "color": "#000000",
        "font_family": "Roboto",
        "font_weight": "FontWeight.w400",
        "is_italic": false,
        "imageFit": "BoxFit.contain",
        "is_underlined": false,
        "decorations": null,
        "border_style": null,
        "border_color": null,
        "border_width": null
      },
      "z_index": 0
    },
    {
      "type": "shape",
      "box": {
        "x_percent": 80,
        "y_percent": 80,
        "width_percent": 20,
        "height_percent": 20,
        "alignment": "center",
        "rotation": 0
      },
      "content": {
        "shapeType": "ShapeType.hexagon",
        "fillColor": "#FFFFFF",
        "strokeColor": "#000000",
        "strokeWidth": 2,
        "isStrokeDashed": false
      },
      "style": {
        "font_size": 0,
        "color": "#000000",
        "font_family": "Roboto",
        "font_weight": "FontWeight.w400",
        "is_italic": false,
        "imageFit": "BoxFit.contain",
        "is_underlined": false,
        "decorations": null,
        "border_style": null,
        "border_color": null,
        "border_width": null
      },
      "z_index": 0
    },
    {
      "type": "shape",
      "box": {
        "x_percent": 35.05549096039877,
        "y_percent": 26.6280674315289,
        "width_percent": 23.509597602409134,
        "height_percent": 22.59333475779894,
        "alignment": "center",
        "rotation": 0
      },
      "content": {
        "shapeType": "ShapeType.star",
        "fillColor": "#FFFFFF",
        "strokeColor": "#000000",
        "strokeWidth": 2,
        "isStrokeDashed": false
      },
      "style": {
        "font_size": 0,
        "color": "#000000",
        "font_family": "Roboto",
        "font_weight": "FontWeight.w400",
        "is_italic": false,
        "imageFit": "BoxFit.contain",
        "is_underlined": false,
        "decorations": null,
        "border_style": null,
        "border_color": null,
        "border_width": null
      },
      "z_index": 0
    }
  ]
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

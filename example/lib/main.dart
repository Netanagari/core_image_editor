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
  "id": 5,
  "poster": 5,
  "base_image_url":
      "https://netanagri-bucket.s3.amazonaws.com/poster_base_images/gradient.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250404%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250404T192525Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=2f3a62f7c66631ee8df2c211f6795d285ae45bada38a8889a191d94c32a0086d",
  "thumbnail_url":
      "https://netanagri-bucket.s3.amazonaws.com/https%3A//netanagri-bucket.s3.amazonaws.com/poster/5/content/1743409416030?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU7IC7N7V53BDVH2P%2F20250404%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20250404T192525Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=8f2d39361b36fa3aca3dea257d46645ee5da4df3e41bd42ebface15662fdf84a",
  "original_width": 1200,
  "original_height": 1200,
  "aspect_ratio": 1.0,
  "content_json": [
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 0,
        "y_percent": 76.95075646238273,
        "width_percent": 15.860830295641838,
        "height_percent": 12.563229906504354
      },
      "tag": "TemplateElementTag.defaulty",
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
            "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742028986662"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 11.655742807962351,
        "y_percent": 73.85791157281803,
        "width_percent": 14.678719324607796,
        "height_percent": 15.572691556492936
      },
      "tag": "TemplateElementTag.defaulty",
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
            "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742028996977"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 23.45617875110833,
        "y_percent": 75.98284276347688,
        "width_percent": 15.701983251012882,
        "height_percent": 13.327908748971538
      },
      "tag": "TemplateElementTag.defaulty",
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
            "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742029004099"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 0,
        "y_percent": 89.47844622680574,
        "width_percent": 100,
        "height_percent": 10.521553773194254
      },
      "tag": "TemplateElementTag.defaulty",
      "type": "shape",
      "group": "user_strip",
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
        "fillColor": "#efbfb0",
        "shapeType": "ShapeType.rectangle",
        "strokeColor": "#ffffff",
        "strokeWidth": 2,
        "isStrokeDashed": false
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 0.6723887829685592,
        "y_percent": 2.013964020058426,
        "width_percent": 13.407318660132187,
        "height_percent": 9.611011678995826
      },
      "tag": "TemplateElementTag.partySymbol",
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
            "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742031058954"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 17.212925424557437,
        "y_percent": 44.782417289167846,
        "width_percent": 73.71482252003617,
        "height_percent": 24.59227059275817
      },
      "tag": "TemplateElementTag.title",
      "type": "text",
      "group": null,
      "style": {
        "color": "#668ce9",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 6.5,
        "is_italic": false,
        "box_shadow": null,
        "decorations": null,
        "font_family": "Gajraj One",
        "font_weight": "FontWeight.w900",
        "image_shape": null,
        "border_color": null,
        "border_style": null,
        "border_width": null,
        "is_read_only": false,
        "border_radius": null,
        "is_underlined": false
      },
      "content": {"text": "होली की हार्दिक शुभकामनाएं!"},
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 116.52636204228428,
        "alignment": "center",
        "x_percent": 22.404812461389422,
        "y_percent": 34.99831055964494,
        "width_percent": 16.09246539530147,
        "height_percent": 16.80928800989464
      },
      "tag": "TemplateElementTag.defaulty",
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
            "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742031323341"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 20.35255892591967,
        "y_percent": 58.96485617238527,
        "width_percent": 61.9364635175845,
        "height_percent": 7.246999372561389
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
        "font_family": "Yatra One",
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
        "text": "रंगों के इस पर्व पर आपके जीवन में खुशियों की बौछार हो"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "right",
        "x_percent": 25.724826150061546,
        "y_percent": 0,
        "width_percent": 74.27517384993845,
        "height_percent": 15.671984258719784
      },
      "tag": "TemplateElementTag.leaderPhotoStrip",
      "type": "leader_strip",
      "group": "leader_strip",
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
                  "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742032516631"
            },
            "z_index": 0,
            "nested_content": null
          },
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
                  "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742031631484"
            },
            "z_index": 0,
            "nested_content": null
          }
        ],
        "spacing": 8,
        "stripSize": "medium"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 70,
        "y_percent": 70,
        "width_percent": 30,
        "height_percent": 30
      },
      "tag": "TemplateElementTag.userPicture",
      "type": "image",
      "group": "user_strip",
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
            "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742031776126"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 52.39568553106911,
        "y_percent": 89.46669621353281,
        "width_percent": 22.43332862196072,
        "height_percent": 7.803889075874767
      },
      "tag": "TemplateElementTag.userName",
      "type": "text",
      "group": "user_strip",
      "style": {
        "color": "#6282f3",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 11,
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
      "content": {"text": "राजेश यादव"},
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 51.972449356550925,
        "y_percent": 94.33937138983174,
        "width_percent": 23.130423497637707,
        "height_percent": 4.014200581431188
      },
      "tag": "TemplateElementTag.userDesignation",
      "type": "text",
      "group": "user_strip",
      "style": {
        "color": "#444444",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 8.5,
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
      "content": {"text": "पूर्व केंद्रीय मंत्री"},
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 1.641413135444603,
        "y_percent": 92.880911797595,
        "width_percent": 3.5110498886314923,
        "height_percent": 3.704978538255895
      },
      "tag": "TemplateElementTag.defaulty",
      "type": "image",
      "group": "user_strip",
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
        "url":
            "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742032083222"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 2.7971230609090645,
        "y_percent": 92.23295424868095,
        "width_percent": 15.772927770332714,
        "height_percent": 47.61904761904762
      },
      "tag": "TemplateElementTag.defaulty",
      "type": "text",
      "group": null,
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 8.5,
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
      "content": {"text": "@bjpindia"},
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 3.642940245588552,
        "y_percent": 92.63063901328243,
        "width_percent": 10.0598945786943,
        "height_percent": 4.586222798864398
      },
      "tag": "TemplateElementTag.defaulty",
      "type": "text",
      "group": "user_strip",
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 12.5,
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
      "content": {"text": "@bjpindia"},
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 12.6226229204276,
        "y_percent": 92.79901625299004,
        "width_percent": 3.369534387554207,
        "height_percent": 4.140007671197182
      },
      "tag": "TemplateElementTag.defaulty",
      "type": "image",
      "group": "user_strip",
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
        "url":
            "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742032206819"
      },
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0.2740470108596469,
        "alignment": "center",
        "x_percent": 14.035812438129906,
        "y_percent": 93.37621605136546,
        "width_percent": 11.814424726309866,
        "height_percent": 3.090636692773053
      },
      "tag": "TemplateElementTag.defaulty",
      "type": "text",
      "group": "user_strip",
      "style": {
        "color": "#000000",
        "opacity": 1,
        "imageFit": "BoxFit.contain",
        "font_size": 11,
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
      "content": {"text": "@bjpindia"},
      "z_index": 0,
      "nested_content": null
    },
    {
      "box": {
        "rotation": 0,
        "alignment": "center",
        "x_percent": 29.69555089530216,
        "y_percent": 10.520572026872491,
        "width_percent": 44.03689634528136,
        "height_percent": 44.88336869431768
      },
      "tag": "TemplateElementTag.image",
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
            "https://netanagri-bucket.s3.amazonaws.com/poster/5/content/1742032365006"
      },
      "z_index": 0,
      "nested_content": null
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

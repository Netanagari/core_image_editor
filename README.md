# Core Image Editor

A flexible, configuration-driven template editor for Flutter that allows different levels of editing capabilities based on user roles.

## Features

- 🎨 Rich template editing capabilities
- 👥 Role-based editing permissions
- 📱 Responsive design (works on both mobile and desktop)
- 🔄 Undo/Redo support
- 📐 Shape manipulation with multiple shape types
- 🖼️ Image handling with various fit options
- ✍️ Text editing with Google Fonts support
- 🎯 Precise positioning with drag and resize
- 🎭 Multiple border styles
- 📚 Z-index management

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  core_image_editor:
    git:
      url: https://github.com/yourusername/core_image_editor.git
      ref: main  # or specific tag/commit
```

Or install via command line:

```bash
flutter pub add core_image_editor --git-url=https://github.com/yourusername/core_image_editor.git --git-ref=main
```

## Basic Usage

```dart
import 'package:core_image_editor/core_image_editor.dart';
import 'package:core_image_editor/models/editor_config.dart';

class MyEditorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CoreImageEditor(
        template: myTemplateData,
        onSave: (updatedTemplate) {
          // Handle save
        },
        onSelectImage: (context) async {
          // Handle image selection
          return "image_url";
        },
        // Optional: Configure editor capabilities
        configuration: EditorConfiguration.admin, // or EditorConfiguration.endUser
      ),
    );
  }
}
```

## Template Data Structure

The template should follow this structure:

```dart
final templateData = {
  "id": 4,
  "base_image": "https://picsum.photos/512/512",
  "original_width": 512,
  "original_height": 512,
  "aspect_ratio": 1.0,
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
  ],
  "user_id": 1,
  "poster": 1
};
```

## User Roles and Capabilities

The editor supports different user roles through the `EditorConfiguration` class:

```dart
// For admin users (full access)
CoreImageEditor(
  configuration: EditorConfiguration.admin,
  // ... other props
)

// For end users (restricted access)
CoreImageEditor(
  configuration: EditorConfiguration.endUser,
  // ... other props
)

// Custom configuration
CoreImageEditor(
  configuration: EditorConfiguration(
    capabilities: {
      EditorCapability.changeTextContent,
      EditorCapability.changeColors,
      // Add specific capabilities as needed
    },
  ),
  // ... other props
)
```

Available capabilities:
- `addElements`: Allow adding new elements
- `deleteElements`: Allow deleting elements
- `repositionElements`: Allow moving elements
- `resizeElements`: Allow resizing elements
- `changeColors`: Allow color modifications
- `changeFonts`: Allow font modifications
- `changeTextContent`: Allow text content editing
- `changeBorders`: Allow border style modifications
- `changeAlignment`: Allow alignment modifications
- `changeZIndex`: Allow layer order modifications
- `modifyShapeProperties`: Allow shape property modifications
- `changeImageFit`: Allow image fit modifications
- `uploadNewImage`: Allow uploading new images
- `undoRedo`: Allow undo/redo operations

## Required Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^5.1.0
  flutter_colorpicker: ^1.0.3
```

## Additional Setup

### Android

No additional setup required.

### iOS

Add the following to your `Info.plist`:

```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
```

### Web

No additional setup required.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- Flutter Team for the amazing framework
- All contributors who participate in this project

## Troubleshooting

### Common Issues

1. **Elements not draggable**: Check if the configuration includes `repositionElements` capability.
2. **Can't modify text**: Verify that `changeTextContent` capability is enabled.
3. **No resize handles**: Ensure `resizeElements` capability is included in the configuration.

For more issues, please check the [Issues](https://github.com/yourusername/core_image_editor/issues) section.

## Command to generate poster via skia command line
python generate_thumbnial_skia.py --json sample_content.json --lang bn-IN --base_image_url https://netanagri-bucket.s3.amazonaws.com/poster_base_images/BJP.png\?X-Amz-Algorithm\=AWS4-HMAC-SHA256\&X-Amz-Credential\=AKIAU7IC7N7V53BDVH2P%2F20250508%2Fap-southeast-1%2Fs3%2Faws4_request\&X-Amz-Date\=20250508T114655Z\&X-Amz-Expires\=3600\&X-Amz-SignedHeaders\=host\&X-Amz-Signature\=72e33ef645c473bfae5f61af5268ded6d633a60d2d252acd2d0fc221bf2bb247 --output generated_skia_image.png
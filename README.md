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
  'original_width': 800,
  'original_height': 600,
  'base_image': '/path/to/background.jpg',
  'content_json': [
    {
      'type': 'text',
      'box': {
        'x_percent': 10,
        'y_percent': 10,
        'width_percent': 80,
        'height_percent': 10,
        'alignment': 'center'
      },
      'content': {
        'text': 'Sample Text'
      },
      'style': {
        'font_size': 4.0,
        'color': '#000000',
        'font_family': 'Roboto'
      }
    }
    // ... more elements
  ]
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
import 'package:core_image_editor/models/editor_config.dart';
import 'package:core_image_editor/models/language_support.dart';
import 'package:core_image_editor/state/editor_state.dart';
import 'package:core_image_editor/state/history_state.dart';
import 'package:core_image_editor/utils/responsive_utils.dart';
import 'package:core_image_editor/widgets/editor_element.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template_types.dart';

class ImageFromJsonWidget extends StatelessWidget {
  final Map<String, dynamic> contentJson;

  const ImageFromJsonWidget({
    super.key,
    required this.contentJson,
  });

  @override
  Widget build(BuildContext context) {
    // Extract base image URL and elements from the content JSON
    final String baseImageUrl = contentJson['base_image_url'] ?? '';
    final List<dynamic> elementsJson = contentJson['content_json'] ?? [];

    // Parse elements from JSON
    final List<TemplateElement> elements = elementsJson
        .map((elementJson) => TemplateElement.fromJson(elementJson))
        .toList();

    // Sort elements by z-index
    elements.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return IgnorePointer(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) =>
                LanguageManager()..updateAvailableLanguages(contentJson),
          ),
          ChangeNotifierProvider(
            create: (context) => EditorState(
              initialElements: (contentJson['content_json'] as List? ?? [])
                  .map((e) => TemplateElement.fromJson(e))
                  .toList(),
              configuration: EditorConfiguration.admin,
              canvasAspectRatio: (contentJson['original_width'] as double) /
                  (contentJson['original_height'] as double),
              initialViewportSize: Size.zero,
              originalWidth:
                  (contentJson['original_width'] as double?)?.toDouble() ??
                      1080.0,
              originalHeight:
                  (contentJson['original_height'] as double?)?.toDouble() ??
                      1080.0,
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => HistoryState(),
          ),
        ],
        child: LayoutBuilder(builder: (context, constraints) {
          final editorState = context.watch<EditorState>();
          final viewportSize = ResponsiveUtils.calculateViewportSize(
            constraints,
            1,
          );

          if (viewportSize != editorState.viewportSize) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              editorState.setViewportSize(viewportSize);
            });
          }

          return SizedBox(
            width: 1080,
            height: 1080,
            child: Stack(
              children: [
                // Base image
                if (baseImageUrl.isNotEmpty)
                  Image.network(
                    baseImageUrl,
                    width: viewportSize.width,
                    height: viewportSize.height,
                    fit: BoxFit.contain,
                  ),

                // Render all elements
                ...elements.map((element) => EditorElement(element: element)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

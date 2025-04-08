import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/language_support.dart';
import '../../models/template_types.dart';
import '../../state/editor_state.dart';
import '../../state/history_state.dart';

class CopyTranslationsTool extends StatelessWidget {
  final TemplateElement currentElement;
  final VoidCallback onUpdate;

  const CopyTranslationsTool({
    super.key,
    required this.currentElement,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // Only show for text elements
    if (currentElement.type != 'text') {
      return const SizedBox.shrink();
    }

    final editorState = Provider.of<EditorState>(context);
    final historyState = Provider.of<HistoryState>(context);
    final languageManager = Provider.of<LanguageManager>(context);

    // Get all text elements except the current one
    final otherTextElements = editorState.elements
        .where((element) => element.type == 'text' && element != currentElement)
        .toList();

    if (otherTextElements.isEmpty) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      title: Row(
        children: [
          const Icon(Icons.content_copy, size: 16),
          const SizedBox(width: 8),
          const Text('Copy Translations'),
        ],
      ),
      subtitle: const Text('Copy translations from other elements'),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select source element:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // List of other text elements to copy from
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: otherTextElements.length,
                itemBuilder: (context, index) {
                  final sourceElement = otherTextElements[index];

                  // Only show elements with multilingual content
                  if (!sourceElement.hasMultilingualContent) {
                    return const SizedBox.shrink();
                  }

                  // Get available languages in source element
                  final availableLanguages = sourceElement.content.keys
                      .where((key) =>
                          key != 'fallback' &&
                          sourceElement.content[key] is Map &&
                          (sourceElement.content[key] as Map)
                              .containsKey('text'))
                      .toList();

                  if (availableLanguages.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            sourceElement.tag.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${availableLanguages.length} languages',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        sourceElement.getTextContent('fallback'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Button to view available translations
                          IconButton(
                            icon: const Icon(Icons.preview),
                            tooltip: 'View Translations',
                            onPressed: () {
                              _showTranslationsPreview(
                                context,
                                sourceElement,
                                languageManager,
                              );
                            },
                          ),

                          // Button to copy all translations
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy All Translations',
                            onPressed: () {
                              _copyTranslations(
                                sourceElement,
                                currentElement,
                                availableLanguages,
                              );
                              onUpdate();
                              historyState.pushState(
                                editorState.elements,
                                currentElement,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Copied ${availableLanguages.length} translations!',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _copyTranslations(
    TemplateElement source,
    TemplateElement target,
    List<String> languagesToCopy,
  ) {
    // Ensure target has multilingual structure
    if (!target.hasMultilingualContent) {
      target.convertToMultilingual();
    }

    // Copy each language
    for (final langCode in languagesToCopy) {
      if (source.content.containsKey(langCode) &&
          source.content[langCode] is Map &&
          (source.content[langCode] as Map).containsKey('text')) {
        final text = source.getTextContent(langCode);
        target.setTextContent(langCode, text);
      }
    }
  }

  void _showTranslationsPreview(
    BuildContext context,
    TemplateElement element,
    LanguageManager languageManager,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 500,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Translations for ${element.tag.displayName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fallback: ${element.getTextContent('fallback')}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        element.content.length - 1, // Subtract 1 for fallback
                    itemBuilder: (context, index) {
                      final keys = element.content.keys
                          .where((key) => key != 'fallback')
                          .toList();

                      if (index >= keys.length) {
                        return const SizedBox.shrink();
                      }

                      final langCode = keys[index];

                      // Skip if not a valid language entry
                      if (element.content[langCode] is! Map ||
                          !(element.content[langCode] as Map)
                              .containsKey('text')) {
                        return const SizedBox.shrink();
                      }

                      final text = element.getTextContent(langCode);
                      final langModel =
                          languageManager.getLanguageModel(langCode);

                      return ListTile(
                        leading: langModel?.flagEmoji != null
                            ? Text(
                                langModel!.flagEmoji!,
                                style: const TextStyle(fontSize: 24),
                              )
                            : const Icon(Icons.language),
                        title: Text(
                          langModel?.name ?? langCode,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          text,
                          textDirection: languageManager.isRtl(langCode)
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

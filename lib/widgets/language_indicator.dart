import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_support.dart';
import '../models/template_types.dart';

class LanguageIndicator extends StatelessWidget {
  final TemplateElement element;

  const LanguageIndicator({
    super.key,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    // Only show for text elements with multilingual content
    if (element.type != 'text' || !element.hasMultilingualContent) {
      return const SizedBox.shrink();
    }

    final languageManager = Provider.of<LanguageManager>(context);
    final enabledLanguages = languageManager.enabledLanguages;

    // Get all languages that have content for this element
    final availableLanguages = element.content.keys
        .where((key) => key != 'fallback' && element.content[key] is Map)
        .toList();

    // Count how many languages are missing content
    final missingLanguages = enabledLanguages
        .where((lang) => !availableLanguages.contains(lang))
        .length;

    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.language,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 2),
            Text(
              '${availableLanguages.length}/${enabledLanguages.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (missingLanguages > 0) ...[
              const SizedBox(width: 2),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$missingLanguages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

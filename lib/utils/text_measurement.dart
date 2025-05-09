import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template_types.dart';
import '../models/language_support.dart';
import 'responsive_utils.dart';

class TextMeasurement {
  static Size measureText({
    required String text,
    required TemplateElement element,
    required Size viewportSize,
    required BuildContext context,
  }) {
    // Convert font size from vw to pixels
    double fontSizePixels = ResponsiveUtils.vwToPixels(
      element.style.fontSizeVw,
      viewportSize.width,
    );

    // Calculate the maximum width in pixels
    double maxWidthPixels = ResponsiveUtils.percentToPixelX(
      element.box.widthPercent,
      viewportSize.width,
    );

    // Get text direction
    TextDirection textDirection = TextDirection.ltr;
    late LanguageManager languageManager;
    if (context.mounted) {
      languageManager = Provider.of<LanguageManager>(context, listen: false);
      final currentLanguage = languageManager.currentLanguage;
      textDirection = languageManager.isRtl(currentLanguage)
          ? TextDirection.rtl
          : TextDirection.ltr;
    }

    // Create text painter with the same style as the element
    final textStyle = TextStyle(
      fontFamily: languageManager.currentLanguageModel.fontFamily,
      package: 'core_image_editor',
      fontSize: fontSizePixels,
      color: Color(int.parse(element.style.color.replaceFirst('#', '0xff'))),
      fontWeight: element.style.fontWeight,
      fontStyle: element.style.isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: element.style.isUnderlined ? TextDecoration.underline : null,
    );

    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: textDirection,
      maxLines: null, // Allow unlimited lines for height measurement
    );

    // Layout with constraints
    textPainter.layout(maxWidth: maxWidthPixels);

    return Size(textPainter.width, textPainter.height);
  }

  static double calculateRequiredHeightPercent({
    required String text,
    required TemplateElement element,
    required Size viewportSize,
    required BuildContext context,
  }) {
    Size textSize = measureText(
      text: text,
      element: element,
      viewportSize: viewportSize,
      context: context,
    );

    // Convert height from pixels back to percentage and add padding
    double heightPercent = ResponsiveUtils.pixelToPercentY(
      textSize.height,
      viewportSize.height,
    );

    // Add 20% padding to ensure text fits comfortably
    return heightPercent * 1.2;
  }

  static void adjustBoxHeight({
    required TemplateElement element,
    required String newText,
    required Size viewportSize,
    required BuildContext context,
  }) {
    if (element.type != 'text') return;

    double requiredHeight = calculateRequiredHeightPercent(
      text: newText,
      element: element,
      viewportSize: viewportSize,
      context: context,
    );

    // Update height if required height is greater than current height
    if (requiredHeight > element.box.heightPercent) {
      element.box.heightPercent = requiredHeight.clamp(0.0, 100.0);
    }
  }

  // New method to check and adjust element height for all languages
  static void adjustBoxHeightForAllLanguages({
    required TemplateElement element,
    required Size viewportSize,
    required BuildContext context,
  }) {
    if (element.type != 'text' || !element.hasMultilingualContent) return;

    // Get the language manager
    final languageManager =
        Provider.of<LanguageManager>(context, listen: false);
    final enabledLanguages = languageManager.enabledLanguages;

    double maxRequiredHeight = 0;

    // Check height requirements for all languages
    for (final lang in enabledLanguages) {
      final text = element.getTextContent(lang.code);
      double requiredHeight = calculateRequiredHeightPercent(
        text: text,
        element: element,
        viewportSize: viewportSize,
        context: context,
      );

      maxRequiredHeight = max(maxRequiredHeight, requiredHeight);
    }

    // Update height if any language requires more height
    if (maxRequiredHeight > element.box.heightPercent) {
      element.box.heightPercent = maxRequiredHeight.clamp(0.0, 100.0);
    }
  }
}

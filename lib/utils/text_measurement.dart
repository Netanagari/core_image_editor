import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/template_types.dart';
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

    // Create text painter with the same style as the element
    final textStyle = GoogleFonts.getFont(
      element.style.fontFamily,
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
      textDirection: TextDirection.ltr,
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
}

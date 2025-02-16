import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/template_types.dart';

class FontFamilyControl extends StatelessWidget {
  final TemplateElement element;
  final List<String> availableFonts;
  final VoidCallback onUpdate;

  const FontFamilyControl({
    super.key,
    required this.element,
    required this.availableFonts,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Font Family'),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: element.style.fontFamily,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: availableFonts.map((String font) {
              return DropdownMenuItem<String>(
                value: font,
                child: Text(
                  font,
                  style: GoogleFonts.getFont(font),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                element.style.fontFamily = newValue;
                onUpdate();
              }
            },
          ),
        ],
      ),
    );
  }
}

class FontWeightControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const FontWeightControl({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Font Weight'),
          const SizedBox(height: 4),
          DropdownButtonFormField<FontWeight>(
            value: element.style.fontWeight,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: FontWeight.w100,
                child: Text(
                  'Thin (100)',
                  style: TextStyle(fontWeight: FontWeight.w100),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w200,
                child: Text(
                  'Extra-Light (200)',
                  style: TextStyle(fontWeight: FontWeight.w200),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w300,
                child: Text(
                  'Light (300)',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w400,
                child: Text(
                  'Regular (400)',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w500,
                child: Text(
                  'Medium (500)',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w600,
                child: Text(
                  'Semi-Bold (600)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w700,
                child: Text(
                  'Bold (700)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w800,
                child: Text(
                  'Extra-Bold (800)',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              DropdownMenuItem(
                value: FontWeight.w900,
                child: Text(
                  'Black (900)',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
            onChanged: (FontWeight? newValue) {
              if (newValue != null) {
                element.style.fontWeight = newValue;
                onUpdate();
              }
            },
          ),
        ],
      ),
    );
  }
}

class FontStyleControl extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;

  const FontStyleControl({
    super.key,
    required this.element,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Text Style'),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Italic'),
                selected: element.style.isItalic,
                onSelected: (bool selected) {
                  element.style.isItalic = selected;
                  onUpdate();
                },
              ),
              FilterChip(
                label: const Text('Underline'),
                selected: element.style.isUnderlined,
                onSelected: (bool selected) {
                  element.style.isUnderlined = selected;
                  onUpdate();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

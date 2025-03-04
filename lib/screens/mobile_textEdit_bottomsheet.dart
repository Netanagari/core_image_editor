import 'package:core_image_editor/utils/app_color.dart';
import 'package:core_image_editor/utils/app_text_style.dart';
import 'package:flutter/material.dart';

class MobileTextEditBottomSheet extends StatefulWidget {
  const MobileTextEditBottomSheet({super.key});

  @override
  State<MobileTextEditBottomSheet> createState() =>
      _MobileTextEditBottomSheetState();
}

class _MobileTextEditBottomSheetState extends State<MobileTextEditBottomSheet> {
  String headerText = "This is poster header";
  String subtitleText = "This is poster subtitle";
  String bodyText = "This is poster subtitle";
  double selectedFontSize = 16.0; // Medium by default
  FontStyle fontStyle = FontStyle.normal;
  FontWeight fontWeight = FontWeight.normal;
  bool isUnderlined = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          TextEditorView(
              label: "Heading",
              value: headerText,
              onChanged: (value) {
                setState(() => headerText = value);
              }),
          TextEditorView(
              label: "Sub Heading",
              value: subtitleText,
              onChanged: (value) {
                setState(() => subtitleText = value);
              }),
          TextEditorView(
              label: "Text",
              value: bodyText,
              onChanged: (value) {
                setState(() => bodyText = value);
              }),
          const SizedBox(height: 16),
          _buildFontSizeSelector(),
          const SizedBox(height: 16),
          _buildFontStyleSelector(),
        ],
      ),
    );
  }

  Widget _buildFontSizeSelector() {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text("Font Size",
              style: AppTextStyles.labelSmRegular
                  .copyWith(color: AppColors.secondary100)),
        ),
        _buildFontSizeOption("Small", 12.0),
        const SizedBox(width: 12),
        _buildFontSizeOption("Medium", 16.0, isSelected: true),
        const SizedBox(width: 12),
        _buildFontSizeOption("Large", 20.0),
      ],
    );
  }

  Widget _buildFontSizeOption(String label, double fontSize,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFontSize = fontSize;
        });
      },
      child: Column(
        children: [
          Container(
            width: 12 + fontSize,
            height: 12 + fontSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: selectedFontSize == fontSize ? Colors.black : Colors.white,
            ),
            child: Center(
              child: Text(
                'T',
                style: TextStyle(
                  fontSize: fontSize,
                  color: selectedFontSize == fontSize
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.secondary100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontStyleSelector() {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "Font Style",
            style: AppTextStyles.labelSmRegular
                .copyWith(color: AppColors.secondary100),
          ),
        ),
        _buildStyleOption(
            "B", "Bold", FontWeight.bold, fontWeight == FontWeight.bold),
        const SizedBox(width: 12),
        _buildUnderlineOption("U", isUnderlined),
        const SizedBox(width: 12),
        _buildItalicOption("I", fontStyle == FontStyle.italic),
      ],
    );
  }

  Widget _buildStyleOption(
      String text, String styleName, FontWeight weight, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          fontWeight = isSelected ? FontWeight.normal : weight;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.black : Colors.white,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: weight,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnderlineOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isUnderlined = !isUnderlined;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.black : Colors.white,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItalicOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          fontStyle = isSelected ? FontStyle.normal : FontStyle.italic;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.black : Colors.white,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class TextEditorView extends StatelessWidget {
  const TextEditorView({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Function(String p1) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label,
                style: AppTextStyles.labelSmRegular
                    .copyWith(color: AppColors.secondary100)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: AppColors.primary100,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.tertiary100.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 1)),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                style: AppTextStyles.labelSmMedium
                    .copyWith(color: AppColors.secondary100),
                decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: "Enter text",
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintStyle: AppTextStyles.labelSmRegular
                        .copyWith(color: AppColors.tertiary100),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

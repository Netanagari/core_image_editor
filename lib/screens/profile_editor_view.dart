import 'package:core_image_editor/screens/mobile_textEdit_bottomsheet.dart';
import 'package:core_image_editor/utils/app_color.dart';
import 'package:core_image_editor/utils/app_text_style.dart';
import 'package:flutter/material.dart';

class ProfileEditorScreen extends StatefulWidget {
  const ProfileEditorScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  String name = "Name";
  String designation = "Designation";
  String party = "BJP";
  String selectedImageSize = "Medium";
  String selectedImageShape = "Circle";
  double selectedSize = 64; // Circle

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image and edit buttons
          Center(
            child: Stack(
              children: [
                // Profile image
                Container(
                  width: selectedSize + 24,
                  height: selectedSize + 24,
                  decoration: BoxDecoration(
                    shape: selectedImageShape == "Rectangle"
                        ? BoxShape.rectangle
                        : BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                ),

                // Edit button
                Positioned(
                  bottom: 4,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Name field
          TextEditorView(
              label: "Name",
              value: name,
              onChanged: (value) {
                setState(() => name = value);
              }),

          const SizedBox(height: 8),

          // Designation field
          TextEditorView(
              label: "Designation",
              value: designation,
              onChanged: (value) {
                setState(() => designation = value);
              }),

          const SizedBox(height: 5),

          // Party selector
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text('Party',
                    style: AppTextStyles.labelSmRegular
                        .copyWith(color: AppColors.secondary100)),
              ),
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Party logo
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1496200186974-4293800e2c20?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8YmhhanBhJTIwbG9nb3xlbnwwfHwwfHx8MA%3D%3D',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Party name
                      Text('BJP',
                          style: AppTextStyles.labelSmRegular
                              .copyWith(color: AppColors.secondary100)),
                      const Spacer(),
                      // Dropdown icon
                      const Icon(Icons.arrow_drop_down),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Delete button
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Image Size selector
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text('Image Size',
                    style: AppTextStyles.labelSmRegular
                        .copyWith(color: AppColors.secondary100)),
              ),
              _buildSizeOption("Small", "Small", 24,
                  isSelected: selectedImageSize == "Small"),
              const SizedBox(width: 8),
              _buildSizeOption("Medium", "Medium", 48,
                  isSelected: selectedImageSize == "Medium"),
              const SizedBox(width: 8),
              _buildSizeOption("Large", "Large", 64,
                  isSelected: selectedImageSize == "Large"),
            ],
          ),

          const SizedBox(height: 24),

          // Image Shape selector
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text('Image Shape',
                    style: AppTextStyles.labelSmRegular
                        .copyWith(color: AppColors.secondary100)),
              ),
              _buildShapeOption("Rectangle", "Rectangle",
                  isSelected: selectedImageShape == "Rectangle"),
              const SizedBox(width: 16),
              _buildShapeOption(
                "Circle",
                "Circle",
                isSelected: selectedImageShape == "Circle",
                isCircle: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String value, String label, double size,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImageSize = value;
          selectedSize = size;
        });
      },
      child: Container(
        width: 24 + size / 3,
        height: 24 + size / 3,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.black : Colors.white,
        ),
        child: Center(
          child: Icon(
            Icons.person,
            color: isSelected ? Colors.white : Colors.black,
            size: 12 + size * 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildShapeOption(String value, String label,
      {bool isSelected = false, bool isCircle = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImageShape = value;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(color: AppColors.secondary100, width: 1),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}

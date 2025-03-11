import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/editor_state.dart';

class CanvasSettingsControl extends StatelessWidget {
  final Function(double) onAspectRatioChanged;
  final Function(Color) onBackgroundColorChanged;
  final Function(String) onBackgroundImageChanged;
  final Future<String> Function(BuildContext) onSelectImage;

  const CanvasSettingsControl({
    Key? key,
    required this.onAspectRatioChanged,
    required this.onBackgroundColorChanged,
    required this.onBackgroundImageChanged,
    required this.onSelectImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final theme = Theme.of(context);

    return ExpansionTile(
      title: Text(
        'Canvas Settings',
        style: theme.textTheme.titleMedium,
      ),
      initiallyExpanded: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aspect Ratio',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildAspectRatioOption(context, '1:1', 1.0),
                    const SizedBox(width: 8),
                    _buildAspectRatioOption(context, '4:3', 4 / 3),
                    const SizedBox(width: 8),
                    _buildAspectRatioOption(context, '3:4', 3 / 4),
                    const SizedBox(width: 8),
                    _buildAspectRatioOption(context, '16:9', 16 / 9),
                    const SizedBox(width: 8),
                    _buildAspectRatioOption(context, '9:16', 9 / 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Background',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildColorPicker(context, editorState.backgroundColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Set Background Image'),
                      onPressed: () async {
                        final imageUrl = await onSelectImage(context);
                        if (imageUrl.isNotEmpty) {
                          onBackgroundImageChanged(imageUrl);
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (editorState.backgroundImageUrl != null &&
                  editorState.backgroundImageUrl!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Image: ${editorState.backgroundImageUrl}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onBackgroundImageChanged(''),
                      tooltip: 'Remove background image',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAspectRatioOption(
      BuildContext context, String label, double ratio) {
    final editorState = context.watch<EditorState>();
    final isSelected = (editorState.canvasAspectRatio - ratio).abs() < 0.01;

    return InkWell(
      onTap: () => onAspectRatioChanged(ratio),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey[400]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context, Color currentColor) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Select Background Color'),
              content: SingleChildScrollView(
                child: ColorPickerGrid(
                    currentColor: currentColor,
                    onColorSelected: (color) {
                      onBackgroundColorChanged(color);
                      Navigator.of(context).pop();
                    }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!),
        ),
      ),
    );
  }
}

class ColorPickerGrid extends StatelessWidget {
  final Color currentColor;
  final Function(Color) onColorSelected;

  const ColorPickerGrid({
    Key? key,
    required this.currentColor,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a color palette
    final colors = [
      Colors.transparent,
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    return SizedBox(
      width: 300,
      height: 300,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = color.value == currentColor.value;

          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[400]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                image: color == Colors.transparent
                    ? const DecorationImage(
                        image: NetworkImage(
                          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAGElEQVQYlWNgYGCQwoKxgqGgcJA5h3yFAAs8BRWVSwooAAAAAElFTkSuQmCC',
                        ),
                        repeat: ImageRepeat.repeat,
                      )
                    : null,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

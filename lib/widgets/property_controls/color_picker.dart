import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NColorPicker extends StatelessWidget {
  final String label;
  final String color;
  final Function(String) onColorChanged;

  const NColorPicker({
    super.key,
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _showColorPicker(context),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Color(
                  int.parse(color.replaceFirst('#', '0xff')),
                ),
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
                image: color == '#00000000'
                    ? const DecorationImage(
                        image: NetworkImage(
                          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAGElEQVQYlWNgYGCQwoKxgqGgcJA5h3yFAAs8BRWVSwooAAAAAElFTkSuQmCC',
                        ),
                        repeat: ImageRepeat.repeat,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick $label'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add transparent color option
            InkWell(
              onTap: () {
                onColorChanged('#00000000');
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAGElEQVQYlWNgYGCQwoKxgqGgcJA5h3yFAAs8BRWVSwooAAAAAElFTkSuQmCC',
                    ),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Transparent',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            ColorPicker(
              pickerColor: Color(
                int.parse(color.replaceFirst('#', '0xff')),
              ),
              onColorChanged: (color) {
                onColorChanged(
                  '#${color.value.toRadixString(16).substring(2)}',
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

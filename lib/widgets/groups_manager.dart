import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template_types.dart';
import '../state/editor_state.dart';

class GroupsManager extends StatelessWidget {
  const GroupsManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final groups = editorState.availableGroups;

    if (groups.isEmpty) {
      return const Center(
        child: Text('No groups created yet'),
      );
    }

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final elementsInGroup = editorState.getElementsByGroup(group);
        
        return ExpansionTile(
          title: Row(
            children: [
              Icon(Icons.folder, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(group),
              const SizedBox(width: 8),
              Text(
                '(${elementsInGroup.length})',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          children: [
            ...elementsInGroup.map((element) => ListTile(
                  leading: _getIconForElementType(element.type),
                  title: Text(
                    _getElementDisplayName(element),
                    style: TextStyle(
                      fontWeight: element == editorState.selectedElement
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: element == editorState.selectedElement,
                  onTap: () {
                    editorState.setSelectedElement(element);
                  },
                )),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.select_all),
                  label: const Text('Select All'),
                  onPressed: () {
                    // Set the first element as selected
                    // In the future, this could be expanded to handle multi-selection
                    if (elementsInGroup.isNotEmpty) {
                      editorState.setSelectedElement(elementsInGroup.first);
                    }
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('Show/Hide'),
                  onPressed: () {
                    // This is a placeholder for toggle visibility feature
                    // Would require additional properties in TemplateElement
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Icon _getIconForElementType(String type) {
    switch (type) {
      case 'text':
        return const Icon(Icons.text_fields);
      case 'image':
        return const Icon(Icons.image);
      case 'shape':
        return const Icon(Icons.shape_line);
      case 'leader_strip':
        return const Icon(Icons.people);
      default:
        return const Icon(Icons.widgets);
    }
  }

  String _getElementDisplayName(TemplateElement element) {
    if (element.type == 'text' && element.content.containsKey('text')) {
      final text = element.content['text'] as String? ?? '';
      if (text.isNotEmpty) {
        // Return the first 20 chars of text or first line
        final displayText = text.contains('\n') 
            ? text.split('\n').first 
            : (text.length > 20 ? text.substring(0, 20) + '...' : text);
        return displayText;
      }
    }
    
    // For other element types
    return '${element.tag.displayName} (${element.type})';
  }
}
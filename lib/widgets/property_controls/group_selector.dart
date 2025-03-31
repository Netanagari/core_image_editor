import 'package:flutter/material.dart';
import '../../models/template_types.dart';

class GroupSelector extends StatefulWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;
  final List<String> availableGroups; // List of existing groups to select from

  const GroupSelector({
    super.key,
    required this.element,
    required this.onUpdate,
    required this.availableGroups,
  });

  @override
  State<GroupSelector> createState() => _GroupSelectorState();
}

class _GroupSelectorState extends State<GroupSelector> {
  late TextEditingController _controller;
  bool _isCreatingNew = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.element.group ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GroupSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element.group != widget.element.group) {
      _controller.text = widget.element.group ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton.icon(
                icon: Icon(_isCreatingNew ? Icons.arrow_back : Icons.add),
                label: Text(_isCreatingNew ? 'Back' : 'New Group'),
                onPressed: () {
                  setState(() {
                    _isCreatingNew = !_isCreatingNew;
                    if (_isCreatingNew) {
                      _controller.text = '';
                    } else {
                      _controller.text = widget.element.group ?? '';
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_isCreatingNew)
            // Text field for creating a new group
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter new group name',
                isDense: true,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.element.group = value;
                  widget.onUpdate();
                  setState(() {
                    _isCreatingNew = false;
                  });
                }
              },
            )
          else
            // Dropdown for selecting from existing groups
            DropdownButtonFormField<String?>(
              value: widget.element.group,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              hint: const Text('Select a group (optional)'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('No Group'),
                ),
                ...widget.availableGroups
                    .map((group) => DropdownMenuItem<String?>(
                          value: group,
                          child: Text(group),
                        )),
              ],
              onChanged: (String? newValue) {
                widget.element.group = newValue;
                widget.onUpdate();
              },
            ),
        ],
      ),
    );
  }
}

import 'package:core_image_editor/models/language_types.dart';
import 'package:flutter/material.dart';
import '../models/template_types.dart';
import '../models/editor_config.dart';

class EditorState extends ChangeNotifier {
  List<TemplateElement> _elements;
  TemplateElement? _selectedElement;
  bool _isCreationSidebarExpanded;
  bool _isRotating;
  final EditorConfiguration configuration;
  Size _viewportSize;
  final double _canvasAspectRatio;

  EditorState({
    required List<TemplateElement> initialElements,
    required this.configuration,
    required double canvasAspectRatio,
    required Size initialViewportSize,
  })  : _elements = initialElements,
        _isCreationSidebarExpanded = true,
        _isRotating = false,
        _canvasAspectRatio = canvasAspectRatio,
        _viewportSize = initialViewportSize;

  List<TemplateElement> get elements => _elements;
  TemplateElement? get selectedElement => _selectedElement;
  bool get isCreationSidebarExpanded => _isCreationSidebarExpanded;
  bool get isRotating => _isRotating;
  Size get viewportSize => _viewportSize;
  double get canvasAspectRatio => _canvasAspectRatio;

  List<String> get availableGroups {
    Set<String> groups = {};
    for (var element in _elements) {
      if (element.group != null && element.group!.isNotEmpty) {
        groups.add(element.group!);
      }
    }
    return groups.toList()..sort();
  }

  List<TemplateElement> getElementsByGroup(String? group) {
    if (group == null) {
      return _elements.where((e) => e.group == null).toList();
    }
    return _elements.where((e) => e.group == group).toList();
  }

  // Helper method to select all elements in a group
  void selectGroup(String group) {
    // Note: This method doesn't select multiple elements yet,
    // just sets the first element in the group as selected
    final groupElements = getElementsByGroup(group);
    if (groupElements.isNotEmpty) {
      _selectedElement = groupElements.first;
      notifyListeners();
    }
  }

  void bringGroupToFront(String group) {
    final groupElements = getElementsByGroup(group);
    if (groupElements.isEmpty) return;

    // Find the highest z-index in the document
    int highestZIndex =
        _elements.fold(0, (max, e) => e.zIndex > max ? e.zIndex : max);

    // Move all elements in the group above that
    for (var element in groupElements) {
      element.zIndex = ++highestZIndex;
    }

    notifyListeners();
  }

  void sendGroupToBack(String group) {
    final groupElements = getElementsByGroup(group);
    if (groupElements.isEmpty) return;

    // Find the lowest z-index in the document
    int lowestZIndex =
        _elements.fold(0, (min, e) => e.zIndex < min ? e.zIndex : min);

    // Move all elements in the group below that
    for (var element in groupElements) {
      element.zIndex = --lowestZIndex;
    }

    notifyListeners();
  }

// Method to align all elements in a group
  void alignGroup(String group, String alignment) {
    final groupElements = getElementsByGroup(group);
    if (groupElements.isEmpty) return;

    for (var element in groupElements) {
      element.box.alignment = alignment;
    }

    notifyListeners();
  }

// Method to remove a group (not the elements, just ungroup them)
  void removeGroup(String group) {
    final groupElements = getElementsByGroup(group);
    for (var element in groupElements) {
      element.group = null;
    }

    notifyListeners();
  }

// Method to create a new group from selected elements
  void createGroupFromSelected(String groupName) {
    if (_selectedElement != null) {
      _selectedElement!.group = groupName;
      notifyListeners();
    }
  }

  void setElements(List<TemplateElement> elements) {
    _elements = elements;
    notifyListeners();
  }

  void setSelectedElement(TemplateElement? element) {
    _selectedElement = element;
    notifyListeners();
  }

  void toggleCreationSidebar() {
    _isCreationSidebarExpanded = !_isCreationSidebarExpanded;
    notifyListeners();
  }

  void setRotating(bool isRotating) {
    _isRotating = isRotating;
    notifyListeners();
  }

  void setViewportSize(Size size) {
    _viewportSize = size;
    notifyListeners();
  }

  void addElement(TemplateElement element) {
    _elements.add(element);
    _selectedElement = element;
    notifyListeners();
  }

  void removeElement(TemplateElement element) {
    _elements.remove(element);
    _selectedElement = null;
    notifyListeners();
  }

  void updateElement(TemplateElement element) {
    final index = _elements.indexWhere((e) => e == element);
    if (index != -1) {
      _elements[index] = element;
      notifyListeners();
    }
  }
  void refreshTextElementsForLanguage(String languageCode) {
  for (final element in _elements) {
    if (element.type == 'text' && element.content['localizedText'] != null) {
      try {
        final localizedText = element.localizedText;
        element.content['text'] = localizedText.get(languageCode);
      } catch (e) {
        // Ignore elements that don't have proper localization
      }
    }
  }
  notifyListeners();
}
}

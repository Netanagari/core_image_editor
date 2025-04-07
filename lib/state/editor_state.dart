// lib/state/editor_state.dart - Updated version

import 'package:core_image_editor/models/language_types.dart';
import 'package:flutter/material.dart';
import '../models/template_types.dart';
import '../models/editor_config.dart';

class EditorState extends ChangeNotifier {
  MultiLanguageContent _multiLanguageContent;
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
    String? initialLanguage,
  })  : _multiLanguageContent = MultiLanguageContent.fromSingleLanguage(
          initialLanguage ?? AppLanguageState.instance.currentLanguage,
          initialElements,
        ),
        _isCreationSidebarExpanded = true,
        _isRotating = false,
        _canvasAspectRatio = canvasAspectRatio,
        _viewportSize = initialViewportSize {
    // Listen to language changes
    AppLanguageState.instance.addListener(_handleLanguageChange);
  }

  @override
  void dispose() {
    AppLanguageState.instance.removeListener(_handleLanguageChange);
    super.dispose();
  }

  void _handleLanguageChange() {
    // When language changes, we need to change the current language in the multi-language content
    final newLanguage = AppLanguageState.instance.currentLanguage;

    // If the language doesn't exist yet in our content, let's create it
    if (!_multiLanguageContent.languageContents.containsKey(newLanguage)) {
      _multiLanguageContent.addLanguage(newLanguage);
    }

    // Set the current language
    _multiLanguageContent.currentLanguage = newLanguage;

    // Refresh all text elements for the new language
    refreshTextElementsForLanguage(newLanguage);

    notifyListeners();
  }

  // Get the elements for the current language
  List<TemplateElement> get elements =>
      _multiLanguageContent.getCurrentElements();

  // Shorthand to get the current language
  String get currentLanguage => _multiLanguageContent.currentLanguage;

  // Get the complete multi-language content
  MultiLanguageContent get multiLanguageContent => _multiLanguageContent;

  TemplateElement? get selectedElement => _selectedElement;
  bool get isCreationSidebarExpanded => _isCreationSidebarExpanded;
  bool get isRotating => _isRotating;
  Size get viewportSize => _viewportSize;
  double get canvasAspectRatio => _canvasAspectRatio;

  List<String> get availableGroups {
    Set<String> groups = {};
    for (var element in elements) {
      if (element.group != null && element.group!.isNotEmpty) {
        groups.add(element.group!);
      }
    }
    return groups.toList()..sort();
  }

  List<TemplateElement> getElementsByGroup(String? group) {
    if (group == null) {
      return elements.where((e) => e.group == null).toList();
    }
    return elements.where((e) => e.group == group).toList();
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
        elements.fold(0, (max, e) => e.zIndex > max ? e.zIndex : max);

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
        elements.fold(0, (min, e) => e.zIndex < min ? e.zIndex : min);

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

  void setElements(List<TemplateElement> newElements) {
    _multiLanguageContent.setCurrentElements(newElements);
    notifyListeners();
  }

  // Method to set elements for a specific language
  void setElementsForLanguage(
      String languageCode, List<TemplateElement> newElements) {
    _multiLanguageContent.setElementsForLanguage(languageCode, newElements);

    // If this is the current language, notify listeners
    if (languageCode == currentLanguage) {
      notifyListeners();
    }
  }

  // Method to copy elements from one language to another
  void copyElementsBetweenLanguages(
      String sourceLanguage, String targetLanguage) {
    _multiLanguageContent.copyElementsFromLanguage(
        sourceLanguage, targetLanguage);
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
    final currentElements = _multiLanguageContent.getCurrentElements();
    currentElements.add(element);
    _multiLanguageContent.setCurrentElements(currentElements);
    _selectedElement = element;
    notifyListeners();
  }

  void removeElement(TemplateElement element) {
    final currentElements = _multiLanguageContent.getCurrentElements();
    currentElements.remove(element);
    _multiLanguageContent.setCurrentElements(currentElements);
    _selectedElement = null;
    notifyListeners();
  }

  void updateElement(TemplateElement element) {
    final currentElements = _multiLanguageContent.getCurrentElements();
    final index = currentElements.indexWhere((e) => e == element);
    if (index != -1) {
      currentElements[index] = element;
      _multiLanguageContent.setCurrentElements(currentElements);
      notifyListeners();
    }
  }

  void refreshTextElementsForLanguage(String languageCode) {
    final currentElements = _multiLanguageContent.getCurrentElements();
    for (final element in currentElements) {
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

  // Method to export all content in the multi-language JSON format
  Map<String, dynamic> exportMultiLanguageContent() {
    return _multiLanguageContent.toJson();
  }

  // Method to import multi-language content
  void importMultiLanguageContent(Map<String, dynamic> json) {
    _multiLanguageContent = MultiLanguageContent.fromJson(json);
    // Ensure the current language is set to the app's current language
    final currentLang = AppLanguageState.instance.currentLanguage;
    if (_multiLanguageContent.languageContents.containsKey(currentLang)) {
      _multiLanguageContent.currentLanguage = currentLang;
    }

    refreshTextElementsForLanguage(_multiLanguageContent.currentLanguage);
    notifyListeners();
  }
}

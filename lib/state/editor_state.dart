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
}

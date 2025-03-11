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
  double _canvasAspectRatio;
  Color _backgroundColor;
  String? _backgroundImageUrl;

  EditorState({
    required List<TemplateElement> initialElements,
    required this.configuration,
    required double canvasAspectRatio,
    required Size initialViewportSize,
    Color? backgroundColor,
    String? backgroundImageUrl,
  })  : _elements = initialElements,
        _isCreationSidebarExpanded = true,
        _isRotating = false,
        _canvasAspectRatio = canvasAspectRatio,
        _viewportSize = initialViewportSize,
        _backgroundColor = backgroundColor ?? Colors.blue,
        _backgroundImageUrl = backgroundImageUrl;

  List<TemplateElement> get elements => _elements;
  TemplateElement? get selectedElement => _selectedElement;
  bool get isCreationSidebarExpanded => _isCreationSidebarExpanded;
  bool get isRotating => _isRotating;
  Size get viewportSize => _viewportSize;
  double get canvasAspectRatio => _canvasAspectRatio;
  Color get backgroundColor => _backgroundColor;
  String? get backgroundImageUrl => _backgroundImageUrl;

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

  void setCanvasAspectRatio(double ratio) {
    _canvasAspectRatio = ratio;
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  void setBackgroundImage(String url) {
    _backgroundImageUrl = url.isEmpty ? null : url;
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

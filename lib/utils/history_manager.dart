import '../models/template_types.dart';

class HistoryState {
  final List<TemplateElement> elements;
  final TemplateElement? selectedElement;

  HistoryState({
    required this.elements,
    this.selectedElement,
  });

  HistoryState copyWith({
    List<TemplateElement>? elements,
    TemplateElement? selectedElement,
  }) {
    return HistoryState(
      elements: elements ?? List.from(this.elements),
      selectedElement: selectedElement ?? this.selectedElement,
    );
  }

  factory HistoryState.fromElements(List<TemplateElement> elements, [TemplateElement? selectedElement]) {
    return HistoryState(
      elements: List.from(elements.map((e) => TemplateElement.fromJson(e.toJson()))),
      selectedElement: selectedElement != null 
          ? TemplateElement.fromJson(selectedElement.toJson())
          : null,
    );
  }
}

class HistoryManager {
  final List<HistoryState> _undoStack = [];
  final List<HistoryState> _redoStack = [];
  static const int maxHistorySize = 50;

  void pushState(HistoryState state) {
    _undoStack.add(state);
    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  HistoryState? undo() {
    if (_undoStack.isEmpty) return null;
    
    final currentState = _undoStack.removeLast();
    _redoStack.add(currentState);
    
    return _undoStack.isNotEmpty ? _undoStack.last : null;
  }

  HistoryState? redo() {
    if (_redoStack.isEmpty) return null;
    
    final state = _redoStack.removeLast();
    _undoStack.add(state);
    
    return state;
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
}
import 'package:flutter/foundation.dart';
import '../models/template_types.dart';

class HistoryState extends ChangeNotifier {
  final List<HistoryStateSnapshot> _undoStack = [];
  final List<HistoryStateSnapshot> _redoStack = [];
  static const int maxHistorySize = 50;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void pushState(
      List<TemplateElement> elements, TemplateElement? selectedElement) {
    _undoStack.add(HistoryStateSnapshot(
      elements:
          List.from(elements.map((e) => TemplateElement.fromJson(e.toJson()))),
      selectedElement: selectedElement != null
          ? TemplateElement.fromJson(selectedElement.toJson())
          : null,
    ));

    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    notifyListeners();
  }

  HistoryStateSnapshot? undo() {
    if (_undoStack.isEmpty) return null;

    final currentState = _undoStack.removeLast();
    _redoStack.add(currentState);
    notifyListeners();

    return _undoStack.isNotEmpty ? _undoStack.last : null;
  }

  HistoryStateSnapshot? redo() {
    if (_redoStack.isEmpty) return null;

    final state = _redoStack.removeLast();
    _undoStack.add(state);
    notifyListeners();

    return state;
  }
}

class HistoryStateSnapshot {
  final List<TemplateElement> elements;
  final TemplateElement? selectedElement;

  HistoryStateSnapshot({
    required this.elements,
    this.selectedElement,
  });
}

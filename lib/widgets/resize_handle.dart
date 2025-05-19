import 'package:core_image_editor/models/shape_types.dart';
import 'package:core_image_editor/models/template_types.dart';
import 'package:core_image_editor/state/editor_state.dart';
import 'package:core_image_editor/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResizeHandle extends StatefulWidget {
  final HandlePosition position;
  final TemplateElement element;
  final Size viewportSize;
  final VoidCallback onUpdate;
  final double handleSize;

  const ResizeHandle({
    super.key,
    required this.position,
    required this.element,
    required this.viewportSize,
    required this.onUpdate,
    this.handleSize = 24,
  });

  @override
  _ResizeHandleState createState() => _ResizeHandleState();
}

class _ResizeHandleState extends State<ResizeHandle>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  Offset? dragStart;
  double? initialWidth; // in percent
  double? initialHeight; // in percent
  double? initialX; // in percent
  double? initialY; // in percent

  // For maintaining font size in pixels during resize
  double? dragStartFontSizeVw;
  double? dragStartElementWidthPxForFont;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    dragStart = details.localPosition;
    initialWidth = widget.element.box.widthPercent;
    initialHeight = widget.element.box.heightPercent;
    initialX = widget.element.box.xPercent;
    initialY = widget.element.box.yPercent;

    if (widget.element.type == 'text') {
      dragStartFontSizeVw = widget.element.style.fontSizeVw;
      final editorState = context.read<EditorState>();
      // Calculate the element's width in original pixels at the start of the drag
      dragStartElementWidthPxForFont = widget.element.box.widthPx ??
          (widget.element.box.widthPercent / 100.0) *
              editorState.originalWidthValue;
    } else {
      dragStartFontSizeVw = null;
      dragStartElementWidthPxForFont = null;
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (dragStart == null || initialWidth == null || initialHeight == null)
      return;

    final deltaX = ResponsiveUtils.pixelToPercentX(
      details.localPosition.dx - dragStart!.dx,
      widget.viewportSize.width,
    );
    final deltaY = ResponsiveUtils.pixelToPercentY(
      details.localPosition.dy - dragStart!.dy,
      widget.viewportSize.height,
    );

    setState(() {
      switch (widget.position) {
        case HandlePosition.topLeft:
          _updateTopLeft(deltaX, deltaY);
          break;
        case HandlePosition.topRight:
          _updateTopRight(deltaX, deltaY);
          break;
        case HandlePosition.bottomLeft:
          _updateBottomLeft(deltaX, deltaY);
          break;
        case HandlePosition.bottomRight:
          _updateBottomRight(deltaX, deltaY);
          break;
      }

      // Apply constraints
      _applyConstraints();

      // Always update pixel values based on the new percentage values
      final editorState = context.read<EditorState>();
      final originalWidth = editorState.originalWidthValue;
      final originalHeight = editorState.originalHeightValue;

      widget.element.box.xPx =
          (widget.element.box.xPercent / 100.0) * originalWidth;
      widget.element.box.yPx =
          (widget.element.box.yPercent / 100.0) * originalHeight;
      widget.element.box.widthPx =
          (widget.element.box.widthPercent / 100.0) * originalWidth;
      widget.element.box.heightPx =
          (widget.element.box.heightPercent / 100.0) * originalHeight;

      // If it's a text element, adjust fontSizeVw to try and maintain the pixel font size from drag start
      if (widget.element.type == 'text' &&
          dragStartFontSizeVw != null &&
          dragStartElementWidthPxForFont != null &&
          dragStartElementWidthPxForFont! > 0) {
        final currentActualPixelWidth =
            widget.element.box.widthPx!; // This is the new width
        if (currentActualPixelWidth > 0) {
          // Calculate the font size in pixels that we want to maintain (based on drag start state)
          double targetFontSizePx =
              (dragStartFontSizeVw! / 100.0) * dragStartElementWidthPxForFont!;
          // Calculate the new fontSizeVw needed to achieve targetFontSizePx with the new currentActualPixelWidth
          widget.element.style.fontSizeVw =
              (targetFontSizePx / currentActualPixelWidth) * 100.0;
        }
      }

      widget.onUpdate();
    });
  }

  void _updateTopLeft(double deltaX, double deltaY) {
    widget.element.box.xPercent = (initialX! + deltaX).clamp(0.0, 100.0);
    widget.element.box.yPercent = (initialY! + deltaY).clamp(0.0, 100.0);
    widget.element.box.widthPercent =
        (initialWidth! - deltaX).clamp(1.0, 100.0);
    widget.element.box.heightPercent =
        (initialHeight! - deltaY).clamp(1.0, 100.0);
  }

  void _updateTopRight(double deltaX, double deltaY) {
    widget.element.box.yPercent = (initialY! + deltaY).clamp(0.0, 100.0);
    widget.element.box.widthPercent =
        (initialWidth! + deltaX).clamp(1.0, 100.0);
    widget.element.box.heightPercent =
        (initialHeight! - deltaY).clamp(1.0, 100.0);
  }

  void _updateBottomLeft(double deltaX, double deltaY) {
    widget.element.box.xPercent = (initialX! + deltaX).clamp(0.0, 100.0);
    widget.element.box.widthPercent =
        (initialWidth! - deltaX).clamp(1.0, 100.0);
    widget.element.box.heightPercent =
        (initialHeight! + deltaY).clamp(1.0, 100.0);
  }

  void _updateBottomRight(double deltaX, double deltaY) {
    widget.element.box.widthPercent =
        (initialWidth! + deltaX).clamp(1.0, 100.0);
    widget.element.box.heightPercent =
        (initialHeight! + deltaY).clamp(1.0, 100.0);
  }

  void _applyConstraints() {
    // Ensure element stays within viewport bounds
    if (widget.element.box.xPercent + widget.element.box.widthPercent > 100) {
      widget.element.box.widthPercent = 100 - widget.element.box.xPercent;
    }
    if (widget.element.box.yPercent + widget.element.box.heightPercent > 100) {
      widget.element.box.heightPercent = 100 - widget.element.box.yPercent;
    }

    // Minimum dimensions
    widget.element.box.widthPercent =
        widget.element.box.widthPercent.clamp(1.0, 100.0);
    widget.element.box.heightPercent =
        widget.element.box.heightPercent.clamp(1.0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position == HandlePosition.topLeft ||
              widget.position == HandlePosition.bottomLeft
          ? -widget.handleSize / 2
          : null,
      right: widget.position == HandlePosition.topRight ||
              widget.position == HandlePosition.bottomRight
          ? -widget.handleSize / 2
          : null,
      top: widget.position == HandlePosition.topLeft ||
              widget.position == HandlePosition.topRight
          ? -widget.handleSize / 2
          : null,
      bottom: widget.position == HandlePosition.bottomLeft ||
              widget.position == HandlePosition.bottomRight
          ? -widget.handleSize / 2
          : null,
      child: MouseRegion(
        cursor: _getCursor(),
        onEnter: (_) {
          setState(() {
            _isHovered = true;
            _scaleController.forward();
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
            _scaleController.reverse();
          });
        },
        child: GestureDetector(
          onPanStart: _handleDragStart,
          onPanUpdate: _handleDragUpdate,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: widget.handleSize,
              height: widget.handleSize,
              decoration: BoxDecoration(
                color: _isHovered ? Colors.blue : Colors.white,
                border: Border.all(
                  color: _isHovered ? Colors.white : Colors.blue,
                  width: 2,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.2),
                    blurRadius: _isHovered ? 6 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _getHandleIcon(),
                  size: 12,
                  color: _isHovered ? Colors.white : Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getHandleIcon() {
    switch (widget.position) {
      case HandlePosition.topLeft:
        return Icons.north_west;
      case HandlePosition.topRight:
        return Icons.north_east;
      case HandlePosition.bottomLeft:
        return Icons.south_west;
      case HandlePosition.bottomRight:
        return Icons.south_east;
    }
  }

  MouseCursor _getCursor() {
    switch (widget.position) {
      case HandlePosition.topLeft:
      case HandlePosition.bottomRight:
        return SystemMouseCursors.resizeUpDown;
      case HandlePosition.topRight:
      case HandlePosition.bottomLeft:
        return SystemMouseCursors.resizeUpLeft;
    }
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/template_types.dart';

class RotationHandle extends StatefulWidget {
  final TemplateElement element;
  final VoidCallback onUpdate;
  final double handleSize;
  final Size viewportSize;

  const RotationHandle({
    super.key,
    required this.element,
    required this.onUpdate,
    required this.viewportSize,
    this.handleSize = 24,
  });

  @override
  State<RotationHandle> createState() => _RotationHandleState();
}

class _RotationHandleState extends State<RotationHandle>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  Offset? _startPosition;
  Offset? _elementCenter;
  double? _startRotation;

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
    _elementCenter = Offset(
      widget.element.box.xPercent * widget.viewportSize.width / 100 +
          (widget.element.box.widthPercent * widget.viewportSize.width / 100) /
              2,
      widget.element.box.yPercent * widget.viewportSize.height / 100 +
          (widget.element.box.heightPercent *
                  widget.viewportSize.height /
                  100) /
              2,
    );

    _startPosition = details.globalPosition;
    _startRotation = widget.element.box.rotation;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_startPosition == null ||
        _startRotation == null ||
        _elementCenter == null) return;

    final startAngle = (math.atan2(
          _startPosition!.dy - _elementCenter!.dy,
          _startPosition!.dx - _elementCenter!.dx,
        )) *
        180 /
        math.pi;

    final currentAngle = (math.atan2(
          details.globalPosition.dy - _elementCenter!.dy,
          details.globalPosition.dx - _elementCenter!.dx,
        )) *
        180 /
        math.pi;

    final newRotation = _startRotation! + (currentAngle - startAngle);
    widget.element.box.rotation = (newRotation % 360 + 360) % 360;
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -40,
      left: 0,
      right: 0,
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
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
                    Icons.rotate_right,
                    size: 16,
                    color: _isHovered ? Colors.white : Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

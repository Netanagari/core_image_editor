import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInput extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;
  final double? min;
  final double? max;
  final String? suffix;
  final int? decimalPlaces;
  final double stepSize;

  const NumberInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.suffix,
    this.decimalPlaces = 2,
    this.stepSize = 1.0,
  });

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value.toStringAsFixed(widget.decimalPlaces ?? 2),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text =
          widget.value.toStringAsFixed(widget.decimalPlaces ?? 2);
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndUpdateValue(_controller.text);
    }
  }

  void _validateAndUpdateValue(String text) {
    double? newValue = double.tryParse(text);
    if (newValue != null) {
      if (widget.min != null) {
        newValue = newValue.clamp(widget.min!, widget.max ?? double.infinity);
      }
      if (widget.max != null) {
        newValue =
            newValue.clamp(widget.min ?? double.negativeInfinity, widget.max!);
      }
      widget.onChanged(newValue);
      _controller.text = newValue.toStringAsFixed(widget.decimalPlaces ?? 2);
    } else {
      _controller.text =
          widget.value.toStringAsFixed(widget.decimalPlaces ?? 2);
    }
  }

  void _increment() {
    double newValue = widget.value + widget.stepSize;
    if (widget.max != null) {
      newValue =
          newValue.clamp(widget.min ?? double.negativeInfinity, widget.max!);
    }
    widget.onChanged(newValue);
  }

  void _decrement() {
    double newValue = widget.value - widget.stepSize;
    if (widget.min != null) {
      newValue = newValue.clamp(widget.min!, widget.max ?? double.infinity);
    }
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.label}${widget.suffix != null ? ' (${widget.suffix})' : ''}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
                    ],
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      suffixText: widget.suffix,
                    ),
                    onChanged: (text) {
                      // Allow live typing but don't update state until focus is lost
                      if (text.isEmpty) return;
                      if (text == '-' || text == '.') return;
                      _validateAndUpdateValue(text);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepperButton(
                        icon: Icons.remove,
                        onPressed:
                            widget.min == null || widget.value > widget.min!
                                ? _decrement
                                : null,
                        isHovered: _isHovered,
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: theme.dividerColor,
                      ),
                      _StepperButton(
                        icon: Icons.add,
                        onPressed:
                            widget.max == null || widget.value < widget.max!
                                ? _increment
                                : null,
                        isHovered: _isHovered,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.min != null || widget.max != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Range: ${widget.min?.toStringAsFixed(1) ?? '-∞'} to ${widget.max?.toStringAsFixed(1) ?? '∞'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isHovered;

  const _StepperButton({
    required this.icon,
    this.onPressed,
    required this.isHovered,
  });

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: IconButton(
        icon: Icon(
          widget.icon,
          size: 16,
          color: widget.onPressed == null
              ? theme.disabledColor
              : _isHovered
                  ? theme.primaryColor
                  : theme.iconTheme.color,
        ),
        onPressed: widget.onPressed,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        padding: EdgeInsets.zero,
        splashRadius: 16,
        mouseCursor: widget.onPressed == null
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
      ),
    );
  }
}

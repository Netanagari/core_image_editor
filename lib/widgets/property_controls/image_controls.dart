import 'package:flutter/material.dart';
import '../../models/editor_config.dart';
import '../../models/template_types.dart';
import 'number_input.dart';

class ImageControls extends StatefulWidget {
  final TemplateElement element;
  final Future<String> Function(BuildContext) onSelectImage;
  final VoidCallback onUpdate;
  final EditorConfiguration configuration;

  const ImageControls({
    super.key,
    required this.element,
    required this.onSelectImage,
    required this.onUpdate,
    required this.configuration,
  });

  @override
  State<ImageControls> createState() => _ImageControlsState();
}

class _ImageControlsState extends State<ImageControls> {
  late TextEditingController _urlController;
  late FocusNode _focusNode;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: widget.element.content['url'] ?? '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _validateImageUrl(_urlController.text);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ImageControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element.content['url'] != widget.element.content['url'] &&
        !_focusNode.hasFocus) {
      _urlController.text = widget.element.content['url'] ?? '';
      _validateImageUrl(_urlController.text);
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _updateImageUrl(_urlController.text);
    }
  }

  Future<void> _validateImageUrl(String url) async {
    if (url.isEmpty) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final Uri? uri = Uri.tryParse(url);
      if (uri == null || !uri.isAbsolute) {
        throw Exception('Invalid URL format');
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Invalid or inaccessible image URL';
      });
    }
  }

  void _updateImageUrl(String url) {
    if (widget.element.content['url'] != url) {
      widget.element.content['url'] = url;
      widget.onUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageShapeControl(theme),
        const SizedBox(height: 16),
        _buildImageUrlControl(theme),
        const SizedBox(height: 16),
        _buildImageFitControl(theme),
        const SizedBox(height: 16),
        _buildAdvancedControls(theme),
      ],
    );
  }

  Widget _buildImageShapeControl(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Shape',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'rectangle',
              icon: Icon(Icons.rectangle_outlined),
              label: Text('Rectangle'),
            ),
            ButtonSegment(
              value: 'circle',
              icon: Icon(Icons.circle_outlined),
              label: Text('Circle'),
            ),
          ],
          selected: {widget.element.style.imageShape ?? 'rectangle'},
          onSelectionChanged: (Set<String> newSelection) {
            widget.element.style.imageShape = newSelection.first;
            widget.onUpdate();
          },
        ),
      ],
    );
  }

  Widget _buildImageUrlControl(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Image URL',
              style: theme.textTheme.bodyMedium,
            ),
            if (_isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _urlController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            errorText: _errorMessage,
            prefixIcon: const Icon(Icons.link),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _urlController.text.isNotEmpty
                  ? () {
                      _urlController.clear();
                      _updateImageUrl('');
                      setState(() {
                        _hasError = false;
                        _errorMessage = null;
                      });
                    }
                  : null,
            ),
          ),
          onChanged: (value) {
            _validateImageUrl(value);
          },
        ),
        const SizedBox(height: 8),
        if (widget.configuration.can(EditorCapability.uploadNewImage))
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final url = await widget.onSelectImage(context);
                _urlController.text = url;
                _updateImageUrl(url);
                _validateImageUrl(url);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to upload image: $e'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            icon: const Icon(Icons.upload),
            label: const Text('Upload New Image'),
          ),
      ],
    );
  }

  Widget _buildImageFitControl(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Fit',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<BoxFit>(
          value: widget.element.style.imageFit,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: BoxFit.contain,
              child: Row(
                children: [
                  const Icon(Icons.fit_screen, size: 16),
                  const SizedBox(width: 8),
                  const Text('Contain - Fit Within'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: BoxFit.cover,
              child: Row(
                children: [
                  const Icon(Icons.crop, size: 16),
                  const SizedBox(width: 8),
                  const Text('Cover - Fill & Crop'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: BoxFit.fill,
              child: Row(
                children: [
                  const Icon(Icons.expand, size: 16),
                  const SizedBox(width: 8),
                  const Text('Fill - Stretch'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: BoxFit.fitWidth,
              child: Row(
                children: [
                  const Icon(Icons.trending_flat, size: 16),
                  const SizedBox(width: 8),
                  const Text('Fit Width'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: BoxFit.fitHeight,
              child: Row(
                children: [
                  const Icon(Icons.height, size: 16),
                  const SizedBox(width: 8),
                  const Text('Fit Height'),
                ],
              ),
            ),
          ],
          onChanged: (BoxFit? newValue) {
            if (newValue != null) {
              widget.element.style.imageFit = newValue;
              widget.onUpdate();
            }
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedControls(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          title: Text(
            'Advanced Settings',
            style: theme.textTheme.bodyMedium,
          ),
          children: [
            // Image Quality Control
            NumberInput(
              label: 'Quality',
              value: widget.element.content['quality']?.toDouble() ?? 100,
              min: 1,
              max: 100,
              suffix: '%',
              onChanged: (value) {
                widget.element.content['quality'] = value.toInt();
                widget.onUpdate();
              },
            ),
            // Image Background Color
            CheckboxListTile(
              title: const Text('Keep Aspect Ratio'),
              value: widget.element.content['keepAspectRatio'] ?? true,
              onChanged: (bool? value) {
                widget.element.content['keepAspectRatio'] = value ?? true;
                widget.onUpdate();
              },
            ),
            // Image Smoothing
            CheckboxListTile(
              title: const Text('Enable Smoothing'),
              subtitle: const Text('Apply smooth scaling to the image'),
              value: widget.element.content['smoothing'] ?? true,
              onChanged: (bool? value) {
                widget.element.content['smoothing'] = value ?? true;
                widget.onUpdate();
              },
            ),
          ],
        ),
      ],
    );
  }
}

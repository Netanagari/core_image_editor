import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import '../widgets/image_from_json_widget.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// A class that handles bulk processing of posters
/// It fetches content_json for each poster ID, renders images,
/// uploads them, and updates the content_json with thumbnail URLs
class BulkPosterProcessor {
  // Configuration
  final List<int> posterIds;
  final String apiBaseUrl;
  final int concurrentTasks;

  // Internal state
  final Map<int, Map<String, dynamic>> _contentJsons = {};
  final Map<int, String> _thumbnailUrls = {};
  final List<int> _processingQueue = [];
  final List<int> _failedIds = [];
  final int _currentlyProcessing = 0;

  // Callbacks
  final Function(String) onLog;
  final Function(int, int) onProgress;
  final Function(List<int>) onComplete;
  final Function(String, dynamic) onError;

  // Add BuildContext to the constructor for web rendering
  final BuildContext? context;

  BulkPosterProcessor({
    required this.posterIds,
    required this.apiBaseUrl,
    this.concurrentTasks = 3,
    required this.onLog,
    required this.onProgress,
    required this.onComplete,
    required this.onError,
    this.context, // Add context for web rendering
  }) {
    _processingQueue.addAll(posterIds);
  }

  /// Start processing all poster IDs
  Future<void> startProcessing() async {
    onLog('Starting bulk processing of \\${posterIds.length} posters');
    final queue = List<int>.from(_processingQueue);
    final failedIds = <int>[];
    const int maxRetries = 3;

    // Worker function
    Future<void> worker() async {
      while (true) {
        int? posterId;
        // Synchronized queue pop
        if (queue.isNotEmpty) {
          posterId = queue.removeAt(0);
        } else {
          break;
        }

        int attempt = 0;
        while (attempt < maxRetries) {
          try {
            await _processPosterId(posterId);
            break; // Success
          } catch (e) {
            attempt++;
            if (attempt >= maxRetries) {
              failedIds.add(posterId);
              onError('Error processing poster ID $posterId', e);
            } else {
              onLog('Retrying poster ID $posterId (attempt $attempt)');
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        }

        onProgress(
          posterIds.length - queue.length - 1, // processed count
          posterIds.length,
        );
      }
    }

    // Launch a pool of workers
    final workers = List.generate(
      concurrentTasks,
      (_) => worker(),
    );

    await Future.wait(workers);

    // Write failed IDs to filed_ids.txt
    if (failedIds.isNotEmpty) {
      try {
        final failedIdsString = failedIds.join(',');
        final file = File('filed_ids.txt');
        await file.writeAsString(failedIdsString);
        onLog('Failed IDs written to filed_ids.txt');
      } catch (e) {
        onLog('Failed to write failed IDs to filed_ids.txt: $e');
      }
    }

    onComplete(failedIds);
  }

  /// Process a single poster ID
  Future<void> _processPosterId(int posterId) async {
    try {
      onLog('Processing poster ID: $posterId');

      // Step 1: Fetch content JSON
      final contentJson = await _fetchContentJson(posterId);
      final copy = Map<String, dynamic>.from(contentJson);
      _contentJsons[posterId] = contentJson;

      final allLanguages = Stream.fromIterable(
          contentJson['language_settings']['enabled_languages'] ?? []);
      final Map<String, String> thumbnailUrls = {};

      await for (final lang in allLanguages) {
        final langCode = lang['code'] as String;
        onLog('Generating poster for language: $langCode ($posterId)');

        // Deep copy contentJson for this language
        final contentJsonForLang = jsonDecode(jsonEncode(contentJson));

        // Step 2: Render the image for the specific language
        contentJsonForLang['language_settings']['current_language'] = langCode;
        final preProcessedJson = _preProcessContentJson(contentJsonForLang);
        final imageBytes = await _renderPosterImage(preProcessedJson);

        // Log original image dimensions
        await _logImageDimensions(imageBytes, 'Original');

        // Step 2.5: Compress the image using JPEG (lossy)
        double toKB(int bytes) => bytes / 1024.0;
        onLog(
            'Original image size: \\${toKB(imageBytes.length).toStringAsFixed(1)} KB');
        final compressedBytes = await FlutterImageCompress.compressWithList(
          imageBytes,
          format: CompressFormat.jpeg,
          minWidth: 1080,
          minHeight: 1080,
          quality: 85, // 85 is a good balance for thumbnails
        );
        onLog(
            'Compressed JPEG image size: \\${toKB(compressedBytes.length).toStringAsFixed(1)} KB (saved: \\${toKB(imageBytes.length - compressedBytes.length).toStringAsFixed(1)} KB)');

        // Log compressed image dimensions
        await _logImageDimensions(compressedBytes, 'Compressed JPEG');

        // Step 3: Upload the compressed image
        final thumbnailUrl = await _uploadImage(compressedBytes, posterId);
        _thumbnailUrls[posterId] = thumbnailUrl;
        thumbnailUrls[langCode] = thumbnailUrl;
      }

      // Step 4: Update content JSON with thumbnail URL
      copy['thumbnail_url'] = thumbnailUrls;

      // Step 5: Update the poster with the new content JSON
      await _updatePoster(posterId, copy);

      onLog('Successfully processed poster ID: $posterId');
    } catch (e) {
      onLog('Failed to process poster ID: $posterId - Error: $e');
      _failedIds.add(posterId);
      rethrow;
    }
  }

  /// Fetch content JSON for a poster ID
  Future<Map<String, dynamic>> _fetchContentJson(int posterId) async {
    onLog('Fetching content JSON for poster ID: $posterId');

    // TODO: Replace with your actual API endpoint

    final response = await http.get(
      Uri.parse('$apiBaseUrl/poster-template/$posterId/'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Token 908ca2cfad64a66e5bc34421a37f9f94c34655ea',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to fetch content JSON for poster ID: $posterId - Status: ${response.statusCode}');
    }
  }

  Map<String, dynamic> _preProcessContentJson(Map<String, dynamic> json) {
    // remove all the elements with tag TemplateTag.leaderStrip
    json['content_json'] = json['content_json']
        .where((e) => e['tag'] != 'TemplateElementTag.leaderStrip')
        .toList();

    // remove all the elements where group is "user_strip" and tag is not TemplateElementTag.partyStrip and TemplateElementTag.partySymbol
    json['content_json'] = json['content_json']
        .where((e) =>
            e['group'] != 'user_strip' ||
            (e['tag'] == 'TemplateElementTag.partyStrip' ||
                e['tag'] == 'TemplateElementTag.partySymbol'))
        .toList();

    final indexOfBackground = json['content_json']
        .indexWhere((e) => e['tag'] == 'TemplateElementTag.background');

    // By default all the posters will be generated with OP background with 0.25 opacity
    var el = json['content_json'][indexOfBackground] as Map<String, dynamic>;
    el['content']['url'] =
        'https://netanagri-bucket.s3.amazonaws.com/assets/backgrounds/op.png';
    el['style']['opacity'] = 0.25;

    return json;
  }

  /// Preload all images from content JSON to avoid race conditions
  Future<void> _preloadImages(
    Map<String, dynamic> contentJson,
    BuildContext context,
  ) async {
    onLog('Preloading images from content JSON');

    // Extract all image URLs from the content JSON
    final List<String> imageUrls = [];

    // Add base image if present
    final String baseImageUrl = contentJson['base_image_url'] ?? '';
    if (baseImageUrl.isNotEmpty) {
      imageUrls.add(baseImageUrl);
    }

    // Process all elements to find image URLs
    final List<dynamic> elementsJson = contentJson['content_json'] ?? [];
    for (final elementJson in elementsJson) {
      // Check for image elements
      if (elementJson['type'] == 'image' &&
          elementJson['content']?['url'] != null) {
        imageUrls.add(elementJson['content']['url']);
      }

      // Check for leader strip elements
      if (elementJson['type'] == 'leader_strip' &&
          elementJson['content']?['leaders'] != null) {
        for (final leader in elementJson['content']['leaders']) {
          if (leader['content']?['url'] != null) {
            imageUrls.add(leader['content']['url']);
          }
        }
      }

      // Check for nested content with images
      if (elementJson['nestedContent']?['content']?['type'] == 'image' &&
          elementJson['nestedContent']['content']['content']?['url'] != null) {
        imageUrls
            .add(elementJson['nestedContent']['content']['content']['url']);
      }
    }

    onLog('Found ${imageUrls.length} images to preload');

    // Preload all images
    final List<Future<void>> precacheFutures = [];
    for (final url in imageUrls) {
      precacheFutures.add(precacheImage(NetworkImage(url), context)
          .catchError((e) => onLog('Error preloading image $url: $e')));
    }

    // Wait for all images to be loaded
    await Future.wait(precacheFutures);
    onLog('All images preloaded successfully');
  }

  /// Render poster image using widget-based approach (web-compatible)
  Future<Uint8List> _renderPosterImage(Map<String, dynamic> contentJson) async {
    onLog('Rendering image for content JSON');

    if (context == null) {
      throw Exception('BuildContext is required for web rendering');
    }

    final completer = Completer<Uint8List>();

    // Preload all images before rendering
    await _preloadImages(contentJson, context!);

    // For web, we need to use the overlay approach
    late OverlayEntry overlayEntry;
    final GlobalKey boundaryKey = GlobalKey();

    overlayEntry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        left: -10000, // Move off-screen
        top: -10000,
        child: Material(
          child: RepaintBoundary(
            key: boundaryKey,
            child: Container(
              width: 1080, // Set appropriate size for your posters
              height: 1080, // Set appropriate size for your posters
              color: Colors.white,
              child: ImageFromJsonWidget(
                contentJson: contentJson,
              ),
            ),
          ),
        ),
      ),
    );

    // Add to overlay
    Overlay.of(context!).insert(overlayEntry);

    // Wait for widget to render then capture
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Since we've preloaded images, we can reduce the delay
        await Future.delayed(const Duration(milliseconds: 200));

        final boundary = boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 1.0);
          final byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          final bytes = byteData!.buffer.asUint8List();

          // Remove from overlay
          overlayEntry.remove();

          completer.complete(bytes);
        } else {
          overlayEntry.remove();
          completer.completeError('Failed to find RepaintBoundary');
        }
      } catch (e) {
        overlayEntry.remove();
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  Future<String> _uploadImage(
    Uint8List imageBytes,
    int templateId,
  ) async {
    try {
      final uploadUrl = Uri.parse("$apiBaseUrl/get-upload-url/");

      final response = await http.post(
        uploadUrl,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Token 908ca2cfad64a66e5bc34421a37f9f94c34655ea',
        },
        body: jsonEncode({
          "folder_name": "poster/$templateId/content",
          'content_type': "image/jpeg",
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final uploadUrl0 =
            (jsonDecode(response.body) as Map<String, dynamic>)['upload_url'];

        await http.put(
          Uri.parse(uploadUrl0),
          body: imageBytes,
          headers: {
            'Content-Type': "image/jpeg",
            'Content-Length': imageBytes.length.toString(),
          },
        );

        return uploadUrl0.toString().split("?").first;
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  /// Update a poster with new content JSON
  Future<void> _updatePoster(
    int posterId,
    Map<String, dynamic> contentJson,
  ) async {
    onLog('Updating poster ID: $posterId with new content JSON');

    // TODO: Replace with your actual API endpoint
    final response = await http.put(
      Uri.parse('$apiBaseUrl/poster-template/$posterId/content/'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Token 07a2c31005b269fc51ec53a4b3454cd17802186b',
      },
      body: json.encode(contentJson),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update poster ID: $posterId - Status: ${response.statusCode}');
    }
  }

  Future<void> _logImageDimensions(Uint8List bytes, String label) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      onLog('$label image dimensions: \\${image.width}x\\${image.height}');
    } catch (e) {
      onLog('Failed to get $label image dimensions: $e');
    }
  }
}

/// Alternative approach: A widget-based image renderer
/// This should be used within the widget tree of your app
class ImageRenderer extends StatefulWidget {
  final Map<String, dynamic> contentJson;
  final Function(Uint8List) onImageRendered;

  const ImageRenderer({
    super.key,
    required this.contentJson,
    required this.onImageRendered,
  });

  @override
  State<ImageRenderer> createState() => _ImageRendererState();
}

class _ImageRendererState extends State<ImageRenderer> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isRendering = false;

  @override
  void initState() {
    super.initState();
    // Capture the image after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureImage();
    });
  }

  Future<void> _captureImage() async {
    if (_isRendering) return;

    setState(() {
      _isRendering = true;
    });

    try {
      await Future.delayed(
          const Duration(milliseconds: 100)); // Allow widget to settle

      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        widget.onImageRendered(bytes);
      }
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      setState(() {
        _isRendering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: ImageFromJsonWidget(
        contentJson: widget.contentJson,
      ),
    );
  }
}

/// A widget that displays the progress of bulk poster processing
class BulkPosterProcessorWidget extends StatefulWidget {
  final List<int> posterIds;
  final String apiBaseUrl;
  final int concurrentTasks;

  const BulkPosterProcessorWidget({
    super.key,
    required this.posterIds,
    required this.apiBaseUrl,
    this.concurrentTasks = 3,
  });

  @override
  State<BulkPosterProcessorWidget> createState() =>
      _BulkPosterProcessorWidgetState();
}

class _BulkPosterProcessorWidgetState extends State<BulkPosterProcessorWidget> {
  bool _isProcessing = false;
  int _processedCount = 0;
  int _totalCount = 0;
  final List<String> _logs = [];
  List<int> _failedIds = [];

  late BulkPosterProcessor _processor;

  @override
  void initState() {
    super.initState();
    _totalCount = widget.posterIds.length;

    _processor = BulkPosterProcessor(
      posterIds: widget.posterIds,
      apiBaseUrl: widget.apiBaseUrl,
      concurrentTasks: widget.concurrentTasks,
      onLog: _addLog,
      onProgress: _updateProgress,
      onComplete: _onComplete,
      onError: _onError,
      context: context, // Pass context for web rendering
    );
  }

  void _addLog(String log) {
    if (mounted) {
      setState(() {
        _logs.add('${DateTime.now().toString().substring(11, 19)}: $log');
      });
    }
  }

  void _updateProgress(int processed, int total) {
    if (mounted) {
      setState(() {
        _processedCount = processed;
        _totalCount = total;
      });
    }
  }

  void _onComplete(List<int> failedIds) {
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _failedIds = failedIds;
      });

      _addLog('Processing complete. ${failedIds.length} posters failed.');

      if (failedIds.isNotEmpty) {
        _addLog('Failed poster IDs: ${failedIds.join(', ')}');
      }
    }
  }

  void _onError(String message, dynamic error) {
    _addLog('ERROR: $message - $error');
  }

  void _startProcessing() {
    setState(() {
      _isProcessing = true;
      _processedCount = 0;
      _logs.clear();
      _failedIds.clear();
    });

    _processor.startProcessing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Poster Processor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Processing ${widget.posterIds.length} posters',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _totalCount > 0 ? _processedCount / _totalCount : 0,
            ),
            const SizedBox(height: 8),
            Text('Progress: $_processedCount / $_totalCount'),
            const SizedBox(height: 16),
            Text(
              'Logs:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Expanded(
              child: SelectionArea(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Text(_logs[index]);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _isProcessing ? null : _startProcessing,
                  child: Text(
                      _isProcessing ? 'Processing...' : 'Start Processing'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

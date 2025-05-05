// ignore_for_file: public_member_api_docs, sort_constructors_first
enum EditorCapability {
  // Element manipulation
  addElements,
  deleteElements,
  repositionElements,
  resizeElements,
  rotateElements,

  // Style modifications
  changeColors,
  changeFonts,
  changeTextContent,
  changeBorders,

  // Layout controls
  changeAlignment,
  changeZIndex,

  // Shape specific
  modifyShapeProperties,

  // Image specific
  changeImageFit,
  uploadNewImage,

  // History controls
  undoRedo,
}

class EditorConfiguration {
  final Set<EditorCapability> capabilities;
  final List<String> availableFonts;
  final double pixelRatio; // the more the better image export quality

  const EditorConfiguration({
    required this.capabilities,
    this.availableFonts = supportedFallbackFonts,
    this.pixelRatio = 6,
  });

  static const supportedFallbackFonts = [
    'English',
    'Lohit-Assamese',
    'Lohit-Bengali',
    'Lohit-Devanagari',
    'Lohit-Gujarati',
    'Lohit-Kannada',
    'Lohit-Malayalam',
    'Lohit-Marathi',
    'Lohit-Oriya',
    'Lohit-Punjabi',
    'Lohit-Tamil',
    'Lohit-Telugu',
    'Noto-Urdu',
  ];

  // Predefined configurations
  static const admin = EditorConfiguration(
    capabilities: {
      EditorCapability.addElements,
      EditorCapability.deleteElements,
      EditorCapability.repositionElements,
      EditorCapability.resizeElements,
      EditorCapability.changeColors,
      EditorCapability.changeFonts,
      EditorCapability.changeTextContent,
      EditorCapability.changeBorders,
      EditorCapability.changeAlignment,
      EditorCapability.changeZIndex,
      EditorCapability.modifyShapeProperties,
      EditorCapability.changeImageFit,
      EditorCapability.uploadNewImage,
      EditorCapability.undoRedo,
      EditorCapability.rotateElements,
    },
  );

  static const endUser = EditorConfiguration(
    capabilities: {
      EditorCapability.changeTextContent,
      EditorCapability.changeColors,
      EditorCapability.changeFonts,
      EditorCapability.undoRedo,
    },
  );

  bool can(EditorCapability capability) {
    return capabilities.contains(capability);
  }

  EditorConfiguration copyWith({
    Set<EditorCapability>? capabilities,
    List<String>? availableFonts,
    double? pixelRatio,
  }) {
    return EditorConfiguration(
      capabilities: capabilities ?? this.capabilities,
      availableFonts: availableFonts ?? this.availableFonts,
      pixelRatio: pixelRatio ?? this.pixelRatio,
    );
  }
}

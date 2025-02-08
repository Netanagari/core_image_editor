enum EditorCapability {
  // Element manipulation
  addElements,
  deleteElements,
  repositionElements,
  resizeElements,

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

  const EditorConfiguration({
    required this.capabilities,
    this.availableFonts = supportedFallbackFonts,
  });

  static const supportedFallbackFonts = [
    'Roboto',
    'Lato',
    'Open Sans',
    'Montserrat',
    'Poppins',
    'Raleway',
    'Ubuntu',
    'Playfair Display',
    'Merriweather',
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
}

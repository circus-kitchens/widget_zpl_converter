import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';

/// Rotation options for ZPL image output
enum ZplRotation {
  /// Normal orientation (0 degrees)
  normal,

  /// Rotated 90 degrees clockwise
  rotate90,

  /// Rotated 180 degrees
  rotate180,

  /// Rotated 270 degrees clockwise (90 degrees counterclockwise)
  rotate270,
}

/// Converts any Flutter Widget to a print-ready ZPL command. Intended for Label mode printing.
///
/// Simple usage:
/// ```dart
/// String zpl = await ImageZplConverter.convertWidget(myWidget);
/// ```
///
/// Advanced usage with high-resolution and label dimension options:
/// ```dart
/// final converter = ImageZplConverter(
///   myWidget,
///   width: 400,
///   threshold: 100,
///   pixelRatio: 3.0, // High resolution for crisp output
///   labelWidthCm: 10.0, // 10cm wide label
///   labelHeightCm: 6.0,  // 6cm tall label
///   dpi: 203, // Printer DPI (dots per inch)
/// );
/// String zpl = await converter.convert();
///
/// // Check if the image fits on the label
/// if (!converter.validateLabelFit()) {
///   print(converter.getLabelFitWarning());
/// }
/// ```
class ImageZplConverter {
  /// Creates a new [ImageZplConverter]
  ImageZplConverter(
    this.widget, {
    int width = 560,
    this.threshold = 128,
    this.xPosition = 0,
    this.yPosition = 0,
    this.rotation = ZplRotation.normal,
    this.pixelRatio = 2.0,
    this.labelWidthCm = 10.0,
    this.labelHeightCm = 6.0,
    this.dpi = 203,
  }) : _originalWidth = width {
    if (width <= 0) {
      throw ArgumentError('Width must be positive');
    }
    if (threshold < 0 || threshold > 255) {
      throw ArgumentError('Threshold must be between 0 and 255');
    }
    if (pixelRatio <= 0) {
      throw ArgumentError('Pixel ratio must be positive');
    }
    if (labelWidthCm <= 0) {
      throw ArgumentError('Label width must be positive');
    }
    if (labelHeightCm <= 0) {
      throw ArgumentError('Label height must be positive');
    }
    if (dpi <= 0) {
      throw ArgumentError('DPI must be positive');
    }
  }

  /// The widget to be converted to ZPL
  final Widget widget;

  /// The original desired width of the ZPL image, defaults to 560
  final int _originalWidth;

  /// The threshold value for binarization (0-255), defaults to 128
  final int threshold;

  /// X position on the label where the image should be placed
  final int xPosition;

  /// Y position on the label where the image should be placed
  final int yPosition;

  /// Rotation setting for the image
  final ZplRotation rotation;

  /// The pixel ratio for high resolution screenshots, defaults to 2.0 for better quality
  final double pixelRatio;

  /// The physical width of the label in centimeters
  final double labelWidthCm;

  /// The physical height of the label in centimeters
  final double labelHeightCm;

  /// The printer DPI (dots per inch), defaults to 203 DPI (common for Zebra printers)
  final int dpi;

  /// The actual width of the ZPL image (adjusted to nearest multiple of 8)
  late final int width;

  /// The calculated height of the ZPL image
  late final int height;

  /// A [ScreenshotController] used to capture the widget as an image
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Converts the widget to a ZPL command
  ///
  /// The [widget] goes through the following operations:
  /// 1. Capture the widget as an image
  /// 2. Convert the image to greyscale
  /// 3. Resize the image to the desired width and height
  /// 4. Convert the image to binary
  /// 5. Convert the binary to bytes
  /// 6. Convert the bytes to a hex string
  /// 7. Generate the ZPL command
  ///
  /// Returns the ZPL command as a [String]
  Future<String> convert() async {
    final screenshot = await _screenshot();
    final greyScaleImage = _convertToGreyScale(screenshot);
    final resizedImage = _resizeImage(greyScaleImage);
    final rotatedImage = _rotateImage(resizedImage);
    final pixelBits = _binarizeImage(rotatedImage);
    final pixelBytes = _byteRepresentation(pixelBits);
    final hexBody = _hexRepresentation(pixelBytes);

    // Calculate bytes based on the actual image dimensions after all transformations
    final imageWidth = rotatedImage.width;
    final imageHeight = rotatedImage.height;
    final bytesPerRow = (imageWidth / 8).ceil();
    final totalBytes = bytesPerRow * imageHeight;

    final zpl = _generateZpl(totalBytes, bytesPerRow, hexBody);

    return zpl;
  }

  /// Captures the widget as an image
  ///
  /// Returns the image as a [Uint8List]
  Future<Uint8List> _screenshot() async {
    try {
      final screenshot = await _screenshotController.captureFromWidget(
        widget,
        pixelRatio:
            pixelRatio, // Use configurable pixel ratio for high resolution
        delay: const Duration(milliseconds: 20), // Small delay for rendering
      );

      return screenshot.buffer.asUint8List();
    } catch (e) {
      throw Exception(
        'Failed to capture widget screenshot: $e. '
        'This may happen on web platforms or with complex widgets. '
        'Try running on mobile/desktop or using a simpler widget.',
      );
    }
  }

  /// Converts the image to greyscale
  img.Image _convertToGreyScale(Uint8List image) {
    if (image.isEmpty) {
      throw ArgumentError('Image data cannot be empty');
    }

    final decodedImage = img.decodeImage(image);
    if (decodedImage == null) {
      throw ArgumentError(
        'Failed to decode image. Invalid image format or corrupted data.',
      );
    }

    // Validate image dimensions
    if (decodedImage.width <= 0 || decodedImage.height <= 0) {
      throw ArgumentError('Image must have positive width and height');
    }

    final greyScaleImage = img.grayscale(decodedImage);

    return greyScaleImage;
  }

  /// Resizes the image to the desired width and height
  ///
  /// Sizes are rounded up to the nearest multiple of 8 for byte divisibility
  /// Preserves original aspect ratio and uses high-quality interpolation
  img.Image _resizeImage(img.Image image) {
    width = _findNearestEightMultiple(_originalWidth);
    height = _calculateHeight(image);

    // Use cubic interpolation for better quality when resizing
    final resizedImage = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.cubic,
    );

    return resizedImage;
  }

  /// Rotates the image based on the rotation setting
  ///
  /// Updates width and height if the rotation is 90 or 270 degrees
  img.Image _rotateImage(img.Image image) {
    img.Image rotatedImage;

    switch (rotation) {
      case ZplRotation.normal:
        rotatedImage = image;
        break;
      case ZplRotation.rotate90:
        rotatedImage = img.copyRotate(image, angle: 90);
        // Swap width and height for 90-degree rotation
        final tempWidth = width;
        width = height;
        height = tempWidth;
        break;
      case ZplRotation.rotate180:
        rotatedImage = img.copyRotate(image, angle: 180);
        break;
      case ZplRotation.rotate270:
        rotatedImage = img.copyRotate(image, angle: 270);
        // Swap width and height for 270-degree rotation
        final tempWidth = width;
        width = height;
        height = tempWidth;
        break;
    }

    return rotatedImage;
  }

  /// Converts the image to binary
  ///
  /// Each pixel is converted to a single bit, with 1 representing a dark pixel
  List<int> _binarizeImage(img.Image image) {
    final totalPixels = image.width * image.height;
    final List<int> pixelBits = List<int>.filled(totalPixels, 0);
    int index = 0;

    // Convert image pixels to binary bits
    for (int h = 0; h < image.height; h++) {
      for (int w = 0; w < image.width; w++) {
        final pixel = image.getPixelSafe(w, h);

        // Extract red component which represents grayscale value
        // Since the image is already grayscale, all RGB components are the same
        // In image package v4, use pixel.r to get red component
        final grayscaleValue = pixel.r;

        // Threshold image: If pixel is darker than threshold, set bit to 1
        final bit = grayscaleValue < threshold ? 1 : 0;

        pixelBits[index++] = bit;
      }
    }

    return pixelBits;
  }

  /// Converts the binarized image to bytes
  ///
  /// Each byte represents 8 consecutive pixels
  /// ZPL uses MSB (Most Significant Bit) first bit ordering
  /// Optimized for memory efficiency with large images
  List<int> _byteRepresentation(List<int> bits) {
    if (bits.isEmpty) {
      throw ArgumentError('Bits array cannot be empty');
    }

    final numBytes = (bits.length / 8).ceil();
    final List<int> pixelBytes = List<int>.filled(numBytes, 0);

    // Group bits into bytes using bitwise operations
    // ZPL expects MSB first bit ordering (bit 7 is leftmost)
    // Process in chunks for better memory efficiency
    const int chunkSize = 8192; // Process 8KB at a time

    for (
      int chunkStart = 0;
      chunkStart < bits.length;
      chunkStart += chunkSize
    ) {
      final chunkEnd = (chunkStart + chunkSize < bits.length)
          ? chunkStart + chunkSize
          : bits.length;

      for (int i = chunkStart; i < chunkEnd; i++) {
        final byteIndex = i ~/ 8;
        final bitPosition = 7 - (i % 8); // MSB first for ZPL

        if (bits[i] == 1) {
          pixelBytes[byteIndex] |= (1 << bitPosition);
        }
      }
    }

    // Validate the output
    if (pixelBytes.isEmpty) {
      throw Exception('Failed to convert bits to bytes - no bytes generated');
    }

    return pixelBytes;
  }

  /// Converts the byte array to a hex string
  ///
  /// This representation is required by ZPL standards for image printing
  String _hexRepresentation(List<int> bytes) {
    // Use StringBuffer for efficient string concatenation
    final buffer = StringBuffer();

    for (final byte in bytes) {
      // Convert to hex with uppercase letters and ensure 2 digits
      buffer.write(byte.toRadixString(16).toUpperCase().padLeft(2, '0'));
    }

    return buffer.toString();
  }

  /// Generates the ZPL command
  ///
  /// Requires the total number of bytes, the number of bytes per row, and the
  /// hex string representation of the image
  ///
  /// ZPL GFA command format: ^GFA,totalBytes,totalBytes,bytesPerRow,data
  /// ^GFA = Graphic Field ASCII (command with ASCII hex encoding)
  /// totalBytes: Total number of bytes in the graphic
  /// bytesPerRow: Number of bytes per row
  String _generateZpl(int totalBytes, int byteWidth, String hexBody) {
    // According to Zebra ZPL specification, ^GFA format is:
    // ^GFA,b,c,d,data where:
    // ^GFA = Graphic Field ASCII (the 'A' is part of the command, not a parameter)
    // b = binary byte count (total bytes to be transmitted)
    // c = graphic field count (total bytes comprising the graphic format)
    // d = bytes per row (number of bytes in each row)
    // data = ASCII hexadecimal data
    //
    // Example: ^GFA,8,8,1,FF00FF00FF00FF00
    // This creates an 8x8 pixel image with alternating black/white horizontal stripes
    final zplCommand =
        "^XA^FO$xPosition,$yPosition^GFA,$totalBytes,$totalBytes,$byteWidth,$hexBody^FS^XZ";

    return zplCommand;
  }

  /// Finds the nearest number divisible by 8 to the given value
  int _findNearestEightMultiple(int value) {
    final remainder = value % 8;

    if (remainder != 0) {
      value = value + (8 - remainder);
    }

    return value;
  }

  /// Converts centimeters to pixels based on the printer DPI
  int cmToPixels(double cm) {
    // Convert cm to inches, then to pixels
    final inches = cm / 2.54; // 1 inch = 2.54 cm
    return (inches * dpi).round();
  }

  /// Converts pixels to centimeters based on the printer DPI
  double pixelsToCm(int pixels) {
    // Convert pixels to inches, then to cm
    final inches = pixels / dpi;
    return inches * 2.54; // 1 inch = 2.54 cm
  }

  /// Gets the maximum label width in pixels
  int get maxLabelWidthPixels => cmToPixels(labelWidthCm);

  /// Gets the maximum label height in pixels
  int get maxLabelHeightPixels => cmToPixels(labelHeightCm);

  /// Gets the actual output width in centimeters
  double get outputWidthCm => pixelsToCm(width);

  /// Gets the actual output height in centimeters
  double get outputHeightCm => pixelsToCm(height);

  /// Validates that the generated image fits within the specified label dimensions
  bool validateLabelFit() {
    return width <= maxLabelWidthPixels && height <= maxLabelHeightPixels;
  }

  /// Gets a warning message if the image doesn't fit on the label
  String? getLabelFitWarning() {
    if (validateLabelFit()) return null;

    final widthOverflow = width > maxLabelWidthPixels
        ? 'Width: ${outputWidthCm.toStringAsFixed(2)}cm > ${labelWidthCm}cm'
        : null;
    final heightOverflow = height > maxLabelHeightPixels
        ? 'Height: ${outputHeightCm.toStringAsFixed(2)}cm > ${labelHeightCm}cm'
        : null;

    final issues = [
      widthOverflow,
      heightOverflow,
    ].where((e) => e != null).join(', ');
    return 'Warning: Image exceeds label dimensions. $issues';
  }

  /// Calculates the height of the image based on the width
  ///
  /// Preserves the original aspect ratio from the source image
  int _calculateHeight(img.Image sourceImage) {
    final aspectRatio = sourceImage.height / sourceImage.width;
    final calculatedHeight = (width * aspectRatio).round();

    return _findNearestEightMultiple(calculatedHeight);
  }

  /// Creates a widget wrapper that applies rotation at the Flutter widget level
  ///
  /// This is useful when you want to rotate the widget itself before screenshot,
  /// rather than rotating the image after capture
  static Widget createRotatedWidget(Widget child, ZplRotation rotation) {
    switch (rotation) {
      case ZplRotation.normal:
        return child;
      case ZplRotation.rotate90:
        return RotatedBox(quarterTurns: 1, child: child);
      case ZplRotation.rotate180:
        return RotatedBox(quarterTurns: 2, child: child);
      case ZplRotation.rotate270:
        return RotatedBox(quarterTurns: 3, child: child);
    }
  }

  /// Simple static method to convert any widget to ZPL with default settings
  ///
  /// This is the easiest way to use the package:
  /// ```dart
  /// String zpl = await ImageZplConverter.convertWidget(myWidget);
  /// ```
  ///
  /// For more control, use the constructor and [convert] method instead.
  static Future<String> convertWidget(
    Widget widget, {
    int width = 560,
    int threshold = 128,
    int xPosition = 0,
    int yPosition = 0,
    ZplRotation rotation = ZplRotation.normal,
    double pixelRatio = 2.0,
    double labelWidthCm = 10.0,
    double labelHeightCm = 5.0,
    int dpi = 203,
  }) async {
    final converter = ImageZplConverter(
      widget,
      width: width,
      threshold: threshold,
      xPosition: xPosition,
      yPosition: yPosition,
      rotation: rotation,
      pixelRatio: pixelRatio,
      labelWidthCm: labelWidthCm,
      labelHeightCm: labelHeightCm,
      dpi: dpi,
    );
    return await converter.convert();
  }
}

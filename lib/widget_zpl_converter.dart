library widget_zpl_converter;

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
/// See [ImageZplConverter.convert] for usage
class ImageZplConverter {
  /// Creates a new [ImageZplConverter]
  ImageZplConverter(
    this.widget, {
    int width = 560,
    this.threshold = 128,
    this.xPosition = 0,
    this.yPosition = 0,
    this.rotation = ZplRotation.normal,
  }) : _originalWidth = width {
    if (width <= 0) {
      throw ArgumentError('Width must be positive');
    }
    if (threshold < 0 || threshold > 255) {
      throw ArgumentError('Threshold must be between 0 and 255');
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

    final bytesPerRow = (width / 8).ceil();
    final totalBytes = bytesPerRow * height;

    final zpl = _generateZpl(totalBytes, bytesPerRow, hexBody);

    return zpl;
  }

  /// Captures the widget as an image
  ///
  /// Returns the image as a [Uint8List]
  Future<Uint8List> _screenshot() async {
    final screenshot = await _screenshotController.captureFromWidget(widget);

    return screenshot.buffer.asUint8List();
  }

  /// Converts the image to greyscale
  img.Image _convertToGreyScale(Uint8List image) {
    final decodedImage = img.decodeImage(image);
    if (decodedImage == null) {
      throw ArgumentError('Failed to decode image. Invalid image format.');
    }

    final greyScaleImage = img.grayscale(decodedImage);

    return greyScaleImage;
  }

  /// Resizes the image to the desired width and height
  ///
  /// Sizes are rounded up to the nearest multiple of 8 for byte divisibility
  /// Preserves original aspect ratio
  img.Image _resizeImage(img.Image image) {
    width = _findNearestEightMultiple(_originalWidth);
    height = _calculateHeight(image);
    final resizedImage = img.copyResize(image, width: width, height: height);

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
    final List<int> pixelBits = <int>[];
    pixelBits.length =
        image.width * image.height; // Pre-allocate for better performance
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
  /// ZPL uses LSB (Least Significant Bit) first bit ordering
  List<int> _byteRepresentation(List<int> bits) {
    if (bits.isEmpty) {
      throw ArgumentError('Bits array cannot be empty');
    }

    final numBytes = (bits.length / 8).ceil();
    final List<int> pixelBytes = List<int>.filled(numBytes, 0);

    // Group bits into bytes using bitwise operations
    // ZPL expects LSB first bit ordering (bit 0 is rightmost)
    for (int i = 0; i < bits.length; i++) {
      final byteIndex = i ~/ 8;
      final bitPosition = i % 8; // LSB first for ZPL

      if (bits[i] == 1) {
        pixelBytes[byteIndex] |= (1 << bitPosition);
      }
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
  /// ZPL GFA command format: ^GFA,a,b,c,data
  /// a = Total bytes in graphic
  /// b = Bytes per row
  /// c = Total bytes in graphic (same as a)
  String _generateZpl(int totalBytes, int byteWidth, String hexBody) {
    final zplCommand =
        '^XA^FO$xPosition,$yPosition^GFA,$totalBytes,$byteWidth,$totalBytes,$hexBody^FS^XZ';

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
}

library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';

/// Converts any Flutter Widget to a print-ready ZPL command. Intended for Label mode printing.
///
/// See [ImageZplConverter.convert] for usage
class ImageZplConverter {
  /// Creates a new [ImageZplConverter]
  ImageZplConverter(this.widget, {this.width = 560});

  /// The widget to be converted to ZPL
  final Widget widget;

  /// The desired width of the ZPL image, defaults to 560
  int width;

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
    final pixelBits = _binarizeImage(resizedImage);
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

    final greyScaleImage = img.grayscale(decodedImage!);

    return greyScaleImage;
  }

  /// Resizes the image to the desired width and height
  ///
  /// Sizes are rounded up to the nearest multiple of 8 for byte divisibility
  /// Size and aspect ratio are constrained to Label mode standards
  img.Image _resizeImage(img.Image image) {
    width = _findNearestEightMultiple(width);
    height = _calculateHeight();
    final resizedImage = img.copyResize(image, width: width, height: height);

    return resizedImage;
  }

  /// Converts the image to binary
  ///
  /// Each pixel is converted to a single bit, with 1 representing a dark pixel
  List<int> _binarizeImage(img.Image image) {
    final List<int> pixelBits = [];

    // Convert image pixels to binary bits
    for (int h = 0; h < image.height; h++) {
      for (int w = 0; w < image.width; w++) {
        final rgb = image.getPixelSafe(w, h);

        Uint32List list = Uint32List.fromList([rgb]);
        Uint8List byteData = list.buffer.asUint8List();

        int bit = 0;

        // Threshold image
        // If pixel is darker than 50% grey, set bit to 1
        if (byteData.first < 128 && byteData.last > 128) {
          bit = 1;
        }

        pixelBits.add(bit);
      }
    }

    return pixelBits;
  }

  /// Converts the binaraized image to bytes
  ///
  /// Each byte represents 8 consecutive pixels
  List<int> _byteRepresentation(List<int> bits) {
    final List<int> pixelBytes = [];

    // Group bits into bytes
    for (int i = 0; i < bits.length; i += 8) {
      // If there are less than 8 bits left, pad with 0s
      if (i + 8 > bits.length) {
        final remaining = 8 - (bits.length - i);
        final lastByte = List.filled(remaining, 0);
        final int val = int.parse(lastByte.join(""), radix: 2);
        pixelBytes.add(val);

        break;
      }

      final byte = bits.sublist(i, i + 8);
      final int val = int.parse(byte.join(""), radix: 2);
      pixelBytes.add(val);
    }

    return pixelBytes;
  }

  /// Converts the byte array to a hex string
  ///
  /// This representation is required by ZPL standards for image printing
  String _hexRepresentation(List<int> bytes) {
    final hexBody = const HexEncoder().convert(bytes);

    return hexBody;
  }

  /// Generates the ZPL command
  ///
  /// Requires the total number of bytes, the number of bytes per row, and the
  /// hex string representation of the image
  String _generateZpl(int totalBytes, int byteWidth, String hexBody) {
    final zplCommand =
        '^XA^FO0,0^GFA,$totalBytes,$totalBytes,$byteWidth,$hexBody^XZ';

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
  /// The height is calculated to be half the width, following Labels' aspect ratio
  int _calculateHeight() {
    int height = width ~/ 2;

    return _findNearestEightMultiple(height);
  }
}

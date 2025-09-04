# Widget ZPL Converter

The `widget_zpl_converter` package helps convert any Flutter widget to a ZPL/ZPL2 command. This is mainly targeted towards developers who need to print **labels** using thermal printers.

## Features

- Convert any Flutter widget to a ZPL/ZPL2 command.
- ZPL/ZPL2 command can be sent to a thermal printer using [esc_pos_utils](https://pub.dev/packages/esc_pos_utils)'s [Generator.rawBytes()](https://pub.dev/documentation/esc_pos_utils/latest/esc_pos_utils/Generator/rawBytes.html) method, or any other packages with similar functionality.
- Supports variable widget sizes (while maintaining aspect ratio).

## Usage

To use this package, simply add `widget_zpl_converter` as a dependency in your `pubspec.yaml` file:

```
dependencies:
  widget_zpl_converter: ^1.0.0
```

Then, import the package in your Dart code:
```
import 'package:widget_zpl_converter/widget_zpl_converter.dart';
```

Create a widget that you want to convert to a ZPL/ZPL2 printing command:
```
final myWidget = Container(
  width: 100,
  height: 100,
  color: Colors.blue,
);
```

## Simple Usage (Recommended)

Convert any widget to ZPL with one line:
```dart
String zpl = await ImageZplConverter.convertWidget(myWidget);
```

## Advanced Usage

For more control over the conversion:
```dart
final converter = ImageZplConverter(
  myWidget,
  width: 400,            // Image width in pixels
  threshold: 128,        // Binarization threshold (0-255)
  xPosition: 50,         // X position on label
  yPosition: 30,         // Y position on label
  rotation: ZplRotation.rotate90,  // Rotation angle
);

String zpl = await converter.convert();
```

The ZPL command is now ready to be sent to your thermal printer!

## Rotation Support

The package supports rotation in 90-degree increments:

### Method 1: Image-level rotation (after screenshot)
```dart
// Rotate the captured image during ZPL conversion
final zplConverter = ImageZplConverter(
  myWidget,
  rotation: ZplRotation.rotate90,  // Rotates the image 90° clockwise
);
```

### Method 2: Widget-level rotation (before screenshot)
```dart
// Create a rotated widget wrapper
final rotatedWidget = ImageZplConverter.createRotatedWidget(
  myWidget, 
  ZplRotation.rotate90
);

// Then convert the rotated widget
final zplConverter = ImageZplConverter(rotatedWidget);
```

### Available rotation options:
- `ZplRotation.normal` - No rotation (0°)
- `ZplRotation.rotate90` - 90° clockwise
- `ZplRotation.rotate180` - 180° rotation
- `ZplRotation.rotate270` - 270° clockwise (90° counterclockwise)

## Example App

A complete example application is included in the `/example` directory that demonstrates all features:

- Interactive widget selection (4 sample widgets)
- Real-time configuration controls (rotation, threshold, positioning)
- Live ZPL output with copy-to-clipboard functionality
- Visual preview of widgets before conversion

To run the example:
```bash
cd example
flutter pub get
flutter run
```

The example app showcases practical usage patterns and provides a testing environment for the package.

## Performance Improvements

This package has been optimized for performance with the following improvements:

- **Efficient memory allocation**: Pre-allocates lists to avoid dynamic resizing
- **Optimized image processing**: Direct pixel value extraction without unnecessary buffer operations
- **Fast bit-to-byte conversion**: Uses bitwise operations instead of string parsing
- **Efficient rotation**: Direct image transformation with proper dimension handling
- **Reduced dependencies**: Removed unnecessary hex package dependency
- **Better error handling**: Validates inputs and provides meaningful error messages

## Time Complexity

- Image binarization: O(width × height) - optimal for pixel processing
- Byte conversion: O(n) where n is number of bits - uses efficient bitwise operations
- Hex conversion: O(n) where n is number of bytes - uses StringBuffer for optimal string concatenation
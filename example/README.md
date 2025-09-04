# Widget ZPL Converter Example

This example app demonstrates the functionality of the `widget_zpl_converter` package, showing how to convert Flutter widgets into ZPL (Zebra Programming Language) commands for thermal printing.

## Features Demonstrated

### 🔄 **Rotation Support**
- Test all rotation angles (0°, 90°, 180°, 270°)
- See how rotation affects the generated ZPL output
- Real-time preview of selected widgets

### 🎛️ **Configurable Parameters**
- **Width**: Adjust image width (200-800px)
- **Threshold**: Control binarization threshold (0-255)
- **Position**: Set X and Y coordinates on the label
- **Rotation**: Choose from 4 rotation options

### 📱 **Sample Widgets**
The app includes 4 different sample widgets to convert:

1. **Simple Text** - Basic text with border styling
2. **Icon Card** - QR code icon with descriptive text
3. **Product Label** - Multi-line product information
4. **Warning Label** - Icon with warning message

### 🖨️ **ZPL Output**
- View generated ZPL commands in a code viewer
- Copy ZPL to clipboard with one click
- See character count and formatting

## Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## How to Use

1. **Select a Widget**: Choose from the dropdown menu which sample widget to convert
2. **Configure Settings**: Adjust rotation, width, threshold, and position parameters
3. **Choose Mode**: 
   - **Normal Mode**: Uses actual screenshot functionality (works on mobile/desktop)
   - **Test Mode**: Generates mock ZPL for testing (automatically enabled on web)
4. **Generate ZPL**: Tap "Convert to ZPL" to generate the ZPL command
5. **Copy Output**: Use the copy button to copy the ZPL to your clipboard
6. **Test Printing**: Send the ZPL command to your Zebra printer

### Test Mode

The app includes a **Test Mode** that automatically activates on web platforms where screenshot functionality may not work properly. In test mode:

- Generates valid ZPL commands with mock image data
- Demonstrates the ZPL command structure and format
- Allows testing of rotation, positioning, and sizing parameters
- Useful for development and demonstration purposes

You can manually toggle test mode on/off using the switch in the configuration section.

## Code Structure

```
example/
├── lib/
│   └── main.dart          # Main demo application
├── pubspec.yaml           # Dependencies including widget_zpl_converter
└── README.md             # This file
```

## Key Code Examples

### Basic Conversion
```dart
final converter = ImageZplConverter(
  myWidget,
  width: 400,
  threshold: 128,
  rotation: ZplRotation.rotate90,
);

final zplCommand = await converter.convert();
```

### Widget-Level Rotation
```dart
final rotatedWidget = ImageZplConverter.createRotatedWidget(
  myWidget, 
  ZplRotation.rotate90
);

final converter = ImageZplConverter(rotatedWidget);
```

## ZPL Output Example

The generated ZPL commands follow this format:
```
^XA^FO0,0^GFA,1234,56,1234,FFFF00...^FS^XZ
```

Where:
- `^XA` - Start format
- `^FO0,0` - Field origin (position)
- `^GFA` - Graphic field with data
- `^FS` - Field separator
- `^XZ` - End format

## Testing with Printers

To test the generated ZPL:

1. Copy the ZPL output from the app
2. Send it to your Zebra printer via:
   - Zebra utilities
   - Raw socket connection
   - Print spooler
   - USB/Serial connection

## Performance Notes

The example demonstrates the optimized performance features:
- Efficient memory allocation
- Fast bit-to-byte conversion
- Optimized hex encoding
- Direct pixel processing

For large widgets or high-resolution outputs, conversion typically completes in under 1 second.

## Troubleshooting

### DebugService Errors on Web
If you see "DebugService: Error serving requests - Cannot send Null" errors in the console when running on web, these are Flutter web debugging artifacts and do not affect app functionality. The app includes conditional debug printing to minimize these issues.

### Screenshot Issues
If screenshot functionality doesn't work on your platform:
1. Enable **Test Mode** using the toggle switch
2. Try running on a different platform (mobile/desktop vs web)
3. Check console for specific error messages

### Performance
- Test mode generates smaller, optimized mock ZPL for demonstration
- Normal mode processes actual screenshot data which may take longer
- Large widgets may require more processing time
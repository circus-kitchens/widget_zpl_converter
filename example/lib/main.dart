import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widget_zpl_converter/widget_zpl_converter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget ZPL Converter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ZplConverterDemo(),
    );
  }
}

class ZplConverterDemo extends StatefulWidget {
  const ZplConverterDemo({super.key});

  @override
  State<ZplConverterDemo> createState() => _ZplConverterDemoState();
}

class _ZplConverterDemoState extends State<ZplConverterDemo> {
  String _zplOutput = '';
  bool _isLoading = false;
  ZplRotation _selectedRotation = ZplRotation.normal;
  int _threshold = 128;
  int _width = 560;
  int _xPosition = 0;
  int _yPosition = 0;
  int _selectedWidgetIndex = 0;
  // Removed test mode - always use actual conversion // Test mode toggle

  final List<Widget> _sampleWidgets = [
    // Simple Text Widget
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Hello ZPL!',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),

    // Card with Icon
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code, size: 48, color: Colors.black),
          SizedBox(height: 8),
          Text(
            'Scan Me',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),

    // Product Label
    Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PRODUCT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Widget ZPL Demo',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          SizedBox(height: 4),
          Text(
            'SKU: WZD-001',
            style: TextStyle(fontSize: 10, color: Colors.black),
          ),
          Text(
            'Price: \$29.99',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),

    // Custom Graphics
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.black, size: 20),
              SizedBox(width: 8),
              Text(
                'FRAGILE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Handle with Care',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    ),
  ];

  final List<String> _widgetNames = [
    'Simple Text',
    'Icon Card',
    'Product Label',
    'Warning Label',
  ];

  @override
  void initState() {
    super.initState();
    // No initialization needed - always use actual conversion
  }

  Future<void> _convertToZpl() async {
    setState(() {
      _isLoading = true;
      _zplOutput = '';
    });

    try {
      // Use the simple static method for conversion
      final zpl = await ImageZplConverter.convertWidget(
        _sampleWidgets[_selectedWidgetIndex],
        width: _width,
        threshold: _threshold,
        xPosition: _xPosition,
        yPosition: _yPosition,
        rotation: _selectedRotation,
      );

      // Validate the generated ZPL before setting state
      if (zpl.isNotEmpty && !zpl.contains('null')) {
        setState(() {
          _zplOutput = zpl;
          _isLoading = false;
        });

        // Show success message
        if (mounted && context.mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'ZPL generated successfully! ${zpl.length} characters',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            if (!kIsWeb) {
              debugPrint('Error showing success snackbar: $e');
            }
          }
        }
      } else {
        throw Exception('Generated ZPL is invalid or contains null values');
      }
    } catch (e, stackTrace) {
      if (!kIsWeb) {
        debugPrint('Error during conversion: $e');
        debugPrint('Stack trace: $stackTrace');
      }

      setState(() {
        _zplOutput = '''Error during conversion: $e

This might happen if:
1. Screenshot functionality is not supported on this platform
2. The widget is too complex to capture
3. There's an issue with image processing

Try:
- Running on a mobile device or desktop
- Selecting a different widget
- Reducing the width/threshold values

Technical details:
$stackTrace''';
        _isLoading = false;
      });

      // Show error message
      if (mounted && context.mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Conversion failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        } catch (snackbarError) {
          if (!kIsWeb) {
            debugPrint('Error showing error snackbar: $snackbarError');
          }
        }
      }
    }
  }

  void _copyToClipboard() {
    if (_zplOutput.isNotEmpty && _zplOutput != 'null') {
      try {
        Clipboard.setData(ClipboardData(text: _zplOutput));
        if (mounted && context.mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ZPL copied to clipboard!')),
            );
          } catch (e) {
            if (!kIsWeb) {
              debugPrint('Error showing clipboard success snackbar: $e');
            }
          }
        }
      } catch (e) {
        if (!kIsWeb) {
          debugPrint('Error copying to clipboard: $e');
        }
        if (mounted && context.mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to copy: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          } catch (snackbarError) {
            if (!kIsWeb) {
              debugPrint(
                'Error showing clipboard error snackbar: $snackbarError',
              );
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget ZPL Converter Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Widget Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Widget to Convert',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedWidgetIndex,
                      decoration: const InputDecoration(
                        labelText: 'Sample Widget',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(_widgetNames.length, (index) {
                        return DropdownMenuItem(
                          value: index,
                          child: Text(_widgetNames[index]),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _selectedWidgetIndex = value!;
                          _zplOutput = '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Preview:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: _sampleWidgets[_selectedWidgetIndex],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Configuration Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rotation
                    DropdownButtonFormField<ZplRotation>(
                      initialValue: _selectedRotation,
                      decoration: const InputDecoration(
                        labelText: 'Rotation',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ZplRotation.normal,
                          child: Text('0° (Normal)'),
                        ),
                        DropdownMenuItem(
                          value: ZplRotation.rotate90,
                          child: Text('90° Clockwise'),
                        ),
                        DropdownMenuItem(
                          value: ZplRotation.rotate180,
                          child: Text('180°'),
                        ),
                        DropdownMenuItem(
                          value: ZplRotation.rotate270,
                          child: Text('270° Clockwise'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRotation = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Width slider
                    Text('Width: $_width px'),
                    Slider(
                      value: _width.toDouble(),
                      min: 200,
                      max: 800,
                      divisions: 30,
                      onChanged: (value) {
                        setState(() {
                          _width = value.round();
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Threshold slider
                    Text('Threshold: $_threshold'),
                    Slider(
                      value: _threshold.toDouble(),
                      min: 0,
                      max: 255,
                      divisions: 255,
                      onChanged: (value) {
                        setState(() {
                          _threshold = value.round();
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Position controls
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _xPosition.toString(),
                            decoration: const InputDecoration(
                              labelText: 'X Position',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _xPosition = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _yPosition.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Y Position',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _yPosition = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Convert Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _convertToZpl,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.transform),
              label: Text(_isLoading ? 'Converting...' : 'Convert to ZPL'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // ZPL Output
            if (_zplOutput.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Generated ZPL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy to clipboard',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _zplOutput,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ZPL Length: ${_zplOutput.length} characters',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tip: Test this ZPL at labelary.com/zpl.html to validate format',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

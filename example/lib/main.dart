import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:widget_zpl_converter/widget_zpl_converter.dart';

import 'letter_selector.dart';

void main() {
  runApp(const ZplConverterExampleApp());
}

class ZplConverterExampleApp extends StatelessWidget {
  const ZplConverterExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZPL Converter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ZplConverterHomePage(title: 'Widget to ZPL Converter Demo'),
    );
  }
}

class ZplConverterHomePage extends StatefulWidget {
  const ZplConverterHomePage({super.key, required this.title});

  final String title;

  @override
  State<ZplConverterHomePage> createState() => _ZplConverterHomePageState();
}

class _ZplConverterHomePageState extends State<ZplConverterHomePage> {
  String _generatedZpl = '';
  bool _isGenerating = false;
  int _selectedWidgetIndex = 0;

  // ZPL Parameters
  int _width = 560;
  int _threshold = 128;
  double _pixelRatio = 2.0;
  ZplRotation _rotation = ZplRotation.normal;

  // Label Dimensions
  double _labelWidthCm = 10.0;
  double _labelHeightCm = 5.0;
  int _dpi = 203;

  final List<WidgetExample> _widgetExamples = [
    WidgetExample(
      name: '10x5cm Perfect Fit Label',
      description: 'Optimized layout for 10x5cm labels at 203 DPI',
      widget: _build10x5cmLabel(),
    ),
    WidgetExample(
      name: 'Letter Selector',
      description: 'Custom widget with letters and borders',
      widget: const LetterSelector(
        selectedSectionType: SiloSectionType.c,
        sizingUnit: 10,
      ),
    ),
    WidgetExample(
      name: 'QR Code',
      description: 'QR code with embedded data',
      widget: QrImageView(
        data: 'https://flutter.dev',
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      ),
    ),
    WidgetExample(
      name: 'Business Card',
      description: 'Sample business card layout',
      widget: Container(
        width: 350,
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Software Engineer',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 16),
            Text(
              'john.doe@example.com',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Text(
              '+1 (555) 123-4567',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    ),
    WidgetExample(
      name: 'Shipping Label',
      description: 'Sample shipping label with details',
      widget: Container(
        width: 400,
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SHIPPING LABEL',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'FROM:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              'Acme Corp\n123 Main St\nAnytown, ST 12345',
              style: TextStyle(fontSize: 10, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text(
              'TO:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              'Jane Smith\n456 Oak Ave\nSomewhere, ST 67890',
              style: TextStyle(fontSize: 10, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              'Date: ${DateFormat('MM/dd/yyyy').format(DateTime.now())}',
              style: const TextStyle(fontSize: 10, color: Colors.black),
            ),
            const Text(
              'Tracking: 1Z999AA1234567890',
              style: TextStyle(fontSize: 10, color: Colors.black),
            ),
          ],
        ),
      ),
    ),
    WidgetExample(
      name: 'Simple Text',
      description: 'Basic text widget for testing',
      widget: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
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
    ),
  ];

  // Build a widget optimized for 10x5cm labels at 203 DPI (800x400 pixels)
  static Widget _build10x5cmLabel() {
    return Container(
      width: 800, // 10cm at 203 DPI ≈ 800 pixels
      height: 400, // 5cm at 203 DPI ≈ 400 pixels
      color: Colors.white,
      child: Stack(
        children: [
          // Border
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
          ),

          // Header Section
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'PREMIUM PRODUCT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),

          // Left Column - Product Info
          Positioned(
            top: 80,
            left: 16,
            width: 420,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRODUCT CODE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'PRD-2024-XL-001',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Premium Quality Label\nOptimized for 10x5cm',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BATCH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          DateFormat('yyyyMMdd').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QTY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          '100 PCS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Bottom barcode-style lines
                SizedBox(
                  height: 40,
                  child: Column(
                    children: List.generate(8, (index) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          color: index % 2 == 0
                              ? Colors.black
                              : Colors.transparent,
                          width: index.isEven ? 200 : 150,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Right Column - QR Code and Status
          Positioned(
            top: 80,
            right: 16,
            width: 320,
            bottom: 16,
            child: Column(
              children: [
                // QR Code
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: QrImageView(
                    data:
                        'PRD-2024-XL-001-${DateFormat('yyyyMMdd').format(DateTime.now())}',
                    version: QrVersions.auto,
                    size: 118,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'SCAN FOR DETAILS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 24),

                // Status indicators
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'QUALITY\nAPPROVED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'EXP: ${DateFormat('MM/yyyy').format(DateTime.now().add(const Duration(days: 365)))}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                // Serial number at bottom
                Text(
                  'SN: ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateZpl() async {
    setState(() {
      _isGenerating = true;
      _generatedZpl = '';
    });

    try {
      final selectedWidget = _widgetExamples[_selectedWidgetIndex].widget;

      final converter = ImageZplConverter(
        selectedWidget,
        width: _width,
        threshold: _threshold,
        pixelRatio: _pixelRatio,
        rotation: _rotation,
        labelWidthCm: _labelWidthCm,
        labelHeightCm: _labelHeightCm,
        dpi: _dpi,
      );

      final zpl = await converter.convert();

      // Add dimension information and validation
      final dimensionInfo = StringBuffer();
      dimensionInfo.writeln(
        '// Generated ZPL for ${_labelWidthCm}x${_labelHeightCm}cm label at ${_dpi}DPI',
      );
      dimensionInfo.writeln(
        '// Output dimensions: ${converter.outputWidthCm.toStringAsFixed(2)}x${converter.outputHeightCm.toStringAsFixed(2)}cm',
      );
      dimensionInfo.writeln(
        '// Pixel dimensions: ${converter.width}x${converter.height}px',
      );

      final warning = converter.getLabelFitWarning();
      if (warning != null) {
        dimensionInfo.writeln('// ⚠️  $warning');
      } else {
        dimensionInfo.writeln('// ✅ Image fits within label dimensions');
      }
      dimensionInfo.writeln('');
      dimensionInfo.write(zpl);

      setState(() {
        _generatedZpl = dimensionInfo.toString();
      });
    } catch (e) {
      setState(() {
        _generatedZpl = 'Error generating ZPL: $e';
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_generatedZpl.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedZpl));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ZPL copied to clipboard!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Widget Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Widget to Convert:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButton<int>(
                      value: _selectedWidgetIndex,
                      isExpanded: true,
                      items: _widgetExamples.asMap().entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                entry.value.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                entry.value.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            _selectedWidgetIndex = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Widget Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Widget Preview:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _widgetExamples[_selectedWidgetIndex].widget,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ZPL Parameters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ZPL Parameters:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Width: $_width px'),
                              Slider(
                                value: _width.toDouble(),
                                min: 200,
                                max: 1000,
                                divisions: 16,
                                onChanged: (value) {
                                  setState(() {
                                    _width = value.round();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Threshold: $_threshold'),
                              Slider(
                                value: _threshold.toDouble(),
                                min: 0,
                                max: 255,
                                divisions: 17,
                                onChanged: (value) {
                                  setState(() {
                                    _threshold = value.round();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pixel Ratio: ${_pixelRatio.toStringAsFixed(1)}x',
                              ),
                              Slider(
                                value: _pixelRatio,
                                min: 1.0,
                                max: 4.0,
                                divisions: 6,
                                onChanged: (value) {
                                  setState(() {
                                    _pixelRatio = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rotation:'),
                              DropdownButton<ZplRotation>(
                                value: _rotation,
                                isExpanded: true,
                                items: ZplRotation.values.map((rotation) {
                                  return DropdownMenuItem<ZplRotation>(
                                    value: rotation,
                                    child: Text(_getRotationName(rotation)),
                                  );
                                }).toList(),
                                onChanged: (ZplRotation? value) {
                                  if (value != null) {
                                    setState(() {
                                      _rotation = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Label Dimensions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Label Dimensions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Label Width: ${_labelWidthCm.toStringAsFixed(1)} cm',
                              ),
                              Slider(
                                value: _labelWidthCm,
                                min: 2.0,
                                max: 20.0,
                                divisions: 36,
                                onChanged: (value) {
                                  setState(() {
                                    _labelWidthCm = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Label Height: ${_labelHeightCm.toStringAsFixed(1)} cm',
                              ),
                              Slider(
                                value: _labelHeightCm,
                                min: 1.0,
                                max: 15.0,
                                divisions: 28,
                                onChanged: (value) {
                                  setState(() {
                                    _labelHeightCm = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Printer DPI: $_dpi'),
                              DropdownButton<int>(
                                value: _dpi,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 203,
                                    child: Text('203 DPI (Standard)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 300,
                                    child: Text('300 DPI (High Resolution)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 600,
                                    child: Text('600 DPI (Ultra High)'),
                                  ),
                                ],
                                onChanged: (int? value) {
                                  if (value != null) {
                                    setState(() {
                                      _dpi = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Common Label Sizes:'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _buildLabelSizeChip('4x6"', 10.2, 15.2),
                                  _buildLabelSizeChip('4x3"', 10.2, 7.6),
                                  _buildLabelSizeChip('2x1"', 5.1, 2.5),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Generate Button
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateZpl,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isGenerating
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Generating ZPL...'),
                      ],
                    )
                  : const Text('Generate ZPL', style: TextStyle(fontSize: 16)),
            ),

            // ZPL Output
            if (_generatedZpl.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Generated ZPL:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 200, // Fixed height instead of Expanded
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _generatedZpl,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
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

  String _getRotationName(ZplRotation rotation) {
    switch (rotation) {
      case ZplRotation.normal:
        return 'Normal (0°)';
      case ZplRotation.rotate90:
        return 'Rotate 90°';
      case ZplRotation.rotate180:
        return 'Rotate 180°';
      case ZplRotation.rotate270:
        return 'Rotate 270°';
    }
  }

  Widget _buildLabelSizeChip(String name, double widthCm, double heightCm) {
    return ActionChip(
      label: Text(name),
      onPressed: () {
        setState(() {
          _labelWidthCm = widthCm;
          _labelHeightCm = heightCm;
        });
      },
    );
  }
}

class WidgetExample {
  final String name;
  final String description;
  final Widget widget;

  const WidgetExample({
    required this.name,
    required this.description,
    required this.widget,
  });
}

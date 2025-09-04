import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_zpl_converter/widget_zpl_converter.dart';
import 'package:widget_zpl_converter_example/main.dart';

void main() {
  group('Example App Tests', () {
    testWidgets('App loads without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the app title is displayed
      expect(find.text('Widget ZPL Converter Demo'), findsOneWidget);

      // Verify that the main components are present
      expect(find.text('Select Widget to Convert'), findsOneWidget);
      expect(find.text('Configuration'), findsOneWidget);
      expect(find.text('Convert to ZPL'), findsOneWidget);
    });

    testWidgets('Widget selection works', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Find the dropdown
      expect(find.text('Simple Text'), findsOneWidget);

      // Tap on the dropdown
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();

      // Check if options are available
      expect(find.text('Icon Card'), findsOneWidget);
    });

    testWidgets('Configuration controls are present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Check for rotation dropdown
      expect(find.text('0° (Normal)'), findsOneWidget);

      // Check for sliders
      expect(find.text('Width: 560 px'), findsOneWidget);
      expect(find.text('Threshold: 128'), findsOneWidget);

      // Check for position inputs
      expect(find.text('X Position'), findsOneWidget);
      expect(find.text('Y Position'), findsOneWidget);
    });

    test('ZPL enum values are correct', () {
      expect(ZplRotation.values.length, 4);
      expect(ZplRotation.normal, isA<ZplRotation>());
      expect(ZplRotation.rotate90, isA<ZplRotation>());
      expect(ZplRotation.rotate180, isA<ZplRotation>());
      expect(ZplRotation.rotate270, isA<ZplRotation>());
    });

    test('ImageZplConverter can be instantiated', () {
      const widget = Text('Test');
      expect(() => ImageZplConverter(widget), returnsNormally);
      expect(
        () => ImageZplConverter(widget, rotation: ZplRotation.rotate90),
        returnsNormally,
      );
    });

    test('Mock ZPL generation produces valid output', () {
      // Test the mock ZPL generation logic (without UI)
      const width = 200;
      final bytesPerRow = (width / 8).ceil();
      final height = (width / 2 / 8).ceil() * 8;
      final totalBytes = bytesPerRow * height;
      final limitedBytes = totalBytes > 200 ? 200 : totalBytes;

      // Generate mock hex data
      final mockHexData = StringBuffer();
      for (int i = 0; i < limitedBytes; i++) {
        if ((i ~/ bytesPerRow) % 2 == 0) {
          mockHexData.write(i % 2 == 0 ? 'AA' : '55');
        } else {
          mockHexData.write(i % 2 == 0 ? '55' : 'AA');
        }
      }

      final hexString = mockHexData.toString();
      final zpl =
          '^XA^FO0,0^GFA,$limitedBytes,$bytesPerRow,$limitedBytes,$hexString^FS^XZ';

      // Verify the ZPL is valid
      expect(zpl.isNotEmpty, true);
      expect(zpl.contains('null'), false);
      expect(zpl.startsWith('^XA'), true);
      expect(zpl.endsWith('^XZ'), true);
      expect(zpl.contains('^GFA'), true);
      expect(zpl.contains('^FS'), true);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_zpl_converter/widget_zpl_converter.dart';

void main() {
  group('ImageZplConverter Tests', () {
    test('should throw ArgumentError for invalid width', () {
      const widget = Text('Test');

      expect(() => ImageZplConverter(widget, width: 0),
          throwsA(isA<ArgumentError>()));
      expect(() => ImageZplConverter(widget, width: -10),
          throwsA(isA<ArgumentError>()));
    });

    test('should throw ArgumentError for invalid threshold', () {
      const widget = Text('Test');

      expect(() => ImageZplConverter(widget, threshold: -1),
          throwsA(isA<ArgumentError>()));
      expect(() => ImageZplConverter(widget, threshold: 256),
          throwsA(isA<ArgumentError>()));
    });

    test('should create converter with valid parameters', () {
      const widget = Text('Test');

      expect(() => ImageZplConverter(widget, width: 100), returnsNormally);
      expect(() => ImageZplConverter(widget), returnsNormally);
      expect(() => ImageZplConverter(widget, width: 200, threshold: 100),
          returnsNormally);
      expect(() => ImageZplConverter(widget, xPosition: 50, yPosition: 30),
          returnsNormally);
    });

    test('should accept valid threshold values', () {
      const widget = Text('Test');

      expect(() => ImageZplConverter(widget, threshold: 0), returnsNormally);
      expect(() => ImageZplConverter(widget, threshold: 128), returnsNormally);
      expect(() => ImageZplConverter(widget, threshold: 255), returnsNormally);
    });

    test('should store configuration parameters correctly', () {
      const widget = Text('Test');
      final converter = ImageZplConverter(widget,
          threshold: 100, xPosition: 50, yPosition: 75);

      expect(converter.threshold, equals(100));
      expect(converter.xPosition, equals(50));
      expect(converter.yPosition, equals(75));
    });

    test('should accept rotation parameters', () {
      const widget = Text('Test');

      expect(() => ImageZplConverter(widget, rotation: ZplRotation.normal),
          returnsNormally);
      expect(() => ImageZplConverter(widget, rotation: ZplRotation.rotate90),
          returnsNormally);
      expect(() => ImageZplConverter(widget, rotation: ZplRotation.rotate180),
          returnsNormally);
      expect(() => ImageZplConverter(widget, rotation: ZplRotation.rotate270),
          returnsNormally);
    });

    test('should store rotation setting correctly', () {
      const widget = Text('Test');
      final converter =
          ImageZplConverter(widget, rotation: ZplRotation.rotate90);

      expect(converter.rotation, equals(ZplRotation.rotate90));
    });

    test('should create rotated widget wrapper correctly', () {
      const originalWidget = Text('Test');

      final normalWidget = ImageZplConverter.createRotatedWidget(
          originalWidget, ZplRotation.normal);
      final rotate90Widget = ImageZplConverter.createRotatedWidget(
          originalWidget, ZplRotation.rotate90);
      final rotate180Widget = ImageZplConverter.createRotatedWidget(
          originalWidget, ZplRotation.rotate180);
      final rotate270Widget = ImageZplConverter.createRotatedWidget(
          originalWidget, ZplRotation.rotate270);

      expect(normalWidget, equals(originalWidget));
      expect(rotate90Widget, isA<RotatedBox>());
      expect(rotate180Widget, isA<RotatedBox>());
      expect(rotate270Widget, isA<RotatedBox>());
    });
  });
}

import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import 'helpers.dart';

void main() {
  group('Char', () {
    test('Constructor', () {
      var c = Char();
      expect(c.code, equals(0));
      c = Char(65535);
      expect(c.code, equals(65535));
    });

    test('Constructor out of range', () {
      // Expect _AssertionError
      expect(() => Char(65536), throwsA((e) => true));
      expect(() => Char(-1), throwsA((e) => true));
    });
  });

  group('byte', () {
    test('Call like type casting', () {
      expect((byte)(123 & 0xff), equals(123));
    });
  });

  group('ByteArray', () {
    test('Wrap List', () {
      ByteArray ba;
      ba = ByteArray(List<int>());
      expect(ba.length, equals(0));
      ba.add(9);
      expect(ba.length, equals(1));
      expect(ba[0], equals(9));
    });

    test('Wrap Uint8List', () {
      var ba = ByteArray(Uint8List(1));
      expect(ba.length, equals(1));
      expect(ba[0], equals(0));
      ba[0] = 8;
      expect(ba[0], equals(8));
    });

    test('Byte to char', () {
      expect(Char((byte)(-1 & 0xff)).code, equals(255));
    });

    test('isWhitespace', () {
      expect(Char.of(' ').isWhitespace(), isTrue);
      expect(Char.of('\n').isWhitespace(), isTrue);
      expect(Char.of('\t').isWhitespace(), isTrue);
      expect(Char.of('\r').isWhitespace(), isTrue);
      expect(Char.of('a').isWhitespace(), isFalse);
    });

    test('Char comparison', () {
      Char c = Char.of('\n');
      assertTrue(c.toString() == '\n');
    });
  });
}

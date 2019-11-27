import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  ZsciiEncoding encoding;

  setUp(() {
    encoding = ZsciiEncoding(DefaultAccentTable());
  });

  test('IsZsciiCharacterAscii', () {
    assertTrue(encoding.isZsciiChar(Char.of('A')));
    assertTrue(encoding.isZsciiChar(Char.of('M')));
    assertTrue(encoding.isZsciiChar(Char.of('Z')));
    assertTrue(encoding.isZsciiChar(Char.of('a')));
    assertTrue(encoding.isZsciiChar(Char.of('m')));
    assertTrue(encoding.isZsciiChar(Char.of('z')));
  });

  test('IsZsciiCharacterExtra', () {
    assertEquals(10, Char.of('\n').toInt());
    assertTrue(encoding.isZsciiChar(Char(IZsciiEncoding.NULL)));
    assertTrue(encoding.isZsciiChar(Char(IZsciiEncoding.NEWLINE)));
    assertTrue(encoding.isZsciiChar(Char(IZsciiEncoding.ESCAPE)));
    assertTrue(encoding.isZsciiChar(Char(IZsciiEncoding.DELETE)));
  });

  test('IsConvertableToZscii', () {
    assertTrue(encoding.isConvertibleToZscii(Char.of('A')));
    assertTrue(encoding.isConvertibleToZscii(Char.of('M')));
    assertTrue(encoding.isConvertibleToZscii(Char.of('Z')));
    assertTrue(encoding.isConvertibleToZscii(Char.of('a')));
    assertTrue(encoding.isConvertibleToZscii(Char.of('m')));
    assertTrue(encoding.isConvertibleToZscii(Char.of('z')));

    assertTrue(encoding.isConvertibleToZscii(Char.of('\n')));
    assertFalse(encoding.isConvertibleToZscii(Char.of('\u0007')));
  });

  test('GetUnicode', () {
    assertEquals('A', encoding.getUnicodeChar(Char.of('A')));
    assertEquals('M', encoding.getUnicodeChar(Char.of('M')));
    assertEquals('Z', encoding.getUnicodeChar(Char.of('Z')));
    assertEquals('a', encoding.getUnicodeChar(Char.of('a')));
    assertEquals('m', encoding.getUnicodeChar(Char.of('m')));
    assertEquals('z', encoding.getUnicodeChar(Char.of('z')));
    assertEquals('?', encoding.getUnicodeChar(Char.of('\u0007')));
    assertEquals('\n', encoding.getUnicodeChar(Char(IZsciiEncoding.NEWLINE)));
    assertEquals('\u0000', encoding.getUnicodeChar(Char(IZsciiEncoding.NULL)));
    assertEquals('\x00', encoding.getUnicodeChar(Char(IZsciiEncoding.NULL)));
    assertEquals(0, encoding.getUnicodeChar(Char(IZsciiEncoding.NULL)).toInt());
    assertEquals('?', encoding.getUnicodeChar(Char(IZsciiEncoding.DELETE)));
  });

  test('GetZChar', () {
    assertEquals('A', encoding.getZsciiChar(Char.of('A')));
    assertEquals('M', encoding.getZsciiChar(Char.of('M')));
    assertEquals('Z', encoding.getZsciiChar(Char.of('Z')));

    assertEquals('a', encoding.getZsciiChar(Char.of('a')));
    assertEquals('m', encoding.getZsciiChar(Char.of('m')));
    assertEquals('z', encoding.getZsciiChar(Char.of('z')));
    assertEquals(0, encoding.getZsciiChar(Char.of('\u0007')));
  });

  test('IsCursorKey', () {
    assertTrue(ZsciiEncoding.isCursorKey(Char(IZsciiEncoding.CURSOR_UP)));
    assertTrue(ZsciiEncoding.isCursorKey(Char(IZsciiEncoding.CURSOR_DOWN)));
    assertTrue(ZsciiEncoding.isCursorKey(Char(IZsciiEncoding.CURSOR_LEFT)));
    assertTrue(ZsciiEncoding.isCursorKey(Char(IZsciiEncoding.CURSOR_RIGHT)));
    assertFalse(ZsciiEncoding.isCursorKey(Char(IZsciiEncoding.NEWLINE)));
  });

  test('StandardTable', () {
    assertEquals(69, DefaultAccentTable().getLength());
  });

  test('ToLowerCase', () {
    assertEquals('a', encoding.toLower(Char.of('A')));
    assertEquals(155, encoding.toLower(Char(158)));
  });
}

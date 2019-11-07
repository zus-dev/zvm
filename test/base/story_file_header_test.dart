import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  MockMemory memory;
  StoryFileHeader fileHeader;

  setUp(() {
    memory = MockMemory();
    fileHeader = DefaultStoryFileHeader(memory);
  });

  test('GetVersion', () {
    when(memory.readUnsigned8(0x00)).thenReturn(Char(3));
    assertEquals(3, fileHeader.getVersion());
    verify(memory.readUnsigned8(0x00)).called(1);
  });

  test('GetSerialNumber', () {
    when(memory.readUnsigned8(0x012)).thenReturn(Char.of('0'));
    when(memory.readUnsigned8(0x013)).thenReturn(Char.of('5'));
    when(memory.readUnsigned8(0x014)).thenReturn(Char.of('1'));
    when(memory.readUnsigned8(0x015)).thenReturn(Char.of('2'));
    when(memory.readUnsigned8(0x016)).thenReturn(Char.of('0'));
    when(memory.readUnsigned8(0x017)).thenReturn(Char.of('9'));
    assertEquals("051209", fileHeader.getSerialNumber());
  });

  test('GetFileLengthV3', () {
    when(memory.readUnsigned8(0x00)).thenReturn(Char(3));
    when(memory.readUnsigned16(0x1a)).thenReturn(Char(4718));
    assertEquals(4718 * 2, fileHeader.getFileLength());
  });

  test('GetFileLengthV4', () {
    when(memory.readUnsigned8(0x00)).thenReturn(Char(4));
    when(memory.readUnsigned16(0x1a)).thenReturn(Char(4718));
    assertEquals(4718 * 4, fileHeader.getFileLength());
    verify(memory.readUnsigned8(0x00)).called(2);
  });

  test('GetFileLengthV8', () {
    when(memory.readUnsigned8(0x00)).thenReturn(Char(8));
    when(memory.readUnsigned16(0x1a)).thenReturn(Char(4718));
    assertEquals(4718 * 8, fileHeader.getFileLength());
    verify(memory.readUnsigned8(0x00)).called(2);
  });

  test('SetInterpreterVersionV5', () {
    // Story file version 4 or 5: version number as string
    when(memory.readUnsigned8(0x00)).thenReturn(Char(5));
    fileHeader.setInterpreterVersion(4);
    verify(memory.readUnsigned8(0x00)).called(2);
    verify(memory.writeUnsigned8(0x1f, Char.of('4'))).called(1);
  });

  test('SetInterpreterVersionV8', () {
    // Story file version > 5: version number as value
    when(memory.readUnsigned8(0x00)).thenReturn(Char(8));
    fileHeader.setInterpreterVersion(4);
    verify(memory.readUnsigned8(0x00)).called(2);
    verify(memory.writeUnsigned8(0x1f, Char(4))).called(1);
  });

  test('IsEnabledNull', () {
    // This is not matched in the code
    assertFalse(fileHeader.isEnabled(Attribute.SUPPORTS_STATUSLINE));
  });

  test('SetTranscripting', () {
    when(memory.readUnsigned16(0x10)).thenReturn(Char(0));
    fileHeader.setEnabled(Attribute.TRANSCRIPTING, true);
    fileHeader.setEnabled(Attribute.TRANSCRIPTING, false);
    verify(memory.readUnsigned16(0x10)).callCount > 0;
    verify(memory.writeUnsigned16(0x10, Char(1))).called(1);
    verify(memory.writeUnsigned16(0x10, Char(0))).called(1);
  });

  test('IsTranscriptingEnabled', () {
    var responses = [Char(1), Char(0)];
    when(memory.readUnsigned16(0x10)).thenAnswer((_) => responses.removeAt(0));
    assertTrue(fileHeader.isEnabled(Attribute.TRANSCRIPTING));
    assertFalse(fileHeader.isEnabled(Attribute.TRANSCRIPTING));
    verify(memory.readUnsigned16(0x10)).called(2);
  });

  test('SetForceFixedFont', () {
    when(memory.readUnsigned16(0x10)).thenReturn(Char(1));
    fileHeader.setEnabled(Attribute.FORCE_FIXED_FONT, true);
    fileHeader.setEnabled(Attribute.FORCE_FIXED_FONT, false);
    verify(memory.readUnsigned16(0x10)).callCount > 0;
    verify(memory.writeUnsigned16(0x10, Char(3))).called(1);
    verify(memory.writeUnsigned16(0x10, Char(1))).called(1);
  });

  test('IsForceFixedFont', () {
    var responses = [Char(6), Char(5)];
    when(memory.readUnsigned16(0x10)).thenAnswer((_) => responses.removeAt(0));
    assertTrue(fileHeader.isEnabled(Attribute.FORCE_FIXED_FONT));
    assertFalse(fileHeader.isEnabled(Attribute.FORCE_FIXED_FONT));
    verify(memory.readUnsigned16(0x10)).called(2);
  });

  test('SetSupportsTimedInput', () {
    var responses = [Char(3), Char(131)];
    when(memory.readUnsigned8(0x01)).thenAnswer((_) => responses.removeAt(0));
    fileHeader.setEnabled(Attribute.SUPPORTS_TIMED_INPUT, true);
    fileHeader.setEnabled(Attribute.SUPPORTS_TIMED_INPUT, false);
    verify(memory.readUnsigned8(0x01)).called(2);
    verify(memory.writeUnsigned8(0x01, Char(131))).called(1);
    verify(memory.writeUnsigned8(0x01, Char(3))).called(1);
  });

  test('IsScoreGame', () {
    var responses = [Char(5), Char(7)];
    when(memory.readUnsigned8(0x01)).thenAnswer((_) => responses.removeAt(0));
    assertTrue(fileHeader.isEnabled(Attribute.SCORE_GAME));
    assertFalse(fileHeader.isEnabled(Attribute.SCORE_GAME));
    verify(memory.readUnsigned8(0x01)).called(2);
  });

  test('SetSupportsFixed', () {
    var responses = [Char(1), Char(17)];
    when(memory.readUnsigned8(0x01)).thenAnswer((_) => responses.removeAt(0));
    fileHeader.setEnabled(Attribute.SUPPORTS_FIXED_FONT, true);
    fileHeader.setEnabled(Attribute.SUPPORTS_FIXED_FONT, false);
    verify(memory.readUnsigned8(0x01)).called(2);
    verify(memory.writeUnsigned8(0x01, Char(17))).called(1);
    verify(memory.writeUnsigned8(0x01, Char(1))).called(1);
  });

  test('SetSupportsBold', () {
    var responses = [Char(1), Char(5)];
    when(memory.readUnsigned8(0x01)).thenAnswer((_) => responses.removeAt(0));
    fileHeader.setEnabled(Attribute.SUPPORTS_BOLD, true);
    fileHeader.setEnabled(Attribute.SUPPORTS_BOLD, false);
    verify(memory.readUnsigned8(0x01)).called(2);
    verify(memory.writeUnsigned8(0x01, Char(5))).called(1);
    verify(memory.writeUnsigned8(0x01, Char(1))).called(1);
  });

  test('SetSupportsItalic', () {
    var responses = [Char(1), Char(9)];
    when(memory.readUnsigned8(0x01)).thenAnswer((_) => responses.removeAt(0));
    fileHeader.setEnabled(Attribute.SUPPORTS_ITALIC, true);
    fileHeader.setEnabled(Attribute.SUPPORTS_ITALIC, false);
    verify(memory.readUnsigned8(0x01)).called(2);
    verify(memory.writeUnsigned8(0x01, Char(9))).called(1);
    verify(memory.writeUnsigned8(0x01, Char(1))).called(1);
  });

  test('SetSupportsScreenSplitting', () {
    var responses = [Char(1), Char(33)];
    when(memory.readUnsigned8(0x01)).thenAnswer((_) => responses.removeAt(0));
    fileHeader.setEnabled(Attribute.SUPPORTS_SCREEN_SPLITTING, true);
    fileHeader.setEnabled(Attribute.SUPPORTS_SCREEN_SPLITTING, false);
    verify(memory.readUnsigned8(0x01)).called(2);
    verify(memory.writeUnsigned8(0x01, Char(33))).called(1);
    verify(memory.writeUnsigned8(0x01, Char(1))).called(1);
  });

  test('SetSupportsStatusLine', () {
    var responses = [Char(17), Char(1)];
    when(memory.readUnsigned8(0x01)).thenAnswer((_) => responses.removeAt(0));
    fileHeader.setEnabled(Attribute.SUPPORTS_STATUSLINE, true);
    fileHeader.setEnabled(Attribute.SUPPORTS_STATUSLINE, false);
    verify(memory.readUnsigned8(0x01)).called(2);
    verify(memory.writeUnsigned8(0x01, Char(1))).called(1);
    verify(memory.writeUnsigned8(0x01, Char(17))).called(1);
  });

  test('SetDefaultFontIsVariable', () {
    var responses = [Char(1), Char(65)];
    when(memory.readUnsigned8(0x01)).thenAnswer((_) => responses.removeAt(0));
    fileHeader.setEnabled(Attribute.DEFAULT_FONT_IS_VARIABLE, true);
    fileHeader.setEnabled(Attribute.DEFAULT_FONT_IS_VARIABLE, false);
    verify(memory.readUnsigned8(0x01)).called(2);
    verify(memory.writeUnsigned8(0x01, Char(65))).called(1);
    verify(memory.writeUnsigned8(0x01, Char(1))).called(1);
  });

  test('IsDefaultFontVariable', () {
    var responses = [Char(69), Char(7)];
    when(memory.readUnsigned8(0x01)).thenAnswer((_) => responses.removeAt(0));
    assertTrue(fileHeader.isEnabled(Attribute.DEFAULT_FONT_IS_VARIABLE));
    assertFalse(fileHeader.isEnabled(Attribute.DEFAULT_FONT_IS_VARIABLE));
    verify(memory.readUnsigned8(0x01)).called(2);
  });

  test('SetSupportsColors', () {
    var responses = [Char(4), Char(5)];
    when(memory.readUnsigned8(0x01)).thenAnswer((_) => responses.removeAt(0));
    fileHeader.setEnabled(Attribute.SUPPORTS_COLOURS, true);
    fileHeader.setEnabled(Attribute.SUPPORTS_COLOURS, false);
    verify(memory.readUnsigned8(0x01)).called(2);
    verify(memory.writeUnsigned8(0x01, Char(4))).called(1);
    verify(memory.writeUnsigned8(0x01, Char(5))).called(1);
  });

  test('SetFontWidthV5', () {
    when(memory.readUnsigned8(0x00)).thenReturn(Char(5));
    fileHeader.setFontWidth(1);
    verify(memory.readUnsigned8(0x00)).called(1);
    verify(memory.writeUnsigned8(0x26, Char(1))).called(1);
  });

  test('SetFontWidthV6', () {
    when(memory.readUnsigned8(0x00)).thenReturn(Char(6));
    fileHeader.setFontWidth(1);
    verify(memory.readUnsigned8(0x00)).called(1);
    verify(memory.writeUnsigned8(0x27, Char(1))).called(1);
  });

  test('SetFontHeightV5', () {
    when(memory.readUnsigned8(0x00)).thenReturn(Char(5));
    fileHeader.setFontHeight(2);
    verify(memory.readUnsigned8(0x00)).called(1);
    verify(memory.writeUnsigned8(0x27, Char(2))).called(1);
  });

  test('SetFontHeightV6', () {
    when(memory.readUnsigned8(0x00)).thenReturn(Char(6));
    fileHeader.setFontHeight(2);
    verify(memory.readUnsigned8(0x00)).called(1);
    verify(memory.writeUnsigned8(0x26, Char(2))).called(1);
  });

  test('UseMouseFalse', () {
    when(memory.readUnsigned8(0x10)).thenReturn(Char(2));
    assertFalse(fileHeader.isEnabled(Attribute.USE_MOUSE));
    verify(memory.readUnsigned8(0x10)).called(1);
  });

  test('UseMouseTrue', () {
    when(memory.readUnsigned8(0x10)).thenReturn(Char(63));
    assertTrue(fileHeader.isEnabled(Attribute.USE_MOUSE));
    verify(memory.readUnsigned8(0x10)).called(1);
  });

  // Simulate a situation to set mouse coordinates

  test('SetMouseCoordinatesNoExtensionTable', () {
    when(memory.readUnsigned16(0x36)).thenReturn(Char(0));
    fileHeader.setMouseCoordinates(1, 2);
    verify(memory.readUnsigned16(0x36)).called(1);
  });

  test('SetMouseCoordinatesHasExtensionTable', () {
    when(memory.readUnsigned16(0x36)).thenReturn(Char(100));
    when(memory.readUnsigned16(100)).thenReturn(Char(2));
    fileHeader.setMouseCoordinates(1, 2);
    verify(memory.readUnsigned16(0x36)).called(1);
    verify(memory.readUnsigned16(100)).called(1);
    verify(memory.writeUnsigned16(102, Char(1))).called(1);
    verify(memory.writeUnsigned16(104, Char(2))).called(1);
  });

  test('GetUnicodeTranslationTableNoExtensionTable', () {
    when(memory.readUnsigned16(0x36)).thenReturn(Char(0));
    assertEquals(0, fileHeader.getCustomAccentTable());
    verify(memory.readUnsigned16(0x36)).called(1);
  });

  test('GetCustomUnicodeTranslationTableNoTableInExtTable', () {
    when(memory.readUnsigned16(0x36)).thenReturn(Char(100));
    when(memory.readUnsigned16(100)).thenReturn(Char(2));
    assertEquals(0, fileHeader.getCustomAccentTable());
    verify(memory.readUnsigned16(0x36)).called(1);
    verify(memory.readUnsigned16(100)).called(1);
  });

  test('GetCustomUnicodeTranslationTableHasExtAddress', () {
    when(memory.readUnsigned16(0x36)).thenReturn(Char(100));
    when(memory.readUnsigned16(100)).thenReturn(Char(3));
    when(memory.readUnsigned16(106)).thenReturn(Char(1234));
    assertEquals(1234, fileHeader.getCustomAccentTable());
    verify(memory.readUnsigned16(0x36)).called(1);
    verify(memory.readUnsigned16(100)).called(1);
    verify(memory.readUnsigned16(106)).called(1);
  });

  test('ToString', () {
    var builder = StringBuffer();
    for (int i = 0; i < 55; i++) {
      builder.write('Addr: ${toHexStr(i)} Byte: ${toHexStr(i + 2)}\n');
      when(memory.readUnsigned8(i)).thenReturn(Char(i + 2));
    }
    assertEquals(builder.toString(), fileHeader.toString());
  });
}

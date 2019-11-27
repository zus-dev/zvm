import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

class MockAbbreviationsTable extends Mock implements AbbreviationsTable {}

void main() {
  MockMemory memory;
  AbbreviationsTable abbrev;
  ZCharDecoder decoder;

  setUp(() {
    memory = MockMemory();
    abbrev = MockAbbreviationsTable();

    ZsciiEncoding encoding = ZsciiEncoding(DefaultAccentTable());
    AlphabetTable alphabetTable = DefaultAlphabetTable();
    ZCharTranslator translator = DefaultZCharTranslator(alphabetTable);
    decoder = DefaultZCharDecoder(encoding, translator, abbrev);
  });

  test('DecodeByte', () {
    assertEquals('a', decoder.decodeZChar(Char(6)));
  });

  test('Decode2Unicode2Params', () {
    var hello = ByteArray([0x35, 0x51, 0xc6, 0x85]);
    var Hello = ByteArray([0x11, 0xaa, 0xc6, 0x34]);
    Memory memory1 = DefaultMemory(hello);
    Memory memory2 = DefaultMemory(Hello);
    assertEquals("hello", decoder.decode2Zscii(memory1, 0, 0));
    assertEquals("Hello", decoder.decode2Zscii(memory2, 0, 0));
  });

  //  Real-world tests
  test('Minizork', () {
    final s = Platform.pathSeparator;
    final zork1 = File('testfiles${s}minizork.z3');
    final zork1data = ByteArray(zork1.readAsBytesSync());

    Memory mem = DefaultMemory(zork1data);
    AbbreviationsTable abbr = Abbreviations(
        mem, mem.readUnsigned16(StoryFileHeader.ABBREVIATIONS).toInt());

    ZsciiEncoding encoding = ZsciiEncoding(DefaultAccentTable());
    AlphabetTable alphabetTable = DefaultAlphabetTable();
    ZCharTranslator translator = DefaultZCharTranslator(alphabetTable);

    ZCharDecoder dec = DefaultZCharDecoder(encoding, translator, abbr);
    assertEquals("The Great Underground Empire",
        dec.decode2Zscii(mem, 0xc120, 0).toString());
    assertEquals("[I don't understand that sentence.]",
        dec.decode2Zscii(mem, 0x3e6d, 0).toString());
  });

  /**
   * A pretty complex example: the Zork I introduction message. This one
   * clarified that the current shift lock alphabet needs to be restored
   * after a regular shift occured.
   */
  test('Zork1V1', () {
    String originalString = "ZORK: The Great Underground Empire - Part I\n" +
        "Copyright (c) 1980 by Infocom, Inc. All rights reserved.\n" +
        "ZORK is a trademark of Infocom, Inc.\n" +
        "Release ";

    // This String was extracted from release 5 of Zork I and contains
    // the same message as in originalString.
    var data = ByteArray([
      0x13, 0xf4, 0x5e, 0x02, //
      0x74, 0x19, 0x15, 0xaa,
      0x00, 0x4c, 0x5d, 0x46,
      0x64, 0x02, 0x6a, 0x69,
      0x2a, 0xec, 0x5e, 0x9a,
      0x4d, 0x20, 0x09, 0x52,
      0x55, 0xd7, 0x28, 0x03,
      0x70, 0x02, 0x54, 0xd7,
      0x64, 0x02, 0x38, 0x22,
      0x22, 0x95, 0x7a, 0xee,
      0x31, 0xb9, 0x00, 0x7e,
      0x20, 0x7f, 0x00, 0xa8,
      0x41, 0xe7, 0x00, 0x87,
      0x78, 0x02, 0x3a, 0x6b,
      0x51, 0x14, 0x48, 0x72,
      0x00, 0x4e, 0x4d, 0x03,
      0x44, 0x02, 0x1a, 0x31,
      0x02, 0xee, 0x31, 0xb9,
      0x60, 0x17, 0x2b, 0x0a,
      0x5f, 0x6a, 0x24, 0x71,
      0x04, 0x9f, 0x52, 0xf0,
      0x00, 0xae, 0x60, 0x06,
      0x03, 0x37, 0x19, 0x2a,
      0x48, 0xd7, 0x40, 0x14,
      0x2c, 0x02, 0x3a, 0x6b,
      0x51, 0x14, 0x48, 0x72,
      0x00, 0x4e, 0x4d, 0x03,
      0x44, 0x22, 0x5d, 0x51,
      0x28, 0xd8, 0xa8, 0x05,
    ]);

    Memory mem = DefaultMemory(data);
    ZsciiEncoding encoding = ZsciiEncoding(DefaultAccentTable());
    AlphabetTable alphabetTable = AlphabetTableV1();
    ZCharTranslator translator = DefaultZCharTranslator(alphabetTable);

    ZCharDecoder dec = DefaultZCharDecoder(encoding, translator, null);
    String decoded = dec.decode2Zscii(mem, 0, 0).toString();
    assertEquals(originalString, decoded);
  });

  // Tests based on mock objects
  test('ConvertWithAbbreviation', () {
    when(abbrev.getWordAddress(2)).thenReturn(10);
    var helloAbbrev = ByteArray([
      0x35, 0x51, 0x46, 0x81, 0x88, 0xa5, // hello{abbrev_2}
      0x35, 0x51, 0xc6, 0x85, // hello
      0x11, 0xaa, 0xc6, 0x34 // Hello
    ]);
    Memory mem = DefaultMemory(helloAbbrev);
    assertEquals("helloHello", decoder.decode2Zscii(mem, 0, 0).toString());
    verify(abbrev.getWordAddress(2)).called(1);
  });

  test('EndCharacter', () {
    final notEndWord = Char(0x7123);
    assertFalse(DefaultZCharDecoder.isEndWord(notEndWord));
    final endWord = Char(0x8123);
    assertTrue(DefaultZCharDecoder.isEndWord(endWord));
  });

  test('ExtractZBytesOneWordOnly', () {
    when(memory.readUnsigned16(0)).thenReturn(Char(0x9865));
    List<Char> data = DefaultZCharDecoder.extractZbytes(memory, 0, 0);
    assertEquals(3, data.length);
    assertEquals(6, data[0]);
    assertEquals(3, data[1]);
    assertEquals(5, data[2]);
    verify(memory.readUnsigned16(0)).called(1);
  });

  test('ExtractZBytesThreeWords', () {
    when(memory.readUnsigned16(0)).thenReturn(Char(0x5432));
    when(memory.readUnsigned16(2)).thenReturn(Char(0x1234));
    when(memory.readUnsigned16(4)).thenReturn(Char(0x9865));
    List<Char> data = DefaultZCharDecoder.extractZbytes(memory, 0, 0);
    assertEquals(9, data.length);
    verify(memory.readUnsigned16(0)).called(1);
    verify(memory.readUnsigned16(2)).called(1);
    verify(memory.readUnsigned16(4)).called(1);
  });

  // *********************************************************************
  // **** Tests for string truncation
  // **** We test the truncation algorithm for V3 length only which is
  // **** 4 bytes, 6 characters. In fact, this should be general enough
  // **** so we do not need to test 6 bytes, 9 characters as in >= V4
  // **** files. Since this method is only used within dictionaries, we
  // **** do not need to test abbreviations
  // ****************************************
  test('TruncateAllSmall', () {
    var data = ByteArray([0x35, 0x51, 0x46, 0x86, 0xc6, 0x85]);
    Memory mem = DefaultMemory(data);
    int length = 4;
    // With length = 0
    assertEquals("helloalo", decoder.decode2Zscii(mem, 0, 0).toString());
    // With length = 4
    assertEquals("helloa", decoder.decode2Zscii(mem, 0, length).toString());
  });

  test('TruncateShiftAtEnd', () {
    var data = ByteArray([0x34, 0x8a, 0x45, 0xc4]);
    Memory mem = DefaultMemory(data);
    int length = 4;
    assertEquals("hEli", decoder.decode2Zscii(mem, 0, length).toString());
  });

  /**
   * Escape A6 starts at position 0 of the last word.
   */
  test('TruncateEscapeA2AtEndStartsAtWord2_0', () {
    var data = ByteArray([0x34, 0xd1, 0x14, 0xc1, 0x80, 0xa5]);
    Memory mem = DefaultMemory(data);
    int length = 4;
    assertEquals("hal", decoder.decode2Zscii(mem, 0, length).toString());
  });

  /**
   * Escape A6 starts at position 1 of the last word.
   */
  test('TruncateEscapeA2AtEndStartsAtWord2_1', () {
    var data = ByteArray([0x34, 0xd1, 0x44, 0xa6, 0x84, 0x05]);
    Memory mem = DefaultMemory(data);
    int length = 4;
    assertEquals("hall", decoder.decode2Zscii(mem, 0, length).toString());
  });
}

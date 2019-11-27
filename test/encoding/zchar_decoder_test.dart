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
}

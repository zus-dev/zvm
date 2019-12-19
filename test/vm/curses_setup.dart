import 'package:zvm/zvm.dart';

import '../helpers.dart';

/// Set up the test with a Curses game.
class CursesSetup {
  Memory curses;
  ZCharDecoder converter;
  StoryFileHeader fileheader;
  Abbreviations abbreviations;
  Machine machine;
  static ByteArray originalData;

  void setUp() {
    originalData = readTestFileAsByteArray("curses.z5");
    machine = MachineImpl();
    machine.initialize(originalData, null);
    curses = machine;
    fileheader = machine.getFileHeader();

    abbreviations = Abbreviations(
        curses, machine.readUnsigned16(StoryFileHeader.ABBREVIATIONS).toInt());
    ZsciiEncoding encoding = ZsciiEncoding(DefaultAccentTable());
    AlphabetTable alphabetTable = DefaultAlphabetTable();
    ZCharTranslator translator = DefaultZCharTranslator(alphabetTable);
    converter = DefaultZCharDecoder(encoding, translator, abbreviations);
  }
}

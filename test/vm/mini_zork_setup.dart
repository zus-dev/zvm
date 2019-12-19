import 'package:zvm/zvm.dart';

import 'machine_test_util.dart';

/// This class acts as a base test class and sets up some integrated
/// testing objects for the minizork game.
class MiniZorkSetup {
  Memory minizorkmap;
  ZCharDecoder converter;
  StoryFileHeader fileheader;
  Abbreviations abbreviations;
  Machine machine;

  void setUp() {
    machine = MachineTestUtil.createMachine("minizork.z3");
    minizorkmap = machine;
    fileheader = machine.getFileHeader();

    abbreviations = Abbreviations(minizorkmap,
        machine.readUnsigned16(StoryFileHeader.ABBREVIATIONS).toInt());
    ZsciiEncoding encoding = ZsciiEncoding(DefaultAccentTable());
    AlphabetTable alphabetTable = DefaultAlphabetTable();
    ZCharTranslator translator = DefaultZCharTranslator(alphabetTable);
    converter = DefaultZCharDecoder(encoding, translator, abbreviations);
  }
}

import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';
import 'mini_zork_setup.dart';

void main() {
  final mz = MiniZorkSetup();
  Memory minizorkmap;
  ZCharDecoder converter;
  Abbreviations abbreviations;

  List<String> testdata = [
    "the ", "The ", "You ", ", ", "your ", "is ", "and ", "There ", "you ",
    "of ", ". ", "with ", "to ", "are ", "large ", "This ", "cyclops ", "that ",
    "from ", "have ", "through ", "here", "in ", "It's ", "which ", "small ",
    "room ", "closed", "A ", "can't ", "You're ", "into ", "Room", "Your ",
    "grating ", "already ", "Frigid ", "isn't ", "It ", "thief ", "be ",
    "that", "for ", "water ", "leads ", "won't ", "narrow ", "cannot ", "but ",
    "not ", "this ", "south ", "seems ", "ground", "about ", "passage ",
    "appears ", "don't ", "southwest", "on ", "west ", "north ", "There's ",
    "his ", "feet ", "east ", "door ", "cyclops", "can ", "white ", "That ",
    "probably ", "Maze", "an ", "too ", "has ", "wooden ", "In ", "south",
    "north", "How ", "would ", "With ", "sentence", "rainbow ", "lurking ",
    "looking ", "leading ", "darkness", "candles ", "against ", "treasures ",
    "staircase ", "northeast ", "one ", "now " //
  ];

  setUp(() {
    mz.setUp();
    minizorkmap = mz.minizorkmap;
    converter = mz.converter;
    abbreviations = mz.abbreviations;
  });

  test('GetWordAddress', () {
    // Test of the abbreviations in the minizorkmap
    for (int i = 0; i < testdata.length; i++) {
      final actual = converter
          .decode2Zscii(minizorkmap, abbreviations.getWordAddress(i), 0)
          .toString();
      assertEquals(testdata[i], actual);
    }
  });
}

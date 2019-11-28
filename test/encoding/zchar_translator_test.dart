import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  AlphabetTable alphabetTable;
  ZCharTranslator translator;

  AlphabetTable alphabetTableV2;
  ZCharTranslator translatorV2;

  setUp(() {
    alphabetTable = DefaultAlphabetTable();
    translator = DefaultZCharTranslator(alphabetTable);
    alphabetTableV2 = AlphabetTableV2();
    translatorV2 = DefaultZCharTranslator(alphabetTableV2);
  });

  test('Translate', () {
    // Unknown
    assertEquals('?', translator.translate(Char(255)));

    // alphabet 0
    assertEquals('a', translator.translate(Char(6)));

    // Alphabet 1
    translator.translate(Char(AlphabetTable.SHIFT_4));
    assertEquals('C', translator.translate(Char(8)));

    // Alphabet 2
    translator.translate(Char(AlphabetTable.SHIFT_5));
    assertEquals('2', translator.translate(Char(10)));

    // Alphabet 2, NEWLINE
    translator.translate(Char(AlphabetTable.SHIFT_5));
    assertEquals('\n', translator.translate(Char(7)));
  });

  test('0IsSpace', () {
    assertEquals(' ', translator.translate(Char(0)));
    translator.translate(Char(AlphabetTable.SHIFT_4));
    assertEquals(' ', translator.translate(Char(0)));
    translator.translate(Char(AlphabetTable.SHIFT_5));
    assertEquals(' ', translator.translate(Char(0)));

    assertEquals(' ', translatorV2.translate(Char(0)));
    translatorV2.translate(Char(AlphabetTable.SHIFT_4));
    assertEquals(' ', translatorV2.translate(Char(0)));
    translatorV2.translate(Char(AlphabetTable.SHIFT_5));
    assertEquals(' ', translatorV2.translate(Char(0)));
  });

  // Shift
  test('ShiftFromA0', () {
    var c = translator.translate(Char(AlphabetTable.SHIFT_4));
    assertEquals('\u0000', c);
    assertEquals(Alphabet.A1, translator.getCurrentAlphabet());

    translator.reset();
    assertEquals(Alphabet.A0, translator.getCurrentAlphabet());

    c = translator.translate(Char(AlphabetTable.SHIFT_5));
    assertEquals('\u0000', c);
    assertEquals(Alphabet.A2, translator.getCurrentAlphabet());
  });

  test('ShiftFromA1', () {
    // Switch to A1
    Char c = translator.translate(Char(AlphabetTable.SHIFT_4));

    c = translator.translate(Char(AlphabetTable.SHIFT_4));
    assertEquals('\u0000', c);
    assertEquals(Alphabet.A2, translator.getCurrentAlphabet());

    // Switch to A1 again
    translator.reset();
    c = translator.translate(Char(AlphabetTable.SHIFT_4));

    c = translator.translate(Char(AlphabetTable.SHIFT_5));
    assertEquals('\u0000', c);
    assertEquals(Alphabet.A0, translator.getCurrentAlphabet());
  });

  test('ShiftFromA2', () {
    // Switch to A2
    Char c = translator.translate(Char(AlphabetTable.SHIFT_5));

    c = translator.translate(Char(AlphabetTable.SHIFT_4));
    assertEquals('\u0000', c);
    assertEquals(Alphabet.A0, translator.getCurrentAlphabet());

    // Switch to A2 again
    translator.reset();
    c = translator.translate(Char(AlphabetTable.SHIFT_5));

    c = translator.translate(Char(AlphabetTable.SHIFT_5));
    assertEquals('\u0000', c);
    assertEquals(Alphabet.A1, translator.getCurrentAlphabet());
  });

  /**
   * The default alphabet table should reset to A0 after retrieving a
   * code.
   */
  test('ImplicitReset', () {
    translator.translate(Char(AlphabetTable.SHIFT_4));
    translator.translate(Char(7));
    assertEquals(Alphabet.A0, translator.getCurrentAlphabet());

    translator.translate(Char(AlphabetTable.SHIFT_5));
    translator.translate(Char(7));
    assertEquals(Alphabet.A0, translator.getCurrentAlphabet());
  });

  test('GetAlphabetElement', () {
    // Alphabet A0
    AlphabetElement elem1 = translator.getAlphabetElementFor(Char.of('c'));
    assertEquals(Alphabet.A0, elem1.getAlphabet());
    assertEquals(8, elem1.getZCharCode());

    AlphabetElement elem1b = translator.getAlphabetElementFor(Char.of('a'));
    assertEquals(Alphabet.A0, elem1b.getAlphabet());
    assertEquals(6, elem1b.getZCharCode());

    AlphabetElement elem2 = translator.getAlphabetElementFor(Char.of('d'));
    assertEquals(Alphabet.A0, elem2.getAlphabet());
    assertEquals(9, elem2.getZCharCode());

    // Alphabet A1
    AlphabetElement elem3 = translator.getAlphabetElementFor(Char.of('C'));
    assertEquals(Alphabet.A1, elem3.getAlphabet());
    assertEquals(8, elem3.getZCharCode());

    // Alphabet A2
    AlphabetElement elem4 = translator.getAlphabetElementFor(Char.of('#'));
    assertEquals(Alphabet.A2, elem4.getAlphabet());
    assertEquals(23, elem4.getZCharCode());

    // ZSCII code
    AlphabetElement elem5 = translator.getAlphabetElementFor(Char.of('@'));
    assertEquals(null, elem5.getAlphabet());
    assertEquals(64, elem5.getZCharCode());

    // Newline is tricky, this is always A2/7 !!!
    AlphabetElement newline = translator.getAlphabetElementFor(Char.of('\n'));
    assertEquals(Alphabet.A2, newline.getAlphabet());
    assertEquals(7, newline.getZCharCode());
  });

  // Shifting in V2
  test('ShiftV2FromA0', () {
    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_2)));
    assertEquals(Alphabet.A1, translatorV2.getCurrentAlphabet());
    translatorV2.reset();

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_4)));
    assertEquals(Alphabet.A1, translatorV2.getCurrentAlphabet());
    translatorV2.reset();

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_3)));
    assertEquals(Alphabet.A2, translatorV2.getCurrentAlphabet());
    translatorV2.reset();

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_5)));
    assertEquals(Alphabet.A2, translatorV2.getCurrentAlphabet());
  });

  test('ShiftV2FromA1', () {
    translatorV2.translate(Char(AlphabetTable.SHIFT_2));

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_2)));
    assertEquals(Alphabet.A2, translatorV2.getCurrentAlphabet());
    translatorV2.reset();
    translatorV2.translate(Char(AlphabetTable.SHIFT_2));

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_4)));
    assertEquals(Alphabet.A2, translatorV2.getCurrentAlphabet());
    translatorV2.reset();
    translatorV2.translate(Char(AlphabetTable.SHIFT_2));

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_3)));
    assertEquals(Alphabet.A0, translatorV2.getCurrentAlphabet());
    translatorV2.reset();
    translatorV2.translate(Char(AlphabetTable.SHIFT_2));

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_5)));
    assertEquals(Alphabet.A0, translatorV2.getCurrentAlphabet());
  });

  test('ShiftV2FromA2', () {
    translatorV2.translate(Char(AlphabetTable.SHIFT_3));

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_2)));
    assertEquals(Alphabet.A0, translatorV2.getCurrentAlphabet());
    translatorV2.reset();
    translatorV2.translate(Char(AlphabetTable.SHIFT_3));

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_4)));
    assertEquals(Alphabet.A0, translatorV2.getCurrentAlphabet());
    translatorV2.reset();
    translatorV2.translate(Char(AlphabetTable.SHIFT_3));

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_3)));
    assertEquals(Alphabet.A1, translatorV2.getCurrentAlphabet());
    translatorV2.reset();
    translatorV2.translate(Char(AlphabetTable.SHIFT_3));

    assertEquals(0, translatorV2.translate(Char(AlphabetTable.SHIFT_5)));
    assertEquals(Alphabet.A1, translatorV2.getCurrentAlphabet());
  });

  test('ShiftNotLocked', () {
    translatorV2.translate(Char(AlphabetTable.SHIFT_2));
    translatorV2.translate(Char(10));
    assertEquals(Alphabet.A0, translatorV2.getCurrentAlphabet());

    translatorV2.translate(Char(AlphabetTable.SHIFT_3));
    translatorV2.translate(Char(10));
    assertEquals(Alphabet.A0, translatorV2.getCurrentAlphabet());
  });

  test('ShiftNotLockedChar0', () {
    translatorV2.translate(Char(AlphabetTable.SHIFT_2));
    translatorV2.translate(Char(0));
    assertEquals(Alphabet.A0, translatorV2.getCurrentAlphabet());

    translatorV2.translate(Char(AlphabetTable.SHIFT_3));
    translatorV2.translate(Char(0));
    assertEquals(Alphabet.A0, translatorV2.getCurrentAlphabet());
  });

  test('ShiftLocked', () {
    translatorV2.translate(Char(AlphabetTable.SHIFT_4));
    translatorV2.translate(Char(10));
    assertEquals(Alphabet.A1, translatorV2.getCurrentAlphabet());
    translatorV2.reset();
    assertEquals(Alphabet.A0, translatorV2.getCurrentAlphabet());

    translatorV2.translate(Char(AlphabetTable.SHIFT_5));
    translatorV2.translate(Char(10));
    assertEquals(Alphabet.A2, translatorV2.getCurrentAlphabet());
  });

  /**
   * Test if the shift lock is reset after the a non-locking shift was
   * met.
   */
  test('ShiftLockSequenceLock1', () {
    translatorV2.translate(Char(AlphabetTable.SHIFT_4));
    translatorV2.translate(Char(AlphabetTable.SHIFT_2));
    translatorV2.translate(Char(10));
    assertEquals(Alphabet.A1, translatorV2.getCurrentAlphabet());
  });

  test('ShiftLockSequenceLock2', () {
    translatorV2.translate(Char(AlphabetTable.SHIFT_5));
    translatorV2.translate(Char(AlphabetTable.SHIFT_3));
    translatorV2.translate(Char(10));
    assertEquals(Alphabet.A2, translatorV2.getCurrentAlphabet());
  });
}

import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  final v1Table = AlphabetTableV1();
  final v2Table = AlphabetTableV2();
  final defaultTable = DefaultAlphabetTable();

  test('Char0IsSpace', () {
    assertEquals(' ', v1Table.getA0Char(0));
    assertEquals(' ', v1Table.getA1Char(0));
    assertEquals(' ', v1Table.getA2Char(0));

    assertEquals(' ', v2Table.getA0Char(0));
    assertEquals(' ', v2Table.getA1Char(0));
    assertEquals(' ', v2Table.getA2Char(0));

    assertEquals(' ', defaultTable.getA0Char(0));
    assertEquals(' ', defaultTable.getA1Char(0));
    assertEquals(' ', defaultTable.getA2Char(0));
  });

  test('Char1IsNewLineInV1', () {
    assertEquals('\n', v1Table.getA0Char(1));
    assertEquals('\n', v1Table.getA1Char(1));
    assertEquals('\n', v1Table.getA2Char(1));
  });

  test('IsAbbreviation', () {
    assertFalse(v1Table.isAbbreviation(Char(1)));
    assertFalse(v1Table.isAbbreviation(Char(2)));
    assertFalse(v1Table.isAbbreviation(Char(3)));

    assertTrue(v2Table.isAbbreviation(Char(1)));
    assertFalse(v2Table.isAbbreviation(Char(2)));
    assertFalse(v2Table.isAbbreviation(Char(3)));
  });

  test('ShiftChars', () {
    assertTrue(v1Table.isShift(Char(AlphabetTable.SHIFT_2)));
    assertTrue(v1Table.isShift(Char(AlphabetTable.SHIFT_3)));
    assertTrue(v2Table.isShift(Char(AlphabetTable.SHIFT_2)));
    assertTrue(v2Table.isShift(Char(AlphabetTable.SHIFT_3)));
    assertFalse(v1Table.isShiftLock(Char(AlphabetTable.SHIFT_2)));
    assertFalse(v1Table.isShiftLock(Char(AlphabetTable.SHIFT_3)));
    assertFalse(v2Table.isShiftLock(Char(AlphabetTable.SHIFT_2)));
    assertFalse(v2Table.isShiftLock(Char(AlphabetTable.SHIFT_3)));

    assertFalse(v1Table.isShiftLock(Char(AlphabetTable.SHIFT_2)));
    assertFalse(v1Table.isShiftLock(Char(AlphabetTable.SHIFT_3)));
    assertFalse(v2Table.isShiftLock(Char(AlphabetTable.SHIFT_2)));
    assertFalse(v2Table.isShiftLock(Char(AlphabetTable.SHIFT_3)));
    assertTrue(v1Table.isShiftLock(Char(AlphabetTable.SHIFT_4)));
    assertTrue(v1Table.isShiftLock(Char(AlphabetTable.SHIFT_5)));
    assertTrue(v2Table.isShiftLock(Char(AlphabetTable.SHIFT_4)));
    assertTrue(v2Table.isShiftLock(Char(AlphabetTable.SHIFT_5)));

    assertFalse(defaultTable.isShift(Char(AlphabetTable.SHIFT_2)));
    assertFalse(defaultTable.isShift(Char(AlphabetTable.SHIFT_3)));
    assertTrue(defaultTable.isShift(Char(AlphabetTable.SHIFT_4)));
    assertTrue(defaultTable.isShift(Char(AlphabetTable.SHIFT_5)));
    assertFalse(defaultTable.isShiftLock(Char(AlphabetTable.SHIFT_2)));
    assertFalse(defaultTable.isShiftLock(Char(AlphabetTable.SHIFT_3)));
    assertFalse(defaultTable.isShiftLock(Char(AlphabetTable.SHIFT_4)));
    assertFalse(defaultTable.isShiftLock(Char(AlphabetTable.SHIFT_5)));
  });
}

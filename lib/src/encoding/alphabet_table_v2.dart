import '../../zvm.dart';

/// An alphabet table in a V2 story file behaves "almost like" the default
/// alphabet table, in that they have the same characters in the alphabets.
/// There are however two differences: It only supports one abbreviation code
/// and it supports shift-lock.
class AlphabetTableV2 extends DefaultAlphabetTable {
  @override
  bool isAbbreviation(final Char zchar) {
    return zchar.toInt() == 1;
  }

  @override
  bool isShift1(final Char zchar) {
    return zchar.toInt() == AlphabetTable.SHIFT_2 ||
        zchar.toInt() == AlphabetTable.SHIFT_4;
  }

  @override
  bool isShift2(final Char zchar) {
    return zchar.toInt() == AlphabetTable.SHIFT_3 ||
        zchar.toInt() == AlphabetTable.SHIFT_5;
  }

  @override
  bool isShiftLock(final Char zchar) {
    return zchar.toInt() == AlphabetTable.SHIFT_4 ||
        zchar.toInt() == AlphabetTable.SHIFT_5;
  }
}

import '../../zvm.dart';

/// The default alphabet table implementation.
class DefaultAlphabetTable implements AlphabetTable {
  static const String _A0CHARS = "abcdefghijklmnopqrstuvwxyz";
  static const String _A1CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static const String _A2CHARS = " \n0123456789.,!?_#'\"/\\-:()";

  @override
  Char getA0Char(final int zchar) {
    if (zchar == 0) return Char.of(' ');
    return Char.at(_A0CHARS, zchar - AlphabetTable.ALPHABET_START);
  }

  @override
  Char getA1Char(final int zchar) {
    if (zchar == 0) return Char.of(' ');
    return Char.at(_A1CHARS, zchar - AlphabetTable.ALPHABET_START);
  }

  @override
  Char getA2Char(final int zchar) {
    if (zchar == 0) return Char.of(' ');
    return Char.at(_A2CHARS, zchar - AlphabetTable.ALPHABET_START);
  }

  @override
  int getA0CharCode(final Char zsciiChar) {
    return getCharCodeFor(_A0CHARS, zsciiChar);
  }

  @override
  int getA1CharCode(final Char zsciiChar) {
    return getCharCodeFor(_A1CHARS, zsciiChar);
  }

  @override
  int getA2CharCode(final Char zsciiChar) {
    return getCharCodeFor(_A2CHARS, zsciiChar);
  }

  ///Returns the character code for the specified ZSCII character by searching
  /// the index in the specified chars string or -1 if not found.
  static int getCharCodeFor(final String chars, final Char zsciiChar) {
    int index = chars.indexOf(zsciiChar.toString());
    if (index >= 0) index += AlphabetTable.ALPHABET_START;
    return index;
  }

  @override
  bool isShift1(final Char zchar) {
    return zchar.toInt() == AlphabetTable.SHIFT_4;
  }

  @override
  bool isShift2(final Char zchar) {
    return zchar.toInt() == AlphabetTable.SHIFT_5;
  }

  @override
  bool isShift(final Char zchar) {
    return isShift1(zchar) || isShift2(zchar);
  }

  @override
  bool isShiftLock(final Char zchar) {
    return false;
  }

  @override
  bool isAbbreviation(final Char zchar) {
    return 1 <= zchar.toInt() && zchar.toInt() <= 3;
  }
}

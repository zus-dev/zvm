import '../../zvm.dart';

/// If the story file header defines a custom alphabet table, instances
/// of this class are used to retrieve the alphabet characters.
class CustomAlphabetTable implements AlphabetTable {
  static final int _ALPHABET_SIZE = 26;
  final Memory _memory;
  final int _tableAddress;

  CustomAlphabetTable(this._memory, this._tableAddress);

  @override
  Char getA0Char(final int zchar) {
    if (zchar == 0) return Char.of(' ');
    return _memory
        .readUnsigned8(_tableAddress + (zchar - AlphabetTable.ALPHABET_START));
  }

  @override
  Char getA1Char(final int zchar) {
    if (zchar == 0) return Char.of(' ');
    return _memory.readUnsigned8(_tableAddress +
        _ALPHABET_SIZE +
        (zchar - AlphabetTable.ALPHABET_START));
  }

  @override
  Char getA2Char(final int zchar) {
    if (zchar == 0) return Char.of(' ');
    if (zchar == 7) return Char.of('\n');
    return _memory.readUnsigned8(_tableAddress +
        2 * _ALPHABET_SIZE +
        (zchar - AlphabetTable.ALPHABET_START));
  }

  @override
  int getA0CharCode(final Char zsciiChar) {
    for (int i = AlphabetTable.ALPHABET_START;
        i < AlphabetTable.ALPHABET_START + _ALPHABET_SIZE;
        i++) {
      if (getA0Char(i) == zsciiChar) return i;
    }
    return -1;
  }

  @override
  int getA1CharCode(final Char zsciiChar) {
    for (int i = AlphabetTable.ALPHABET_START;
        i < AlphabetTable.ALPHABET_START + _ALPHABET_SIZE;
        i++) {
      if (getA1Char(i) == zsciiChar) return i;
    }
    return -1;
  }

  @override
  int getA2CharCode(final Char zsciiChar) {
    for (int i = AlphabetTable.ALPHABET_START;
        i < AlphabetTable.ALPHABET_START + _ALPHABET_SIZE;
        i++) {
      if (getA2Char(i) == zsciiChar) return i;
    }
    return -1;
  }

  @override
  bool isAbbreviation(final Char zchar) {
    return 1 <= zchar.toInt() && zchar.toInt() <= 3;
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
  bool isShiftLock(final Char zchar) {
    return false;
  }

  @override
  bool isShift(final Char zchar) {
    return isShift1(zchar) || isShift2(zchar);
  }
}

import '../../zvm.dart';

/// This accent table is used in case that there is an extension header
/// that specifies that accent table.
class CustomAccentTable implements AccentTable {
  /// The Memory object.
  Memory _memory;

  /// The table adddress.
  int _tableAddress;

  CustomAccentTable(final Memory memory, final int address) {
    this._memory = memory;
    this._tableAddress = address;
  }

  @override
  int getLength() {
    int result = 0;
    if (_tableAddress > 0) {
      result = _memory.readUnsigned8(_tableAddress).toInt();
    }
    return result;
  }

  @override
  Char getAccent(final int index) {
    Char result = Char.of('?');
    if (_tableAddress > 0) {
      result = _memory.readUnsigned16(_tableAddress + (index * 2) + 1);
    }
    return result;
  }

  @override
  int getIndexOfLowerCase(final int index) {
    final Char c = getAccent(index);
    final Char lower = c.toLowerCase();
    final int length = getLength();

    for (int i = 0; i < length; i++) {
      if (getAccent(i) == lower) return i;
    }
    return index;
  }
}

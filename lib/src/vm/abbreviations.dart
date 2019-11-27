import '../../zvm.dart';

/// This class represents a view to the abbreviations table. The table
/// starts at the predefined address within the header and contains pointers
/// to ZSCII strings in the memory map. These pointers are word addresses
/// as opposed to all other addresses in the memory map, therefore the
/// actual value has to multiplied by two to get the real address.
class Abbreviations implements AbbreviationsTable {
  /// The memory object.
  Memory _memory;

  /// The start address of the abbreviations table.
  int _address;

  /// Creates from the [memory] map and the start [address] of the
  /// abbreviations table.
  Abbreviations(final Memory memory, final int address) {
    this._memory = memory;
    this._address = address;
  }

  /// The abbreviation table contains word addresses, so read out the pointer
  /// and multiply by two. [entryNum] the entry index in the abbreviations table
  @override
  int getWordAddress(final int entryNum) {
    return _memory.readUnsigned16(_address + entryNum * 2).toInt() * 2;
  }
}

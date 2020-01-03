import '../../zvm.dart';

/// Table position representation.
class TablePosition {
  int tableAddress = 0;
  int bytesWritten = 0;

  TablePosition(int tableAddress) {
    this.tableAddress = tableAddress;
  }
}

/// This class implements output stream 3. This stream writes to dynamic
/// memory. The stream contains a table address stack in order to
/// support nested selections.
class MemoryOutputStream implements OutputStream {
  /// Maximum nesting depth for this stream.
  static final int _MAX_NESTING_DEPTH = 16;
  Machine _machine;

  /// Support nested selections.
  List<TablePosition> _tableStack;

  MemoryOutputStream(Machine machine) {
    _tableStack = List<TablePosition>();
    _machine = machine;
  }

  @override
  void print(final Char zsciiChar) {
    final TablePosition tablePos = _tableStack[_tableStack.length - 1];
    final int position = tablePos.tableAddress + 2 + tablePos.bytesWritten;
    _machine.writeUnsigned8(position, zsciiChar);
    tablePos.bytesWritten++;
  }

  @override
  void flush() {
    // intentionally left empty
  }

  @override
  void close() {
    // intentionally left empty
  }

  @override
  void select(final bool flag) {
    if (!flag && _tableStack.isNotEmpty) {
      // Write the total number of written bytes to the first word
      // of the table
      final TablePosition tablePos =
          _tableStack.removeAt(_tableStack.length - 1);
      _machine.writeUnsigned16(
          tablePos.tableAddress, toUnsigned16(tablePos.bytesWritten));

      if (_machine.getVersion() == 6) {
        _writeTextWidthInUnits(tablePos);
      }
    }
  }

  /// Writes the text width in units.
  void _writeTextWidthInUnits(TablePosition tablepos) {
    int numwords = tablepos.bytesWritten;
    List<Char> data = FilledList.ofChar(numwords);

    for (int i = 0; i < numwords; i++) {
      data[i] = _machine.readUnsigned8(tablepos.tableAddress + i + 2);
    }
    _machine.getScreen6().setTextWidthInUnits(data);
  }

  /// Selects this memory stream.
  void selectWithTable(final int tableAddress, final int tableWidth) {
    //this.tableWidth = tableWidth;
    if (_tableStack.length < _MAX_NESTING_DEPTH) {
      _tableStack.add(TablePosition(tableAddress));
    } else {
      _machine.halt("maximum nesting depth (16) for stream 3 exceeded");
    }
  }

  @override
  bool isSelected() {
    return _tableStack.isNotEmpty;
  }
}

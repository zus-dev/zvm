import '../../zvm.dart';

/// Output implementation.
class OutputImpl implements Output, Closeable {
  Machine _machine;

  /// This is the array of output streams.
  List<OutputStream> _outputStream;

  OutputImpl(final Machine machine) {
    _machine = machine;
    _outputStream = List<OutputStream>(3);
  }

  /// Sets the output stream to the specified number.
  void setOutputStream(final int streamnumber, final OutputStream stream) {
    _outputStream[streamnumber - 1] = stream;
  }

  @override
  void printZString(final int address) {
    print(_machine.decode2Zscii(address, 0));
  }

  @override
  void print(final String str) {
    _printZsciiChars(str);
  }

  @override
  void newline() {
    printZsciiChar(Char(IZsciiEncoding.NEWLINE));
  }

  @override
  void printZsciiChar(final Char zchar) {
    _printZsciiChars(zchar.toString());
  }

  /// Prints the specified array of ZSCII characters. This is the only function
  /// that communicates with the output streams directly.
  void _printZsciiChars(final String zsciiString) {
    _checkTranscriptFlag();
    if (_outputStream[Output.OUTPUTSTREAM_MEMORY - 1].isSelected()) {
      for (int i = 0, n = zsciiString.length; i < n; i++) {
        _outputStream[Output.OUTPUTSTREAM_MEMORY - 1]
            .print(Char.at(zsciiString, i));
      }
    } else {
      for (int i = 0; i < _outputStream.length; i++) {
        if (_outputStream[i] != null && _outputStream[i].isSelected()) {
          for (int j = 0, n = zsciiString.length; j < n; j++) {
            _outputStream[i].print(Char.at(zsciiString, j));
          }
        }
      }
    }
  }

  @override
  void printNumber(final int number) {
    print(number.toString());
  }

  @override
  void flushOutput() {
    // At the moment flushing only makes sense for screen
    if (!_outputStream[Output.OUTPUTSTREAM_MEMORY - 1].isSelected()) {
      for (int i = 0; i < _outputStream.length; i++) {
        if (_outputStream[i] != null && _outputStream[i].isSelected()) {
          _outputStream[i].flush();
        }
      }
    }
  }

  /// Checks the fileheader if the transcript flag was set by the game
  /// bypassing output_stream, e.g. with a storeb to the fileheader flags
  /// address. Enable the transcript depending on the status of that flag.
  void _checkTranscriptFlag() {
    if (_outputStream[Output.OUTPUTSTREAM_TRANSCRIPT - 1] != null) {
      _outputStream[Output.OUTPUTSTREAM_TRANSCRIPT - 1]
          .select(_machine.getFileHeader().isEnabled(Attribute.TRANSCRIPTING));
    }
  }

  @override
  void selectOutputStream(final int streamnumber, final bool flag) {
    _outputStream[streamnumber - 1].select(flag);

    // Sets the tranxdQscript flag if the transcipt is specified
    if (streamnumber == Output.OUTPUTSTREAM_TRANSCRIPT) {
      _machine.getFileHeader().setEnabled(Attribute.TRANSCRIPTING, flag);
    } else if (streamnumber == Output.OUTPUTSTREAM_MEMORY && flag) {
      _machine.halt("invalid selection of memory stream");
    }
  }

  @override
  void selectOutputStream3(final int tableAddress, final int tableWidth) {
    (_outputStream[Output.OUTPUTSTREAM_MEMORY - 1] as MemoryOutputStream)
        .selectWithTable(tableAddress, tableWidth);
  }

  @override
  void close() {
    if (_outputStream != null) {
      for (int i = 0; i < _outputStream.length; i++) {
        if (_outputStream[i] != null) {
          _outputStream[i].flush();
          _outputStream[i].close();
        }
      }
    }
  }

  @override
  void reset() {
    for (int i = 0; i < _outputStream.length; i++) {
      if (_outputStream[i] != null) {
        _outputStream[i].flush();
      }
    }
  }
}

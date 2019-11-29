import '../../zvm.dart';

/// The Output interface.
abstract class Output {
  /// The output stream number for the screen.
  static final int OUTPUTSTREAM_SCREEN = 1;

  /// The output stream number for the transcript.
  static final int OUTPUTSTREAM_TRANSCRIPT = 2;

  /// The output stream number for the memory stream.
  static final int OUTPUTSTREAM_MEMORY = 3;

  /// Selects/unselects the specified output stream. If the [streamnumber]
  /// is negative, [streamnumber] is deselected, if positive, it is selected.
  /// Stream 3 (the memory stream) can not be selected by this function,
  /// but can be deselected here.
  void selectOutputStream(int streamnumber, bool flag);

  /// Selects the output stream 3 which writes to memory.
  void selectOutputStream3(int tableAddress, int tableWidth);

  /// Prints the ZSCII string at the specified address to the active
  /// output streams.
  void printZString(int stringAddress);

  /// Prints the specified ZSCII string to the active output streams.
  void print(String str);

  /// Prints a newline to the active output streams.
  void newline();

  /// Prints the specified ZSCII character.
  void printZsciiChar(Char zchar);

  /// Prints the specified signed number.
  void printNumber(int num);

  /// Flushes the active output streams.
  void flushOutput();

  /// Resets the output streams.
  void reset();
}

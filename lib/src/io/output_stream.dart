import '../../zvm.dart';

/// This interface defines an output stream in the Z-machine.
abstract class OutputStream {
  /// Prints a ZSCII character to the stream. The isInput parameter is
  /// needed to implement edit buffers.
  void print(Char zchar);

  /// Close underlying resources.
  void close();

  /// Flushes the output.
  void flush();

  /// Enables/disables this output stream.
  void select(bool flag);

  /// Determine, if this stream is selected.
  bool isSelected();
}

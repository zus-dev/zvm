import 'dart:collection';

import '../../zvm.dart';

/// The LineBufferInputStream is the default implementation for the keyboard
/// input stream. It is simply a queue holding a number of input lines.
/// Normally this is only one, but it could be used for testing by simply
/// storing more lines and running the core on it.
class LineBufferInputStream implements InputStream, Serializable {

  /// The queue holding input lines.
  Queue<String> _inputLines = Queue<String>();

  /// Adds an input line to the end of the buffer.
  void addInputLine(String line) { _inputLines.add(line); }

  @override
  String readLine() {
    return _inputLines.removeFirst();
  }

  @override
  void close() { }
}

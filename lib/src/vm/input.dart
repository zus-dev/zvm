import '../../zvm.dart';

/// Input interface.
abstract class Input {
  /// The input stream number for the keyboard.
  static final int INPUTSTREAM_KEYBOARD = 0;

  /// The input stream number for file input.
  static final int INPUTSTREAM_FILE = 1;

  /// Selects an input stream.
  void selectInputStream(int streamnumber);

  /// Returns the selected input stream.
  InputStream getSelectedInputStream();
}

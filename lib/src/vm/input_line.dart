import '../../zvm.dart';

/// This interface is used from CommandHistory to manipulate the input line.
abstract class InputLine {
  /// Deletes the previous character in the input line.
  int deletePreviousChar(List<Char> inputbuffer, int pointer);

  /// Adds a character to the current input line.
  int addChar(
      List<Char> inputbuffer, int textbuffer, int pointer, Char zsciiChar);
}

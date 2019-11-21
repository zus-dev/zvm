import '../../zvm.dart';

/// Accent tables are used by ZsciiEncoding objects to translate encoded
/// Z characters to unicode characters.
abstract class AccentTable {
  /// Returns the length of the table.
  int getLength();

  /// Returns the accent at the specified [index].
  Char getAccent(int index);

  /// Converts the accent at the specified [index] to lower case and returns
  /// the index of that character.
  int getIndexOfLowerCase(int index);
}

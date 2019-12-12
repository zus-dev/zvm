import '../../zvm.dart';

/// This is the interface definition for a dictionary.
abstract class Dictionary {

  /// Returns the number of separators.
  int getNumberOfSeparators();

  /// Returns the separator at zero-based position [i] as a ZSCII character.
  int getSeparator(int i);

  /// Returns the length of a dictionary entry.
  int getEntryLength();

  /// Returns the number of dictionary entries.
  int getNumberOfEntries();

  /// Returns the entry address at the specified position.
  /// [entryNum] entry number between (0 - getNumberOfEntries() - 1)
  int getEntryAddress(int entryNum);

  /// Looks up a string in the dictionary. The word will be truncated to
  /// the maximum word length and looked up. The result is the address
  /// of the entry or 0 if it is not found.
  /// A [token] in ZSCII encoding.
  int lookup(String token);
}

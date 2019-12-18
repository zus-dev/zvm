import '../../zvm.dart';

/// This class implements a user dictionary. The specification suggests that
/// lookup is implemented using linear search in case the user dictionary
/// is specified as unordered (negative number of entries) and in case of
/// ordered a binary search will be performed.
class UserDictionary extends AbstractDictionary {
  UserDictionary(
      Memory memory, int address, ZCharDecoder decoder, ZCharEncoder encoder)
      : super(memory, address, decoder, encoder, DictionarySizesV4ToV8());

  @override
  int lookup(final String token) {
    // We only implement linear search for user dictionaries
    final int n = getNumberOfEntries().abs();
    final ByteArray tokenBytes = truncateTokenToBytes(token);
    for (int i = 0; i < n; i++) {
      final int entryAddress = getEntryAddress(i);
      if (tokenMatch(tokenBytes, entryAddress) == 0) {
        return entryAddress;
      }
    }
    return 0;
  }
}

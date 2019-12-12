import '../../zvm.dart';

/// This class implements a view on the dictionary within a memory map.
/// Since it takes the implementations of getN
class DefaultDictionary extends AbstractDictionary {
  DefaultDictionary(Memory memory, int address, ZCharDecoder decoder,
      ZCharEncoder encoder, DictionarySizes sizes)
      : super(memory, address, decoder, encoder, sizes);

  @override
  int lookup(final String token) {
    return _lookupBinary(
        truncateTokenToBytes(token), 0, getNumberOfEntries() - 1);
  }

  /// Recursive binary search to find an input word in the dictionary.
  /// [tokenBytes] the byte array containing the input word.
  int _lookupBinary(ByteArray tokenBytes, int left, int right) {
    if (left > right) return 0;
    int middle = left + (right - left) ~/ 2;
    int entryAddress = getEntryAddress(middle);
    int res = tokenMatch(tokenBytes, entryAddress);
    if (res < 0) {
      return _lookupBinary(tokenBytes, left, middle - 1);
    } else if (res > 0) {
      return _lookupBinary(tokenBytes, middle + 1, right);
    } else {
      return entryAddress;
    }
  }
}

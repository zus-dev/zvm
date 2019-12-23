import '../../zvm.dart';

/// Abstract super class of dictionaries.
abstract class AbstractDictionary implements Dictionary {
  Memory _memory;

  /// The dictionary start address.
  int _address = 0;
  ZCharDecoder _decoder;
  ZCharEncoder _encoder;

  /// A sizes object.
  DictionarySizes _sizes;

  AbstractDictionary(
      final Memory memory,
      final int address,
      final ZCharDecoder decoder,
      final ZCharEncoder encoder,
      final DictionarySizes sizes) {
    _memory = memory;
    _address = address;
    _decoder = decoder;
    _encoder = encoder;
    _sizes = sizes;
  }

  @override
  int getNumberOfSeparators() {
    return _memory.readUnsigned8(_address).toInt();
  }

  @override
  int getSeparator(final int i) {
    return byte(_memory.readUnsigned8(_address + i + 1).toInt());
  }

  @override
  int getEntryLength() {
    return _memory
        .readUnsigned8(_address + getNumberOfSeparators() + 1)
        .toInt();
  }

  @override
  int getNumberOfEntries() {
    // The number of entries is a signed value so that we can recognize
    // a negative number
    return unsignedToSigned16(
        _memory.readUnsigned16(_address + getNumberOfSeparators() + 2));
  }

  @override
  int getEntryAddress(final int entryNum) {
    final int headerSize = getNumberOfSeparators() + 4;
    return _address + headerSize + entryNum * getEntryLength();
  }

  /// Access to the decoder object.
  ZCharDecoder getDecoder() {
    return _decoder;
  }

  /// Access to the Memory object.
  Memory getMemory() {
    return _memory;
  }

  /// Returns the DictionarySizes object for the current story file version.
  DictionarySizes getSizes() {
    return _sizes;
  }

  /// Unfortunately it seems that the maximum size of an entry is not equal
  /// to the size declared in the dictionary header, therefore we take
  /// the maximum length of a token defined in the Z-machine specification.
  /// The lookup token can only be 6 characters long in version 3
  /// and 9 in versions >= 4
  String truncateToken(final String token) {
    return token.length > _sizes.getMaxEntryChars()
        ? token.substring(0, _sizes.getMaxEntryChars())
        : token;
  }

  /// Truncates the specified token and returns a dictionary encoded byte array.
  ByteArray truncateTokenToBytes(final String token) {
    ByteArray result = ByteArray.length(_sizes.getNumEntryBytes());
    Memory buffer = DefaultMemory(result);
    _encoder.encodeString(token, buffer, 0);
    return result;
  }

  /// Lexicographical comparison of the input word and the dictionary entry
  /// at the specified address.
  ///
  /// Returns comparison value, 0 if match, &lt; 0 if lexicographical smaller,
  ///         &lt; 0 if lexicographical greater
  ///
  /// Params:
  /// [tokenBytes] input word bytes
  /// [entryAddress] dictionary entry address
  int tokenMatch(ByteArray tokenBytes, int entryAddress) {
    for (int i = 0; i < tokenBytes.length; i++) {
      int tokenByte = tokenBytes[i] & 0xff;
      int c = (getMemory().readUnsigned8(entryAddress + i) & 0xff);
      if (tokenByte != c) {
        return tokenByte - c;
      }
    }
    return 0;
  }

  /// Creates a string presentation of this dictionary.
  @override
  String toString() {
    final buffer = StringBuffer();
    int entryAddress;
    int i = 0;
    final int n = getNumberOfEntries();
    while (true) {
      entryAddress = getEntryAddress(i);
      final decoder = getDecoder();
      final memory = getMemory();
      final numBytes = _sizes.getNumEntryBytes();
      final str = decoder.decode2Zscii(memory, entryAddress, numBytes) ?? '';
      i++;
      final idx = i.toString();
      buffer.write('[${idx.padLeft(4, " ")}] \'${str.padRight(9, " ")}\'');
      if ((i % 4) == 0) {
        buffer.write("\n");
      }
      if (i == n) {
        break;
      }
    }
    return buffer.toString();
  }
}

import '../../zvm.dart';

/// This interface defines the abstract access to an abbreviations
/// table in memory, this will be used for decoding if needed.
abstract class AbbreviationsTable {
  /// Returns the word address of the specified entry number.
  int getWordAddress(int entryNum);
}

/// This interface provides decoding for the Z character encoding into
/// the Dart character system. It is important to point out that there
/// is a difference between Z characters and the ZCSII encoding. Where
/// ZSCII is a character set that is similar to ASCII/iso-8859-1, the
/// Z characters are a encoded form of characters in memory that provide
/// some degree of compression and encryption.
///
/// ZCharConverter uses the alphabet tables specified in the Z machine
/// standards document 1.0, section 3.
abstract class ZCharDecoder {
  /// Performs a ZSCII decoding at the specified position of
  /// the given memory object, this method is exclusively designed to
  /// deal with the problems of dictionary entries. These can be cropped,
  /// leaving the string in a state, that can not be decoded properly
  /// otherwise. If the provided [length] is 0, the semantics are
  /// equal to the method without the [length] parameter.
  /// Length is the maximum [length] in bytes.
  String decode2Zscii(Memory memory, int address, int length);

  /// Returns the number of Z encoded bytes at the specified string [address].
  int getNumZEncodedBytes(Memory memory, int address);

  /// Decodes the given byte value to the specified buffer using the working
  /// alphabet.
  /// The [zchar] is a z encoded character, needs to be a non-shift character
  Char decodeZChar(Char zchar);

  /// Returns the ZStringTranslator.
  ZCharTranslator getTranslator();
}

import '../../zvm.dart';

/// This class represents an alphabet element which is an alphabet and
/// an index to that alphabet. We need this to determine what kind of
/// encoding we need.
class AlphabetElement {
  /// The zchar code or the ZSCII code, if alphabet is null.
  Char _zcharCode;

  /// The alphabet or null, if index is a ZSCII code.
  Alphabet _alphabet;

  /// Constructor where the [alphabet] can be null and the [zcharCode] in the alphabet or the ZSCII code
  AlphabetElement(Alphabet alphabet, Char zcharCode) {
    this._alphabet = alphabet;
    this._zcharCode = zcharCode;
  }

  /// Returns the alphabet. Can be null, in that case index represents the ZSCII code.
  Alphabet getAlphabet() {
    return _alphabet;
  }

  /// Returns the index to the table. If the alphabet is null, this is the
  /// plain ZSCII code and should be turned into a 10-bit code by the
  /// encoder.
  Char getZCharCode() {
    return _zcharCode;
  }
}

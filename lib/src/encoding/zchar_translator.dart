import '../../zvm.dart';

/// The Z char translator is central for Z char encoding and decoding.
/// We provide an abstract interface, so the decoding and encoding algorithms
/// can be based on this.
///
/// It is basically an alphabet table combined with a current alphabet and
/// depending on this state, decides, whether to shift or translate.
/// We want to have alphabet tables as stateless information providers,
/// so we can keep them fairly simple.
///
/// Shift characters will move the object into another alphabet for the
/// duration of one character. If the current alphabet is A2, willEscapeA2()
/// indicates that the given character escapes to 10bit translation, the
/// client is responsible to join those characters and the translator will
/// not do anything about it, since it can only handle bytes.
///
/// Shift lock characters are a little special: The object will remember
/// the shift locked state until a reset() is called, if a regular shift
/// occurs, the alphabet will be changed for one translation and will
/// return to the last locked state. Since the translation process employs
/// abbreviations and ZSCII-Escape-Sequences which are external to this
/// class, the method resetToLastAlphabet() is provided to reset the state
/// from the client after an external translation has been performed.
/// extends Cloneable
abstract class ZCharTranslator {
  /// Resets the state of the translator. This should be called before
  /// a new decoding is started to reset this object to its initial state.
  void reset();

  /// This method should be invoked within the decoding of one single string.
  /// In story file versions >= 3 this is the same as invoking reset(), in
  /// V1 and V2, the object will reset to the last shift-locked alphabet.
  void resetToLastAlphabet();

  /// Clones this object. Needed, since this object has a modifiable state.
  ZCharTranslator clone();

  /// Returns the current alphabet this object works in.
  /// @return the current alphabet
  Alphabet getCurrentAlphabet();

  /// Translates the given zchar to a Unicode character.
  Char translate(Char zchar);

  /// If this object is in alphabet A2 now, this function determines if the
  /// given [zchar] character is an A2 escape.
  bool willEscapeA2(Char zchar);

  /// Return true if this the specified [zchar] character is an abbreviation in the
  /// current alphabet table.
  bool isAbbreviation(Char zchar);

  /// Provides a reverse translation. Given a ZSCII character, determine
  /// the alphabet and the index to this alphabet. If alphabet in the
  /// result is null, this is a plain ZSCII character.
  AlphabetElement getAlphabetElementFor(Char zsciiChar);
}

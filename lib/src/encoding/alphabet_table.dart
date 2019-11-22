import '../../zvm.dart';

/// Defines the possible alphabets here.
enum Alphabet { A0, A1, A2 }

/// The alphabet table is a central part of the Z encoding system. It stores
/// the characters that are mapped to each alphabet and provides information
/// about shift and escape situations.
abstract class AlphabetTable {
  static const ALPHABET_START = 6;
  static const ALPHABET_END = 31;

  static const SHIFT_2 = 0x02; // Shift 1
  static const SHIFT_3 = 0x03; // Shift 2
  static const SHIFT_4 = 0x04; // Shift lock 1
  static const SHIFT_5 = 0x05; // Shift lock 2

  /// This character code, used from A2, denotes that a 10 bit value follows.
  static const A2_ESCAPE = 0x06; // escape character

  /// Returns the ZSCII character from alphabet 0 at the specified index.
  Char getA0Char(int zchar);

  /// Returns the ZSCII character from alphabet 1 at the specified index.
  Char getA1Char(int zchar);

  /// Returns the ZSCII character from alphabet 2 at the specified index.
  Char getA2Char(int zchar);

  /// Returns the index of the specified ZSCII character in alphabet 0.
  int getA0CharCode(Char zsciiChar);

  /// Returns the index of the specified ZSCII character in alphabet 2 or -1.
  int getA1CharCode(Char zsciiChar);

  /// Returns the index of the specified ZSCII character in alphabet 2 or -1.
  int getA2CharCode(Char zsciiChar);

  /// Determines if the specified character marks a abbreviation.
  bool isAbbreviation(Char zchar);

  /// Returns true if the specified character is a shift level 1 character.
  bool isShift1(Char zchar);

  /// Returns true if the specified character is a shift level 2 character.
  bool isShift2(Char zchar);

  /// Returns true if the specified character is a shift lock character.
  bool isShiftLock(Char zchar);

  /// Returns true if the specified character is a shift character.
  /// Includes shift lock.
  bool isShift(Char zchar);
}

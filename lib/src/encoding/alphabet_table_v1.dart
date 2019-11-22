import '../../zvm.dart';

/// An alphabet table in V1 story files behaves like an alphabet table in
/// V2, except that it has a different A2 alphabet and does not support
/// abbreviations.
/// Furthermore, character 1 returns '\n'. This is a thing that leads
/// to the extension of the getAnChar() methods, handling index -5.
class AlphabetTableV1 extends AlphabetTableV2 {
  ///  V1 Alphabet 2 has a slightly different structure.
  static const String _A2CHARS = " 0123456789.,!?_#'\"/\\<-:()";

  @override
  Char getA0Char(final int zchar) {
    if (zchar == 1) return Char.of('\n');
    return super.getA0Char(zchar);
  }

  @override
  Char getA1Char(final int zchar) {
    if (zchar == 1) return Char.of('\n');
    return super.getA1Char(zchar);
  }

  @override
  Char getA2Char(final int zchar) {
    if (zchar == 0) return Char.of(' ');
    if (zchar == 1) return Char.of('\n');
    return Char.at(_A2CHARS, zchar - AlphabetTable.ALPHABET_START);
  }

  @override
  int getA2CharCode(final Char zsciiChar) {
    return DefaultAlphabetTable.getCharCodeFor(_A2CHARS, zsciiChar);
  }

  @override
  bool isAbbreviation(final Char zchar) {
    return false;
  }
}

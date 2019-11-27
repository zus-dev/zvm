import '../../zvm.dart';

/// The usage of ZSCII is a little confusing, within a story file it uses
/// alphabet tables to encode/decode it to an unreadable format, for input
/// and output it uses a more readable encoding which resembles iso-8859-n.
/// ZsciiEncoding therefore captures this input/output aspect of ZSCII
/// whereas ZsciiConverter and ZsciiString handle story file encoded strings.
///
/// This class has a non-modifiable state, so it can be shared throughout
/// the whole application.
class ZsciiEncoding implements IZsciiEncoding {
  AccentTable _accentTable; // private

  ZsciiEncoding(final AccentTable accentTable) {
    this._accentTable = accentTable;
  }

  /// Returns true if the input is a valid ZSCII character, false otherwise.
  bool isZsciiChar(final Char zchar) {
    switch (zchar.toInt()) {
      case IZsciiEncoding.NULL:
      case IZsciiEncoding.DELETE:
      case IZsciiEncoding.NEWLINE:
      case IZsciiEncoding.ESCAPE:
        return true;
      default:
        return isAscii(zchar) || isAccent(zchar) || _isUnicodeCharacter(zchar);
    }
  }

  /// Returns true if the specified unicode character can be converted to a ZSCII
  /// character, false otherwise.
  bool isConvertibleToZscii(final Char c) {
    return isAscii(c) ||
        _isInTranslationTable(c) ||
        c == Char.of('\n') ||
        c.toInt() == 0 ||
        _isUnicodeCharacter(c);
  }

  /// Converts a ZSCII character to a unicode character. Will return
  /// '?' if the given character is not known.
  @override
  Char getUnicodeChar(final Char zchar) {
    if (isAscii(zchar)) {
      return zchar;
    }
    if (isAccent(zchar)) {
      final index = zchar.toInt() - IZsciiEncoding.ACCENT_START;
      if (index < _accentTable.getLength()) {
        return _accentTable.getAccent(index);
      }
    }
    if (zchar.toInt() == IZsciiEncoding.NULL) {
      return Char.of('\u0000');
    }
    if (zchar.toInt() == IZsciiEncoding.NEWLINE ||
        zchar.toInt() == IZsciiEncoding.NEWLINE_10) {
      return Char.of('\n');
    }
    if (_isUnicodeCharacter(zchar)) {
      return zchar;
    }
    return Char.of('?');
  }

  /// Converts the specified string into its ZSCII representation.
  @override
  String convertToZscii(final String str) {
    var result = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      result.write(getZsciiChar(Char.at(str, i)));
    }
    return result.toString();
  }

  /// Converts the specified unicode character [c] to a ZSCII character.
  /// Will return 0 if the character can not be converted.
  Char getZsciiChar(final Char c) {
    if (isAscii(c)) {
      return c;
    } else if (_isInTranslationTable(c)) {
      return Char(_getIndexInTranslationTable(c) + IZsciiEncoding.ACCENT_START);
    } else if (c == Char.of('\n')) {
      return Char(IZsciiEncoding.NEWLINE);
    }
    return Char(0);
  }

  /// Determines whether the specified character [c] is in the translation table.
  bool _isInTranslationTable(final Char c) {
    return _getIndexInTranslationTable(c) >= 0;
  }

  /// Determines the index of character [c] in the translation table.
  int _getIndexInTranslationTable(final Char c) {
    for (int i = 0; i < _accentTable.getLength(); i++) {
      if (_accentTable.getAccent(i) == c) return i;
    }
    return -1;
  }

  /// Tests the given ZSCII character if it falls in the ASCII range.
  static bool isAscii(final Char zchar) {
    return zchar.toInt() >= IZsciiEncoding.ASCII_START &&
        zchar.toInt() <= IZsciiEncoding.ASCII_END;
  }

  /// Tests the given ZSCII character for whether it is in the special range.
  static bool isAccent(final Char zchar) {
    return zchar.toInt() >= IZsciiEncoding.ACCENT_START &&
        zchar.toInt() <= IZsciiEncoding.ACCENT_END;
  }

  /// Returns true if [zsciiChar] is a cursor key.
  static bool isCursorKey(final Char zsciiChar) {
    return zsciiChar.toInt() >= IZsciiEncoding.CURSOR_UP &&
        zsciiChar.toInt() <= IZsciiEncoding.CURSOR_RIGHT;
  }

  /// Returns true if [zchar] is in the unicode range.
  static bool _isUnicodeCharacter(final Char zchar) {
    return zchar.toInt() >= 256;
  }

  /// Returns true if [zsciiChar] is a function key.
  static bool isFunctionKey(final Char zsciiChar) {
    return (zsciiChar.toInt() >= 129 && zsciiChar.toInt() <= 154) ||
        (zsciiChar.toInt() >= 252 && zsciiChar.toInt() <= 254);
  }

  /// Converts the character to lower case.
  Char toLower(final Char zsciiChar) {
    if (isAscii(zsciiChar)) {
      return zsciiChar.toLowerCase();
    }
    if (isAccent(zsciiChar)) {
      return Char(_accentTable.getIndexOfLowerCase(
              zsciiChar.toInt() - IZsciiEncoding.ACCENT_START) +
          IZsciiEncoding.ACCENT_START);
    }
    return zsciiChar;
  }
}

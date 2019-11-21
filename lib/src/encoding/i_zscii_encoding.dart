import '../../zvm.dart';

/// ZsciiEncoding interface.
abstract class IZsciiEncoding {
  static const NULL = 0;
  static const DELETE = 8;
  static const NEWLINE_10 = 10;
  static const NEWLINE = 13;
  static const ESCAPE = 27;
  static const CURSOR_UP = 129;
  static const CURSOR_DOWN = 130;
  static const CURSOR_LEFT = 131;
  static const CURSOR_RIGHT = 132;
  static const ASCII_START = 32;
  static const ASCII_END = 126;

  /// The start of the accent range.
  static const ACCENT_START = 155;

  /// End of the accent range.
  static const ACCENT_END = 251;

  static const MOUSE_DOUBLE_CLICK = 253;
  static const MOUSE_SINGLE_CLICK = 254;

  /// Converts the specified string into its ZSCII representation.
  String convertToZscii(String str);

  /// Converts a ZSCII character to a unicode character. Will return
  /// '?' if the given character is not known.
  Char getUnicodeChar(Char zsciiChar);
}

import 'helpers.dart';

/// Attributes for the file header flags.
enum Attribute {
  DEFAULT_FONT_IS_VARIABLE,
  SCORE_GAME,
  SUPPORTS_STATUSLINE,
  SUPPORTS_SCREEN_SPLITTING, // V3 only
  TRANSCRIPTING,
  FORCE_FIXED_FONT,
  SUPPORTS_TIMED_INPUT,
  SUPPORTS_FIXED_FONT,
  SUPPORTS_ITALIC,
  SUPPORTS_BOLD,
  SUPPORTS_COLOURS,
  USE_MOUSE
}

abstract class StoryFileHeader {
  final int RELEASE = 0x02;
  final int PROGRAM_START = 0x06;
  final int DICTIONARY = 0x08;
  final int OBJECT_TABLE = 0x0a;
  final int GLOBALS = 0x0c;
  final int STATIC_MEM = 0x0e;
  final int ABBREVIATIONS = 0x18;
  final int CHECKSUM = 0x1c;
  final int INTERPRETER_NUMBER = 0x1e;
  final int SCREEN_HEIGHT = 0x20;
  final int SCREEN_WIDTH = 0x21;
  final int SCREEN_WIDTH_UNITS = 0x22;
  final int SCREEN_HEIGHT_UNITS = 0x24;
  final int ROUTINE_OFFSET = 0x28;
  final int STATIC_STRING_OFFSET = 0x2a;
  final int DEFAULT_BACKGROUND = 0x2c;
  final int DEFAULT_FOREGROUND = 0x2d;
  final int TERMINATORS = 0x2e;
  final int OUTPUT_STREAM3_WIDTH = 0x30; // 16 bit
  final int STD_REVISION_MAJOR = 0x32;
  final int STD_REVISION_MINOR = 0x33;
  final int CUSTOM_ALPHABET = 0x34;

  /// Returns the story file version.
  int getVersion();

  /// Returns this game's serial number.
  String getSerialNumber();

  /// Returns this story file's length.
  int getFileLength();

  /// Sets the interpreter version.
  void setInterpreterVersion(int version);

  /// Sets the font width in number of [units] in width of a '0'.
  void setFontWidth(int units);

  /// Sets the font height in number of [units] in width of a '0'.
  void setFontHeight(int units);

  /// Sets the mouse coordinates.
  void setMouseCoordinates(int x, int y);

  /// Returns the address of the custom unicode translation table.
  Char getCustomAccentTable();

  /// Enables the specified [attribute].
  void setEnabled(Attribute attribute, bool flag);

  /// Checks the enabled status of the specified [attribute].
  bool isEnabled(Attribute attribute);
}

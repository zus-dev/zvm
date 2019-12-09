import '../../zvm.dart';

/// This interface defines the access to the screen model.
abstract class ScreenModel {
  static final int CURRENT_WINDOW = -3;
  static final int WINDOW_BOTTOM = 0;
  static final int WINDOW_TOP = 1;

  /// Font number for the standard font.
  Char FONT_NORMAL = Char(1);

  /// Font number for the character graphics font.
  Char FONT_CHARACTER_GRAPHICS = Char(3);

  /// Font number for the fixed pitch font.
  Char FONT_FIXED = Char(4);

  static const int TEXTSTYLE_ROMAN = 0;
  static const int TEXTSTYLE_REVERSE_VIDEO = 1;
  static const int TEXTSTYLE_BOLD = 2;
  static const int TEXTSTYLE_ITALIC = 4;
  static const int TEXTSTYLE_FIXED = 8;

  /// Color definitions.
  static const int UNDEFINED = -1000;
  static const int COLOR_UNDER_CURSOR = -1;
  static const int COLOR_CURRENT = 0;
  static const int COLOR_DEFAULT = 1;
  static const int COLOR_BLACK = 2;
  static const int COLOR_RED = 3;
  static const int COLOR_GREEN = 4;
  static const int COLOR_YELLOW = 5;
  static const int COLOR_BLUE = 6;
  static const int COLOR_MAGENTA = 7;
  static const int COLOR_CYAN = 8;
  static const int COLOR_WHITE = 9;
  static const int COLOR_MS_DOS_DARKISH_GREY = 10;

  /// Returns the current annotation of the bottom window.
  TextAnnotation getBottomAnnotation();

  /// Returns the current annotation of the top window.
  TextAnnotation getTopAnnotation();

  /// Resets the screen model.
  void reset();

  /// Splits the screen into two windows, the upper window will contain
  /// [linesUpperWindow] lines. If linesUpperWindow is 0, the window will
  /// be unsplit.
  void splitWindow(int linesUpperWindow);

  /// Sets the active window.
  void setWindow(int window);

  /// Returns the active window.
  int getActiveWindow();

  /// Sets the text style.
  void setTextStyle(int style);

  /// Sets the buffer mode.
  void setBufferMode(bool flag);

  /// Version 4/5: If value is 1, erase from current cursor position to the
  /// end of the line.
  void eraseLine(int value);

  /// Clears the window with the specified number to the background color.
  /// If window is -1, the screen is unsplit and the area is cleared.
  /// If window is -2, the whole screen is cleared, but the splitting status
  /// is retained.
  void eraseWindow(int window);

  /// Moves the cursor in the current window to the specified position.
  void setTextCursor(int line, int column, int window);

  /// Retrieves the active window's cursor.
  TextCursor getTextCursor();

  /// Sets the paging mode. This is useful if the input stream is a file.
  //void setPaging(bool flag);

  /// Sets the font in the current window.
  Char setFont(Char fontnumber);

  /// Sets the background color.
  void setBackground(int colornumber, int window);

  /// Sets the foreground color.
  void setForeground(int colornumber, int window);

  /// Returns the output stream associated with the screen.
  OutputStream getOutputStream();
}

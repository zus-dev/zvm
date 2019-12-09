import '../../zvm.dart';

/// Window 6 interface. V6 windows in the Z-machine are probably the hackiest
/// and trickiest challenge in a Z-machine.
abstract class Window6 {
  static const int PROPERTY_Y_COORD = 0;
  static const int PROPERTY_X_COORD = 1;
  static const int PROPERTY_Y_SIZE = 2;
  static const int PROPERTY_X_SIZE = 3;
  static const int PROPERTY_Y_CURSOR = 4;
  static const int PROPERTY_X_CURSOR = 5;
  static const int PROPERTY_LEFT_MARGIN = 6;
  static const int PROPERTY_RIGHT_MARGIN = 7;
  static const int PROPERTY_INTERRUPT_ROUTINE = 8;
  static const int PROPERTY_INTERRUPT_COUNT = 9;
  static const int PROPERTY_TEXTSTYLE = 10;
  static const int PROPERTY_COLOURDATA = 11;
  static const int PROPERTY_FONT_NUMBER = 12;
  static const int PROPERTY_FONT_SIZE = 13;
  static const int PROPERTY_ATTRIBUTES = 14;
  static const int PROPERTY_LINE_COUNT = 15;

  /// Draws the specified picture at the given position.
  void drawPicture(ZmppImage picture, int y, int x);

  /// Clears the area of the specified picture at the given position.
  void erasePicture(ZmppImage picture, int y, int x);

  /// Moves the window to the specified coordinates in pixels, (1, 1)
  /// being the top left.
  void move(int y, int x);

  /// Sets window size in pixels.
  void setSize(int height, int width);

  /// Sets the window style.
  /// The <i>styleflags</i> parameter is a bitmask specified as follows:
  /// - Bit 0: keep text within margins
  /// - Bit 1: scroll when at bottom
  /// - Bit 2: copy text to transcript stream (stream 2)
  /// - Bit 3: word wrapping
  /// The <i>operation</i> parameter is specified as this:
  /// - 0: set style flags to the specified mask
  /// - 1: set the bits supplied
  /// - 2: clear the bits supplied
  /// - 3: reverse the bits supplied
  void setStyle(int styleflags, int operation);

  /// Sets the window margins in pixels. If the cursor is overtaken by the
  /// new margins, set it to the new left margin.
  void setMargins(int left, int right);

  /// Returns the specified window property.
  /// 0  y coordinate    6   left margin size            12  font number
  /// 1  x coordinate    7   right margin size           13  font size
  /// 2  y size          8   newline interrupt routine   14  attributes
  /// 3  x size          9   interrupt countdown         15  line count
  /// 4  y cursor        10  text style
  /// 5  x cursor        11  colour data
  int getProperty(int propertynum);

  /// Sets the specified window property.
  void putProperty(int propertynum, int value);

  /// Scrolls the window by the specified amount of pixels, negative values
  /// scroll down, positive scroll up.
  void scroll(int pixels);
}

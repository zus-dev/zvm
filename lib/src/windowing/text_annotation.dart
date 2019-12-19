import '../../zvm.dart';

/// An annotation to indicate how a sequence of characters should be printed.
class TextAnnotation implements Serializable {
  // Font flags have the same bit layout as in the ScreenModel interface so
  // so the flags are compatible
  static final Char FONT_NORMAL = Char(1);
  static final Char FONT_CHARACTER_GRAPHICS = Char(3);
  static final Char FONT_FIXED = Char(4);

  // Text styles have the same bit layout as in the ScreenModel interface
  // so the flags are compatible
  static final int TEXTSTYLE_ROMAN = 0;
  static final int TEXTSTYLE_REVERSE_VIDEO = 1;
  static final int TEXTSTYLE_BOLD = 2;
  static final int TEXTSTYLE_ITALIC = 4;
  static final int TEXTSTYLE_FIXED = 8;

  // private:
  Char font = Char(0);
  int style = 0;
  int background = 0;
  int foreground = 0;

  TextAnnotation(Char font, int style,
      [int background = ScreenModel.COLOR_DEFAULT,
      int foreground = ScreenModel.COLOR_DEFAULT]) {
    this.font = font;
    this.style = style;
    this.background = background;
    this.foreground = foreground;
  }

  /// Derives an annotation with a modified font based on this object.
  TextAnnotation deriveFont(Char newFont) {
    return TextAnnotation(
        newFont, this.style, this.background, this.foreground);
  }

  /// Derives an annotation with a modified text style based on this object.
  TextAnnotation deriveStyle(int newStyle) {
    int finalStyle = style;
    if (newStyle == TextAnnotation.TEXTSTYLE_ROMAN) {
      finalStyle = newStyle;
    } else {
      finalStyle |= newStyle;
    }
    return TextAnnotation(
        this.font, finalStyle, this.background, this.foreground);
  }

  /// Derives an annotation with a modified background color based
  /// on this object.
  TextAnnotation deriveBackground(int newBackground) {
    return TextAnnotation(
        this.font, this.style, newBackground, this.foreground);
  }

  /// Derives an annotation with a modified foreground color based
  /// on this object.
  TextAnnotation deriveForeground(int newForeground) {
    return TextAnnotation(
        this.font, this.style, this.background, newForeground);
  }

  /// Returns the font.
  Char getFont() {
    return font;
  }

  /// Determines whether this annotation has a fixed style font.
  bool isFixed() {
    return font == FONT_FIXED || (style & TEXTSTYLE_FIXED) == TEXTSTYLE_FIXED;
  }

  /// Determines whether this annotation has a roman font.
  bool isRoman() {
    return style == TEXTSTYLE_ROMAN;
  }

  /// Determines whether this annotation has a bold font.
  bool isBold() {
    return (style & TEXTSTYLE_BOLD) == TEXTSTYLE_BOLD;
  }

  /// Determines whether this annotation has an italic font.
  bool isItalic() {
    return (style & TEXTSTYLE_ITALIC) == TEXTSTYLE_ITALIC;
  }

  /// Determines whether the text is displayed as reverse video.
  bool isReverseVideo() {
    return (style & TEXTSTYLE_REVERSE_VIDEO) == TEXTSTYLE_REVERSE_VIDEO;
  }

  /// Returns the background color.
  int getBackground() {
    return background;
  }

  /// Returns the foreground color.
  int getForeground() {
    return foreground;
  }

  @override
  String toString() {
    return 'TextAnnotation, fixed: ${isFixed()} bold: ${isBold()}' +
        ' italic: ${isItalic()} reverse: ${isReverseVideo()}' +
        ' bg: ${background} fg: ${foreground}';
  }
}

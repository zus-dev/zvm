import '../../zvm.dart';

/// This class implements the virtual top window of the Z-machine screen model.
class TopWindow implements TextCursor {
  int cursorx = 0;
  int cursory = 0;
  int numCharsPerRow = 0;
  int numRows = 0;

  // Note: It is assumed that this annotation will be overridden,
  // check if this is the case for Varicella
  TextAnnotation annotation = TextAnnotation(
      ScreenModel.FONT_FIXED,
      ScreenModel.TEXTSTYLE_ROMAN,
      ScreenModel.COLOR_BLACK,
      ScreenModel.COLOR_WHITE);

  TopWindow() {
    resetCursor();
  }

  /// Resets the text cursor position.
  void resetCursor() {
    cursorx = 1;
    cursory = 1;
  }

  /// Returns the current TextAnnotation used for this window.
  TextAnnotation getCurrentAnnotation() {
    return annotation;
  }

  /// Sets the number of rows in this window.
  void setNumRows(int numRows) {
    this.numRows = numRows;
  }

  /// Returns the number of rows in this window.
  int getNumRows() {
    return numRows;
  }

  /// Sets the new number of characters per row.
  void setNumCharsPerRow(int numChars) {
    numCharsPerRow = numChars;
  }

  /// Sets the font number for this window.
  Char setFont(Char font) {
    Char previousFont = this.annotation.getFont();
    annotation = annotation.deriveFont(font);
    return previousFont;
  }

  /// Sets the current text style in this window.
  void setCurrentTextStyle(int style) {
    annotation = annotation.deriveStyle(style);
  }

  /// Sets the foreground color in this window.
  void setForeground(int color) {
    annotation = annotation.deriveForeground(color);
  }

  /// Sets the new background color in this window.
  void setBackground(int color) {
    annotation = annotation.deriveBackground(color);
  }

  /// Annotates the specified character with the current annotation.
  AnnotatedCharacter annotateCharacter(Char zchar) {
    return AnnotatedCharacter(annotation, zchar);
  }

  /// Sets the new text cursor position.
  void setTextCursor(int line, int column) {
    if (_outOfUpperBounds(line, column)) {
      // set to left margin of current line
      cursorx = 1;
    } else {
      this.cursorx = column;
      this.cursory = line;
    }
  }

  /// Increments the current cursor position.
  void incrementCursorXPos() {
    this.cursorx++;
    // Make sure the cursor does not overrun the margin
    if (cursorx >= numCharsPerRow) {
      cursorx = numCharsPerRow - 1;
    }
  }

  /// Notifies the ScreenModelListeners.
  void notifyChange(ScreenModelListener l, Char c) {
    if (c.toString() == '\n') {
      // handle newline differently
      cursorx = 0;
      cursory++;
    } else {
      l.topWindowUpdated(cursorx, cursory, annotateCharacter(c));
    }
  }

  /// Determines whether the specified position is outside the upper window's
  /// bounds.
  bool _outOfUpperBounds(int line, int column) {
    if (line < 1 || line > numRows) return true;
    if (column < 1 || column > numCharsPerRow) return true;
    return false;
  }

  @override
  int getLine() {
    return cursory;
  }

  @override
  int getColumn() {
    return cursorx;
  }

  @override
  void setLine(int line) {
    cursory = line;
  }

  @override
  void setColumn(int column) {
    cursorx = column;
  }

  @override
  void setPosition(int line, int column) {
    cursorx = column;
    cursory = line;
  }
}

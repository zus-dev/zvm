import 'package:zvm/zvm.dart';

import 'screen_model_split_view.dart';

/// A class representing a text grid in a Z-machine or Glk screen model.
/// Rather than representing the view through its own Swing component,
/// conceptually it just a clipped area within a hosting component.
class TextGridView {
  static final AnnotatedCharacter _EMPTY_CHAR = null;
  var _grid = List<List<AnnotatedCharacter>>();
  ScreenModelSplitView _parent;

  //static final Logger _LOG = Logger.getLogger("org.zmpp");
  bool cursorShown = false;

  TextGridView(ScreenModelSplitView parent) {
    this._parent = parent;
  }

  /// Returns a reference to the current screen model.
  BufferedScreenModel _getScreenModel() {
    return _parent.getScreenModel();
  }

  /// Resize the grid, which changes the number of characters that can be
  /// displayed
  void setGridSize(int numrows, int numcols) {
    _grid = List.generate(numrows, (_) => List(numcols));
  }

  /// The number of rows this component can display.
  int getNumRows() {
    return _grid == null ? 0 : _grid.length;
  }

  /// The number of columns this component can display.
  int getNumColumns() {
    return _grid == null || _grid.isEmpty ? 0 : _grid[0].length;
  }

  /// Clears the window by printing spaces in the specified [color].
  void clear(int color) {
    //LOG.info("clear top window with color: " + color);
    // Fill the size with the background color
    //TODO: fix me getScreenModel().getNumRowsUpper()
    final screenModelNumRowsUpper = _grid.length;
    TextAnnotation annotation = TextAnnotation(
        ScreenModel.FONT_FIXED, ScreenModel.TEXTSTYLE_ROMAN, color, color);
    AnnotatedCharacter annchar = AnnotatedCharacter(annotation, Char.of(' '));
    for (int row = 0; row < screenModelNumRowsUpper; row++) {
      for (int col = 0; col < _grid[row].length; col++) {
        _grid[row][col] = annchar;
      }
    }
    // The rest of the lines is transparent
    for (int row = screenModelNumRowsUpper; row < _grid.length; row++) {
      for (int col = 0; col < _grid[row].length; col++) {
        _grid[row][col] = null;
      }
    }
  }

  /// Sets the character at the specified position.
  /// [line] and [column] are 1-based
  void setCharacter(int line, int column, AnnotatedCharacter c) {
    /*
    if (c != null) {
    LOG.info(String.format(
      "SET_CHAR, line: %d col: %d c: '%c' BG: %d FG: %d REVERSE: %b\n",
             line, column, c.getCharacter(),
             c.getAnnotation().getBackground(),
             c.getAnnotation().getForeground(),
             c.getAnnotation().isReverseVideo()));
    }*/
    _grid[line - 1][column - 1] = c;
  }

  /// Displays or hides the cursor.
  void viewCursor(bool flag) {
    TextCursor cursor = _getScreenModel().getTextCursor();
    if (flag) {
      setCharacter(cursor.getLine(), cursor.getColumn(), _getCursorChar());
      cursorShown = true;
    } else {
      if (cursorShown) {
        setCharacter(cursor.getLine(), cursor.getColumn(), _EMPTY_CHAR);
      }
      cursorShown = false;
    }
  }

  /// Returns a character that can represent the cursor.
  AnnotatedCharacter _getCursorChar() {
    return AnnotatedCharacter(
        TextAnnotation(
          ScreenModel.FONT_FIXED,
          ScreenModel.TEXTSTYLE_REVERSE_VIDEO,
        ),
        Char.of(' '));
  }

  @override
  String toString() {
    StringBuffer builder = StringBuffer();
    for (int row = 0; row < _grid.length; row++) {
      for (int col = 0; col < _grid[row].length; col++) {
        if (_grid[row][col] != null) {
          builder.write(_grid[row][col].getCharacter());
        }
      }
      builder.write("\n");
    }
    return builder.toString();
  }
}

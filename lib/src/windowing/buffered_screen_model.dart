import '../../zvm.dart';

/// Status line listener interface.
abstract class StatusLineListener {
  /// Update the status line.
  void statusLineUpdated(String objectDescription, String status);
}

/// BufferedScreenModel is the attempt to provide a reusable screen model
/// that will be part of the core in later versions. It is mainly a
/// configurable virtual window management model, providing virtual windows
/// that the machine writes to. It is intended to provide interfaces to
/// both Glk and Z-machine and to combine the abilities of both.
class BufferedScreenModel implements ScreenModel, StatusLine, OutputStream {
  static final Logger _LOG = Logger.getLogger("org.zmpp.screen");

  int _current = ScreenModel.WINDOW_BOTTOM;
  BufferedTextWindow _bottomWindow = BufferedTextWindow();
  TopWindow _topWindow = TopWindow();
  List<ScreenModelListener> _screenModelListeners = List<ScreenModelListener>();
  List<StatusLineListener> _statusLineListeners = List<StatusLineListener>();
  IZsciiEncoding _encoding;
  Memory _memory;
  StoryFileHeader _fileheader;

  // OutputStream
  bool _selected = false;

  /// Adds a ScreenModelListener.
  void addScreenModelListener(ScreenModelListener l) {
    _screenModelListeners.add(l);
  }

  /// Adds a StatusLineListener.
  void addStatusLineListener(StatusLineListener l) {
    _statusLineListeners.add(l);
  }

  /// Initialize the model, an Encoding object is needed to retrieve
  /// Unicode characters.
  void init(Memory aMemory, IZsciiEncoding anEncoding) {
    this._memory = aMemory;
    this._fileheader = DefaultStoryFileHeader(_memory);
    this._encoding = anEncoding;
  }

  @override
  TextAnnotation getTopAnnotation() {
    return _topWindow.getCurrentAnnotation();
  }

  @override
  TextAnnotation getBottomAnnotation() {
    return _bottomWindow.getCurrentAnnotation();
  }

  /// Sets the number of characters per row, should be called if the size of
  /// the output area or the size of the font changes.
  void setNumCharsPerRow(int num) {
    _topWindow.setNumCharsPerRow(num);
  }

  /// Resets the screen model.
  void reset() {
    _topWindow.resetCursor();
    _bottomWindow.reset();
    _current = ScreenModel.WINDOW_BOTTOM;
  }

  /// Splits the window.
  void splitWindow(int linesUpperWindow) {
    _LOG.info("SPLIT_WINDOW: ${linesUpperWindow}");
    _topWindow.setNumRows(linesUpperWindow);
    for (ScreenModelListener l in _screenModelListeners) {
      l.screenSplit(linesUpperWindow);
    }
  }

  @override
  void setWindow(int window) {
    _LOG.info("SET_WINDOW: ${window}");
    _current = window;
    if (_current == ScreenModel.WINDOW_TOP) {
      _topWindow.resetCursor();
    }
  }

  @override
  int getActiveWindow() {
    return _current;
  }

  @override
  void setTextStyle(int style) {
    _LOG.info("SET_TEXT_STYLE: ${style}");
    _topWindow.setCurrentTextStyle(style);
    _bottomWindow.setCurrentTextStyle(style);
  }

  @override
  void setBufferMode(bool flag) {
    _LOG.info("SET_BUFFER_MODE: ${flag}");
    _bottomWindow.setBuffered(flag);
  }

  @override
  void eraseLine(int value) {
    _LOG.info("ERASE_LINE: ${value}");
    throw UnsupportedOperationException("Not supported yet.");
  }

  @override
  void eraseWindow(int window) {
    _LOG.info("ERASE_WINDOW: ${window}");
    for (ScreenModelListener l in _screenModelListeners) {
      l.windowErased(window);
    }
    if (window == -1) {
      splitWindow(0);
      setWindow(ScreenModel.WINDOW_BOTTOM);
      _topWindow.resetCursor();
    }
    if (window == ScreenModel.WINDOW_TOP) {
      for (ScreenModelListener l in _screenModelListeners) {
        l.windowErased(ScreenModel.WINDOW_TOP);
      }
      _topWindow.resetCursor();
    }
  }

  @override
  void setTextCursor(int line, int column, int window) {
    int targetWindow = _getTargetWindow(window);
    //LOG.info(String.format("SET_TEXT_CURSOR, line: %d, column: %d, " +
    //                       "window: %d\n", line, column, targetWindow));
    if (targetWindow == ScreenModel.WINDOW_TOP) {
      for (ScreenModelListener l in _screenModelListeners) {
        l.topWindowCursorMoving(line, column);
      }
      _topWindow.setTextCursor(line, column);
    }
  }

  /// Returns the window number for the specified parameter.
  int _getTargetWindow(int window) {
    return window == ScreenModel.CURRENT_WINDOW ? _current : window;
  }

  @override
  TextCursor getTextCursor() {
    if (this._current != ScreenModel.WINDOW_TOP) {
      throw UnsupportedOperationException("Not supported yet.");
    }
    return _topWindow;
  }

  @override
  Char setFont(Char fontnumber) {
    if (fontnumber != ScreenModel.FONT_FIXED &&
        fontnumber != ScreenModel.FONT_NORMAL) {
      setFont(ScreenModel.FONT_FIXED); // call yourself again with the fixed
      return Char(0);
    }
    if (_current == ScreenModel.WINDOW_TOP) {
      // For the top window, the normal font should not be used, instead,
      // we always assume the fixed font as the top window normal font
      // The character graphics font is a fixed font, so we want to set that
      return fontnumber == ScreenModel.FONT_NORMAL
          ? ScreenModel.FONT_FIXED
          : _topWindow.setFont(fontnumber);
    } else {
      return _bottomWindow.setCurrentFont(fontnumber);
    }
  }

  @override
  void setBackground(int colornumber, int window) {
    _LOG.info("setBackground, color: ${colornumber}");
    _topWindow.setBackground(colornumber);
    _bottomWindow.setBackground(colornumber);
  }

  @override
  void setForeground(int colornumber, int window) {
    _LOG.info("setForeground, color: ${colornumber}");
    _topWindow.setForeground(colornumber);
    _bottomWindow.setForeground(colornumber);
  }

  @override
  OutputStream getOutputStream() {
    return this;
  }

  /// This checks the fixed font flag and adjust the font if necessary.
  void _checkFixedFontFlag() {
    if (_fileheader.isEnabled(Attribute.FORCE_FIXED_FONT) &&
        _current == ScreenModel.WINDOW_BOTTOM) {
      _bottomWindow.setCurrentFont(ScreenModel.FONT_FIXED);
    } else if (!_fileheader.isEnabled(Attribute.FORCE_FIXED_FONT) &&
        _current == ScreenModel.WINDOW_BOTTOM) {
      _bottomWindow.setCurrentFont(ScreenModel.FONT_NORMAL);
    }
  }

  @override
  void print(Char zsciiChar) {
    _checkFixedFontFlag();
    Char unicodeChar = _encoding.getUnicodeChar(zsciiChar);
    if (_current == ScreenModel.WINDOW_BOTTOM) {
      _bottomWindow.printChar(unicodeChar);
      if (!_bottomWindow.isBuffered()) {
        flush();
      }
    } else if (_current == ScreenModel.WINDOW_TOP) {
      for (ScreenModelListener l in _screenModelListeners) {
        _topWindow.notifyChange(l, unicodeChar);
        _topWindow.incrementCursorXPos();
      }
    }
  }

  @override
  void close() {}

  /// Notify listeners that the screen has changed.
  void flush() {
    for (ScreenModelListener l in _screenModelListeners) {
      l.screenModelUpdated(this);
    }
  }

  @override
  void select(bool flag) {
    _selected = flag;
  }

  @override
  bool isSelected() {
    return _selected;
  }

  @override
  void updateStatusScore(String objectName, int score, int steps) {
    for (StatusLineListener l in _statusLineListeners) {
      l.statusLineUpdated(objectName, "${score}/${steps}");
    }
  }

  @override
  void updateStatusTime(String objectName, int hours, int minutes) {
    for (StatusLineListener l in _statusLineListeners) {
      l.statusLineUpdated(objectName, "${hours}:${minutes}");
    }
  }

  /// Returns number of rows in upper window.
  int getNumRowsUpper() {
    return _topWindow.getNumRows();
  }

  /// Returns current background color.
  int getBackground() {
    int background = _bottomWindow.getBackground();
    return background == ScreenModel.COLOR_DEFAULT
        ? _getDefaultBackground()
        : background;
  }

  /// Returns current foreground color.
  int getForeground() {
    int foreground = _bottomWindow.getForeground();
    return foreground == ScreenModel.COLOR_DEFAULT
        ? _getDefaultForeground()
        : foreground;
  }

  /// Returns default background color.
  int _getDefaultBackground() {
    return _memory.readUnsigned8(StoryFileHeader.DEFAULT_BACKGROUND).toInt();
  }

  /// Returns default foreground color.
  int _getDefaultForeground() {
    return _memory.readUnsigned8(StoryFileHeader.DEFAULT_FOREGROUND).toInt();
  }

  /// Returns buffer to lower window.
  List<AnnotatedText> getLowerBuffer() {
    return _bottomWindow.getBuffer();
  }
}

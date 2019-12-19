import '../../zvm.dart';

/// BufferedTextWindow is part of the BufferedScreenModel, it represents a
/// buffer for continuously flowing text.
class BufferedTextWindow {
  List<AnnotatedText> _textBuffer;
  TextAnnotation _currentAnnotation = TextAnnotation(
      TextAnnotation.FONT_NORMAL, TextAnnotation.TEXTSTYLE_ROMAN);
  StringBuffer _currentRun;
  bool _isBuffered = false;

  BufferedTextWindow() {
    reset();
  }

  /// Reset the window state.
  void reset() {
    _textBuffer = List<AnnotatedText>();
    _currentRun = StringBuffer();
    _isBuffered = true;
  }

  /// Retrieves the currently active annotation.
  TextAnnotation getCurrentAnnotation() {
    return _currentAnnotation;
  }

  /// Determines whether this window is buffered.
  bool isBuffered() {
    return _isBuffered;
  }

  /// Sets the buffered flag.
  void setBuffered(bool flag) {
    _isBuffered = flag;
  }

  /// Sets the window's current font.
  Char setCurrentFont(Char font) {
    Char previousFont = _currentAnnotation.getFont();
    // no need to start a new run if the font is the same
    if (previousFont != font) {
      _startNewAnnotatedRun(_currentAnnotation.deriveFont(font));
    }
    return previousFont;
  }

  /// Sets the window's current text style.
  void setCurrentTextStyle(int style) {
    _startNewAnnotatedRun(_currentAnnotation.deriveStyle(style));
  }

  /// Sets this window's current background color.
  void setBackground(int color) {
    _startNewAnnotatedRun(_currentAnnotation.deriveBackground(color));
  }

  /// Sets this window's current foreground color.
  void setForeground(int color) {
    _startNewAnnotatedRun(_currentAnnotation.deriveForeground(color));
  }

  /// Retrieves this window's current background color.
  int getBackground() {
    return _currentAnnotation.getBackground();
  }

  /// Retrieves this window's current foreground color.
  int getForeground() {
    return _currentAnnotation.getForeground();
  }

  /// Begins a new text run with the specified annotation.
  void _startNewAnnotatedRun(TextAnnotation annotation) {
    _textBuffer.add(AnnotatedText(_currentAnnotation, _currentRun.toString()));
    _currentRun = StringBuffer();
    _currentAnnotation = annotation;
  }

  /// Appends a character to the current text run.
  void printChar(Char zchar) {
    _currentRun.write(zchar);
  }

  /// Returns this window's buffer.
  List<AnnotatedText> getBuffer() {
    _flush();
    List<AnnotatedText> result = _textBuffer;
    _textBuffer = List<AnnotatedText>();
    return result;
  }

  /// Flushes pending output into
  void _flush() {
    if (_currentRun.length > 0) {
      _textBuffer
          .add(AnnotatedText(_currentAnnotation, _currentRun.toString()));
      _currentRun = StringBuffer();
    }
  }

  @override
  String toString() {
    StringBuffer builder = StringBuffer();
    for (AnnotatedText str in _textBuffer) {
      String line = str.getText().replaceAll('\r', '\n');
      builder.write(line);
    }
    return builder.toString();
  }
}

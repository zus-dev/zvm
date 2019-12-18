import '../../zvm.dart';

/// The class HistoryEntry maintains input entries, there is both an original
/// line and an edited
class HistoryEntry {
  List<Char> original;
  List<Char> edited;

  HistoryEntry() {
    original = List<Char>();
    edited = List<Char>();
  }

  @override
  String toString() {
    List<int> orig = List<int>(original.length);
    List<int> edit = List<int>(edited.length);

    for (int i = 0; i < original.length; i++) {
      orig[i] = original[i].toInt();
    }

    for (int i = 0; i < edited.length; i++) {
      edit[i] = edited[i].toInt();
    }

    final StringBuffer buffer = StringBuffer();
    buffer.write(" (" + String.fromCharCodes(orig));
    buffer.write(", ");
    buffer.write(String.fromCharCodes(edit) + " )");
    return buffer.toString();
  }
}

/// This class implements a store for command lines. The history is a ring
/// buffer stored in an array. This is done to prevent that the history is
/// too big, resulting in a big inefficient thing just to maintain the list
/// of entries.
class CommandHistory {
  static const int _NUM_ENTRIES = 5;
  RingBuffer<HistoryEntry> _history = RingBuffer<HistoryEntry>(_NUM_ENTRIES);
  int _historyIndex = 0;
  int _historySizeAtReset = 0;
  InputLine _inputline;

  CommandHistory(InputLine inputline) {
    _inputline = inputline;
  }

  /// Returns the current history index.
  int getCurrentIndex() {
    return _historyIndex;
  }

  /// Returns true if history char, false otherwise.
  bool isHistoryChar(final Char zsciiChar) {
    return zsciiChar.toInt() == IZsciiEncoding.CURSOR_UP ||
        zsciiChar.toInt() == IZsciiEncoding.CURSOR_DOWN;
  }

  /// Resets the index of the history to the last entry.
  void reset() {
    int historySize = _history.size();
    _historySizeAtReset = historySize;
    _historyIndex = historySize;
    for (int i = 0; i < historySize; i++) {
      final HistoryEntry entry = _history.get(i);
      entry.edited.clear();
      entry.edited.addAll(entry.original);
    }
  }

  /// Adds an input line to the history.
  void addInputLine(final List<Char> inputbuffer) {
    final HistoryEntry entry = HistoryEntry();
    entry.original.addAll(inputbuffer);
    entry.edited.addAll(inputbuffer);

    if (_history.size() > _historySizeAtReset) {
      // If the history was invoked, the last edit line is also included
      // in the input, in this case, replace it with the final input line
      _history.set(_history.size() - 1, entry);
    } else {
      // If the history was not invoked, simply add the input to the end of
      // the history list
      _history.add(entry);
    }
  }

  /// Deletes the current line and replaces it with a history entry, which
  /// is determined depending on the input character.
  int switchHistoryEntry(final List<Char> inputbuffer, final int textbuffer,
      final int pointer, final Char zsciiChar) {
    if (zsciiChar.toInt() == IZsciiEncoding.CURSOR_UP) {
      return _processHistoryUp(inputbuffer, textbuffer, pointer);
    } else {
      return _processHistoryDown(inputbuffer, textbuffer, pointer);
    }
  }

  /// Retrieve previous history entry.
  int _processHistoryUp(
      final List<Char> inputbuffer, final int textbuffer, final int pointer) {
    int newpointer = pointer;
    if (_historyIndex > 0) {
      _storeCurrentInput(inputbuffer);
      _historyIndex--;
      newpointer = _fillInputLineFromHistory(inputbuffer, textbuffer, pointer);
    }
    return newpointer;
  }

  /// Retrieve next entry in the history.
  int _processHistoryDown(
      final List<Char> inputbuffer, final int textbuffer, final int pointer) {
    int newpointer = pointer;
    if (_historyIndex < _history.size() - 1) {
      _storeCurrentInput(inputbuffer);
      _historyIndex++;
      newpointer = _fillInputLineFromHistory(inputbuffer, textbuffer, pointer);
    }
    return newpointer;
  }

  /// Put history text into the input line.
  int _fillInputLineFromHistory(
      final List<Char> inputbuffer, final int textbuffer, final int pointer) {
    int newpointer = _deleteInputLine(inputbuffer, pointer);
    if (_history.size() > _historyIndex) {
      final List<Char> input = _history.get(_historyIndex).edited;
      for (int i = 0; i < input.length; i++) {
        newpointer =
            _inputline.addChar(inputbuffer, textbuffer, newpointer, input[i]);
      }
    }
    return newpointer;
  }

  /// Replaces the current history entry with the content of the input buffer.
  void _storeCurrentInput(final List<Char> inputbuffer) {
    if (_historyIndex < _history.size()) {
      // Replace the edited entry
      _history.get(_historyIndex).edited.clear();
      _history.get(_historyIndex).edited.addAll(inputbuffer);
    } else {
      final HistoryEntry entry = HistoryEntry();
      entry.original.addAll(inputbuffer);
      entry.edited.addAll(inputbuffer);
      _history.add(entry);
    }
  }

  /// Removes the text from the current input line.
  int _deleteInputLine(final List<Char> inputbuffer, final int pointer) {
    final int n = inputbuffer.length;
    int newpointer = pointer;

    for (int i = 0; i < n; i++) {
      newpointer = _inputline.deletePreviousChar(inputbuffer, newpointer);
    }
    return newpointer;
  }
}

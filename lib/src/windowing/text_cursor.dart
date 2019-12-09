/// This defines the operations that can be performed on a text cursor.
abstract class TextCursor {
  /// Returns the current line.
  int getLine();

  /// Returns the current column.
  int getColumn();

  /// Sets the current line. A value <= 0 will set the line to 1.
  void setLine(int line);

  /// Sets the current column. A value <= 0 will set the column to 1.
  void setColumn(int column);

  /// Sets the new position. Values <= 0 will set the corresponding values
  /// to 1.
  void setPosition(int line, int column);
}

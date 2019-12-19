import '../../zvm.dart';

/// The ScreenModelListener interface.
abstract class ScreenModelListener {
  /// Notifies the listener that the screen model was updated.
  void screenModelUpdated(ScreenModel screenModel);

  /// Called when the top window was changed.
  void topWindowUpdated(int cursorx, int cursory, AnnotatedCharacter c);

  /// Called when the screen split value changed.
  void screenSplit(int linesUpperWindow);

  /// Called when a window is erased.
  void windowErased(int window);

  /// Called before the cursor positions is updated.
  void topWindowCursorMoving(int line, int column);
}

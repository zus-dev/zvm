import '../../zvm.dart';

/// Screen model 6 interface.
abstract class ScreenModel6 implements ScreenModel, DrawingArea {

  /// Restricts the mouse pointer to the specified window.
  void setMouseWindow(int window);

  /// Returns the specified window.
  Window6 getWindow(int window);

  /// Returns the currently selected window.
  Window6 getSelectedWindow();

  /// Instructs the screen model to set the width of the current string
  /// to the header.
  void setTextWidthInUnits(List<Char> zchars);

  /// Reads the current mouse data into the specified array.
  void readMouse(int array);
}

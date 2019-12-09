/// An object similar to Dimension
class Resolution {
  int _width = 0;
  int _height = 0;

  Resolution(int width, int height) {
    this._width = width;
    this._height = height;
  }

  /// Returns the width attribute.
  int getWidth() {
    return _width;
  }

  /// Returns the height attribute.
  int getHeight() {
    return _height;
  }

  @override
  String toString() {
    return '${_width}x${_height}';
  }
}

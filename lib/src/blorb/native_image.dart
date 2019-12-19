/// An interface that should be implemented using system-specific classes.
/// Android does not use the java.awt packages, so hide it behind a NativeImage
/// interface.
abstract class NativeImage {
  /// Returns the width.
  int getWidth();

  /// Returns the height.
  int getHeight();
}
import '../../zvm.dart';

/// An abstract ZmppImage interface.
abstract class ZmppImage {
  /// Returns the image resolution for the specified screen width and height.
  Resolution getSize(int screenwidth, int screenheight);
}

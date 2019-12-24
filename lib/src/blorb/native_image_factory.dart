import '../../zvm.dart';

/// User interface specific factory to generate NativeImage instance from
/// a block of data.
abstract class NativeImageFactory {
  /// Creates a NativeImage from an InputStream.
  NativeImage createImage(BytesInputStream inputStream);
}

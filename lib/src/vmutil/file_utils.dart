import 'dart:io';

import '../../zvm.dart';

/// This utility class was introduced to avoid a code smell in data
/// initialization.
/// It offers methods to read data from streams and files.
class FileUtils {
  static final Logger LOG = Logger.getLogger("org.zmpp");

  ///  This class only contains static methods.
  FileUtils._();

  /// Creates a resources object from a Blorb file.
  static Resources createResources(NativeImageFactory imageFactory,
      SoundEffectFactory soundEffectFactory, final File blorbfile) {
    throw UnimplementedError();
  }

  /// Reads an array of bytes from the given input stream.
  static ByteArray readFileBytes(final BytesInputStream inputstream) {
    if (inputstream == null) return null;
    throw UnimplementedError();
  }
}

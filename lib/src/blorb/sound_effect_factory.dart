import '../../zvm.dart';

/// SoundEffectFactory interface.
abstract class SoundEffectFactory {
  /// Creates a SoundEffect from an InputStream.
  SoundEffect createSoundEffect(Chunk aiffChunk);
}

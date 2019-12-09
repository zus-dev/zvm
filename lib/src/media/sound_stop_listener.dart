import '../../zvm.dart';

/// This interface is used to determine when a sound has finished playing.
abstract class SoundStopListener {
  /// The sound has stopped.
  void soundStopped(SoundEffect sound);
}

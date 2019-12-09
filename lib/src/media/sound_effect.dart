import '../../zvm.dart';

/// This class defines the interface to play a Blorb sound.
abstract class SoundEffect {
  /// Plays a sound the specified [number] of times with the [volume].
  void play(int number, int volume);

  /// Stops a sound.
  void stop();

  /// Adds a [l] listener to listen for the sound stop event.
  void addSoundStopListener(SoundStopListener l);

  /// Removes a SoundStopListener.
  void removeSoundStopListener(SoundStopListener l);
}

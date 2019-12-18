/// This interface defines the sound system of the Z-machine preservation
/// project.
abstract class SoundSystem {
  ///  High pitched bleep.
  static const int BLEEP_HIGH = 1;

  ///  Low pitched bleep.
  static const int BLEEP_LOW = 2;

  ///  Prepares a sound.
  static const int EFFECT_PREPARE = 1;

  ///  Starts a sound.
  static const int EFFECT_START = 2;

  ///  Stops a sound.
  static const int EFFECT_STOP = 3;

  ///  Finishes a sound.
  static const int EFFECT_FINISH = 4;

  ///  The maximum value for volume.
  static const int VOLUME_MAX = 0;

  ///  The minimum value for volume.
  static const int VOLUME_MIN = 255;

  ///  Sets the volume to default.
  static const int VOLUME_DEFAULT = -1;

  /// Plays a sound.
  /// Params:
  /// the [number] of the resource, 1 and 2 are bleeps;
  /// [repeats] how often should the sound be played
  /// the interrupt [routine] (can be 0)
  void play(int number, int effect, int volume, int repeats, int routine);

  ///  Resets the sound system.
  void reset();
}

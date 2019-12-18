import '../../zvm.dart';

/// This class implements the SoundSystem interface. The implementation
/// is using a Java 5 thread executor which makes it very easy to
/// assign a control task to each sound which can handle the stopping
/// of a sound easily.
class SoundSystemImpl implements SoundSystem {

  /// The resource database.
  MediaCollection<SoundEffect> _sounds;

  /// The executor service.
  ExecutorService _executor;

  /// The interruptable.
  Interruptable _interruptable;

  /// The current sound task.
  PlaySoundTask _currentTask;

  SoundSystemImpl(final MediaCollection<SoundEffect> sounds) {
    this._sounds = sounds;
    // That's pretty cool:
    // We can control the number of concurrent sounds to be played
    // simultaneously by the size of the thread pool.
    this._executor = Executors.newSingleThreadExecutor();
  }

  /// This method handles the situation if a sound effect is going to
  /// be played and a previous one is not finished.
  void handlePreviousNotFinished() {
    // The default behaviour is to stop the previous sound
    _currentTask.stop();
  }

  @override
  void reset() {
    // no resetting supported
  }

  @override
  void play(final int number, final int effect, final int volume,
      final int repeats, final int routine) {
    SoundEffect sound;
    // @sound_effect 0 3 followed by @sound_effect 0 4 is called
    // by "The Lurking Horror" and hints that all sound effects should
    // be stopped and unloaded. ZMPP's sound system implementation does
    // nothing at the moment (hey, we have plenty of memory and are
    // in a Java environment)
    if (number == 0) return;

    if (_sounds != null) {
      sound = _sounds.getResource(number);
    }
    if (sound == null) {
      print("*BEEP* (playing non-sound)");
    } else {
      if (effect == SoundSystem.EFFECT_START) {
        _startSound(number, sound, volume, repeats, routine);
      } else if (effect == SoundSystem.EFFECT_STOP) {
        _stopSound(number);
      } else if (effect == SoundSystem.EFFECT_PREPARE) {
        _sounds.loadResource(number);
      } else if (effect == SoundSystem.EFFECT_FINISH) {
        _stopSound(number);
        _sounds.unloadResource(number);
      }
    }
  }

  /// Starts the specified sound.
  /// Params:
  /// [number] the sound number
  /// [sound] the sound object
  /// [volume] the volume
  /// [repeats] the number of repeats
  /// [routine] the interrupt routine
  void _startSound(final int number, final SoundEffect sound,
      final int volume, final int repeats, final int routine) {
    if (_currentTask != null && !_currentTask.wasPlayed()) {
      handlePreviousNotFinished();
    }
    _currentTask = (routine <= 0) ?
      PlaySoundTask(number, sound, volume, repeats) :
      PlaySoundTask.interruptable(number, sound, volume, repeats, _interruptable, routine);
    _executor.submit(_currentTask);
  }

  /// Stops the sound with the given number.
  void _stopSound(final int number) {
    // only stop the sound if the numbers match
    if (_currentTask != null && _currentTask.getResourceNumber() == number) {
      _currentTask.stop();
    }
  }
}

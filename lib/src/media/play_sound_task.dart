import '../../zvm.dart';

/// Class to play sounds.
/// TODO: Implement me!
class PlaySoundTask implements Runnable, SoundStopListener {
  // static final Logger _LOG = Logger.getLogger("org.zmpp");
  int _resourceNum = 0;
  SoundEffect _sound;
  int _repeats = 0;
  int _volume = 0;
  bool _played = false;
  Interruptable _interruptable;
  int _routine = 0;
  bool _stopped = false;

  PlaySoundTask(int resourceNum, SoundEffect sound, int volume, int repeats)
      : this.interruptable(resourceNum, sound, volume, repeats, null, 0);

  /// Constructor.
  /// [interruptable] interruptable object (should not be used anymore)
  /// routine the interrupt routine
  /// deprecated interrupts should be implemented differently
  PlaySoundTask.interruptable(int resourceNum, SoundEffect sound, int volume,
      int repeats, Interruptable interruptable, int routine) {
    _resourceNum = resourceNum;
    _sound = sound;
    _repeats = repeats;
    _volume = volume;
    _interruptable = interruptable;
    _routine = routine;
  }

  /// Returns the resource number.
  int getResourceNumber() {
    return _resourceNum;
  }

  @override
  void run() {
    _sound.addSoundStopListener(this);
    _sound.play(_repeats, _volume);

    /*
    synchronized (this) {
      while (!wasPlayed()) {
        try { wait(); } catch (Exception ex) {
          LOG.throwing("PlaySoundTask", "run", ex);
        }
      }
    }
    */
    _sound.removeSoundStopListener(this);
    if (!wasStopped() && _interruptable != null && _routine > 0) {
      _interruptable.setInterruptRoutine(_routine);
    }
  }

  /// Returns the status of the played flag.
  /// TODO: synchronized
  bool wasPlayed() {
    return _played;
  }

  /// Sets the status of the played flag and notifies waiting threads.
  /// TODO: private synchronized
  void setPlayed(final bool flag) {
    _played = flag;
    /*
    notifyAll();
     */
  }

  /**
   * Returns the status of the stopped flag.
   * @return the stopped flag
   */

  /// TODO: private synchronized
  bool wasStopped() {
    return _stopped;
  }

  /// Sets the stopped flag and notifies waiting threads.
  /// @param flag true to stop, false otherwise
  /// TODO: private synchronized
  void setStopped(final bool flag) {
    _stopped = flag;
    /*
    notifyAll();
     */
  }

  /// Stops the sound.
  /// TODO: synchronized
  void stop() {
    if (!wasPlayed()) {
      setStopped(true);
      _sound.stop();
    }
  }

  /// This method waits until the sound was completely played or stopped.
  /// TODO: synchronized
  void waitUntilDone() {
    /*
    while (!wasPlayed()) {
      try { wait(); } catch (Exception ex) {
        LOG.throwing("PlaySoundTask", "waitUntilDone", ex);
      }
    }
    */
  }

  @override
  void soundStopped(final SoundEffect aSound) {
    setPlayed(true);
  }
}

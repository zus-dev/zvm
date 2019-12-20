import '../../zvm.dart';

/// This class implements the Blorb sound collection.
class BlorbSounds extends BlorbMediaCollection<SoundEffect> {
  /// This map implements the database.
  Map<int, SoundEffect> _sounds;

  BlorbSounds(SoundEffectFactory factory, FormChunk formchunk)
      : super(null, factory, formchunk);

  @override
  void clear() {
    super.clear();
    _sounds.clear();
  }

  @override
  void initDatabase() {
    _sounds = Map<int, SoundEffect>();
  }

  @override
  bool isHandledResource(final ByteArray usageId) {
    return usageId[0] == codeOf('S') &&
        usageId[1] == codeOf('n') &&
        usageId[2] == codeOf('d') &&
        usageId[3] == codeOf(' ');
  }

  @override
  SoundEffect getResource(final int resourcenumber) {
    return _sounds[resourcenumber];
  }

  @override
  bool putToDatabase(final Chunk aiffChunk, final int resnum) {
    try {
      _sounds[resnum] = soundEffectFactory.createSoundEffect(aiffChunk);
      return true;
    } catch (ex) {
      // TODO: ex.printStackTrace();
      print("EXCEPTION: ${ex}");
    }
    return false;
  }
}

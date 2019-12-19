import '../../zvm.dart';

/// This class defines an abstract media collection based on the Blorb
/// format.
/// It also defines the common read process for resources. The collection
/// is represented by a database and an index to the database, which maps
/// index numbers to resource numbers. The implementation of the database
/// is left to the sub classes.
abstract class BlorbMediaCollection<T> implements MediaCollection<T> {
  /// The list of resource numbers in the file.
  List<int> _resourceNumbers;

  /// Access to the form chunk.
  FormChunk _formchunk;

  NativeImageFactory imageFactory;
  SoundEffectFactory soundEffectFactory;

  BlorbMediaCollection(NativeImageFactory imageFactory,
      SoundEffectFactory soundEffectFactory, FormChunk formchunk) {
    _resourceNumbers = List<int>();
    this._formchunk = formchunk;
    this.imageFactory = imageFactory;
    this.soundEffectFactory = soundEffectFactory;
    initDatabase();

    // Ridx chunk
    Chunk ridxChunk = formchunk.getSubChunk("RIdx");
    Memory chunkmem = ridxChunk.getMemory();
    int numresources = readUnsigned32(chunkmem, 8);
    int offset = 12;
    ByteArray usage = ByteArray.length(4);

    for (int i = 0; i < numresources; i++) {
      chunkmem.copyBytesToArray(usage, 0, offset, 4);
      if (isHandledResource(usage)) {
        int resnum = readUnsigned32(chunkmem, offset + 4);
        int address = readUnsigned32(chunkmem, offset + 8);
        Chunk chunk = formchunk.getSubChunkByAddress(address);

        if (putToDatabase(chunk, resnum)) {
          _resourceNumbers.add(resnum);
        }
      }
      offset += 12;
    }
  }

  @override
  void clear() {
    _resourceNumbers.clear();
  }

  @override
  int getNumResources() {
    return _resourceNumbers.length;
  }

  /// Returns the resource number at the given index.
  int getResourceNumber(final int index) {
    return _resourceNumbers[index];
  }

  @override
  void loadResource(final int resourcenumber) {
    // intentionally left empty for possible future use
  }

  @override
  void unloadResource(final int resourcenumber) {
    // intentionally left empty for possible future use
  }

  /// Access to the form chunk.
  FormChunk getFormChunk() {
    return _formchunk;
  }

  /// Initialize the database.
  void initDatabase();

  /// This method is invoked by the constructor to indicate if the
  /// class handles the given resource.
  bool isHandledResource(ByteArray usageId);

  /// Puts the media object based on this sub chunk into the database.
  bool putToDatabase(Chunk chunk, int resnum);
}

import 'package:zvm/zvm.dart';

/// This class saves save games as a memory object.
class MemorySaveGameDataStore implements SaveGameDataStore {
  WritableFormChunk _savegame;

  @override
  bool saveFormChunk(WritableFormChunk formchunk) {
    _savegame = formchunk;
    return true;
  }

  @override
  FormChunk retrieveFormChunk() {
    return _savegame;
  }
}
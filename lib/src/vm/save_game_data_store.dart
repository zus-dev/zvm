import '../../zvm.dart';

/// This interface should be implemented by user interfaces that implement
/// game saving functionality. This keeps the game saving facilities independent
/// of implementation details.
abstract class SaveGameDataStore {
  /// Save the given form chunk in Quetzal format to the storage.
  bool saveFormChunk(WritableFormChunk formchunk);

  /// Reads a form chunk from storage. Returns null if not successful.
  FormChunk retrieveFormChunk();
}

import 'chunk.dart';

/// FormChunk is the wrapper chunk for all other chunks.
abstract class FormChunk extends Chunk {
  /// Returns the sub id.
  String getSubId();

  ///  Returns an iterator of chunks contained in this form chunk.
  Iterator<Chunk> getSubChunks();

  /// Returns the chunk with the specified id or null if it does not exist.
  Chunk getSubChunk(String id);

  /// Returns the sub chunk at the specified address or null if it does not exist.
  Chunk getSubChunkByAddress(int address);
}

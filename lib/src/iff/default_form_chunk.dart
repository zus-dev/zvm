import '../base/memory.dart';
import '../base/memory_section.dart';
import '../helpers.dart';
import 'chunk.dart';
import 'default_chunk.dart';
import 'form_chunk.dart';

/// This class implements the FormChunk interface.
class DefaultFormChunk extends DefaultChunk implements FormChunk {
  /// The sub type id.
  ByteArray _subId;

  /// The list of sub chunks.
  List<Chunk> _subChunks;

  DefaultFormChunk(final Memory memory) : super.forRead(memory, 0) {
    _initBaseInfo();
    _readSubChunks();
  }

  /// Initialize the id field.
  void _initBaseInfo() {
    if ("FORM" != getId()) {
      throw IOException("not a valid IFF format");
    }
    // Determine the sub id
    _subId = ByteArray.length(Chunk.CHUNK_ID_LENGTH);
    getMemory().copyBytesToArray(
        _subId, 0, Chunk.CHUNK_HEADER_LENGTH, Chunk.CHUNK_ID_LENGTH);
  }

  /// Read this form chunk's sub chunks.
  void _readSubChunks() {
    _subChunks = List<Chunk>();

    // skip the identifying information
    final int length = getSize();
    int offset = Chunk.CHUNK_HEADER_LENGTH + Chunk.CHUNK_ID_LENGTH;
    int chunkTotalSize = 0;

    while (offset < length) {
      final memarray = MemorySection(getMemory(), offset, length - offset);
      final subchunk = DefaultChunk.forRead(memarray, offset);
      _subChunks.add(subchunk);
      chunkTotalSize = subchunk.getSize() + Chunk.CHUNK_HEADER_LENGTH;

      // Determine if padding is necessary
      chunkTotalSize =
          (chunkTotalSize % 2) == 0 ? chunkTotalSize : chunkTotalSize + 1;
      offset += chunkTotalSize;
    }
  }

  @override
  bool isValid() {
    return "FORM" == getId();
  }

  @override
  String getSubId() {
    return _subId.getString();
  }

  @override
  Iterator<Chunk> getSubChunks() {
    return _subChunks.iterator;
  }

  @override
  Chunk getSubChunk(final String id) {
    for (Chunk chunk in _subChunks) {
      if (chunk.getId() == id) {
        return chunk;
      }
    }
    return null;
  }

  @override
  Chunk getSubChunkByAddress(final int address) {
    for (Chunk chunk in _subChunks) {
      if (chunk.getAddress() == address) {
        return chunk;
      }
    }
    return null;
  }
}

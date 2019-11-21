import '../../zvm.dart';

/// A writable FormChunk class.
class WritableFormChunk implements FormChunk {
  ByteArray _subId;
  static final String _FORM_ID = "FORM";
  List<Chunk> _subChunks;

  WritableFormChunk(final ByteArray subId) {
    this._subId = subId;
    this._subChunks = List<Chunk>();
  }

  /// Adds a sub [chunk].
  void addChunk(final Chunk chunk) {
    _subChunks.add(chunk);
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
      if (chunk.getId() == id) return chunk;
    }
    return null;
  }

  @override
  Chunk getSubChunkByAddress(final int address) {
    // We do not need to implement this
    return null;
  }

  @override
  String getId() {
    return _FORM_ID;
  }

  @override
  int getSize() {
    int size = _subId.length;

    for (Chunk chunk in _subChunks) {
      int chunkSize = chunk.getSize();
      if ((chunkSize % 2) != 0) {
        chunkSize++; // pad if necessary
      }
      size += (Chunk.CHUNK_HEADER_LENGTH + chunkSize);
    }
    return size;
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  Memory getMemory() {
    return DefaultMemory(getBytes());
  }

  /// Returns the data of this chunk.
  ByteArray getBytes() {
    final int datasize = Chunk.CHUNK_HEADER_LENGTH + getSize();
    final ByteArray data = ByteArray.length(datasize);
    final Memory memory = DefaultMemory(data);
    memory.writeUnsigned8(0, Char.of('F'));
    memory.writeUnsigned8(1, Char.of('O'));
    memory.writeUnsigned8(2, Char.of('R'));
    memory.writeUnsigned8(3, Char.of('M'));
    writeUnsigned32(memory, 4, getSize());

    int offset = Chunk.CHUNK_HEADER_LENGTH;

    // Write sub id
    memory.copyBytesFromArray(_subId, 0, offset, _subId.length);
    offset += _subId.length;

    // Write sub chunk data
    for (Chunk chunk in _subChunks) {
      final ByteArray chunkId = ByteArray.fromString(chunk.getId());
      final int chunkSize = chunk.getSize();

      // Write id
      memory.copyBytesFromArray(chunkId, 0, offset, chunkId.length);
      offset += chunkId.length;

      // Write chunk size
      writeUnsigned32(memory, offset, chunkSize);
      offset += 4; // add the size word length

      // Write chunk data
      final Memory chunkMem = chunk.getMemory();
      memory.copyBytesFromMemory(
          chunkMem, Chunk.CHUNK_HEADER_LENGTH, offset, chunkSize);
      offset += chunkSize;
      // Pad if necessary
      if ((chunkSize % 2) != 0) {
        memory.writeUnsigned8(offset++, Char(0));
      }
    }
    return data;
  }

  @override
  int getAddress() {
    return 0;
  }
}

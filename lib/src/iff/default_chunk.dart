import 'package:zvm/src/base/default_memory.dart';
import 'package:zvm/src/base/memory.dart';
import 'package:zvm/src/base/memory_util.dart';
import 'package:zvm/src/helpers.dart';

import 'chunk.dart';

/// This is the default implementation of the Chunk interface.
class DefaultChunk extends Chunk {
  /// The memory access object.
  Memory _memory;

  /// The chunk id.
  ByteArray _id;

  /// The chunk size.
  int _chunkSize = 0;

  /// The start address within the form chunk.
  int _address = 0;

  /// Constructor. Used for reading files.
  DefaultChunk.forRead(final Memory memory, final int address) {
    _memory = memory;
    _address = address;
    _id = ByteArray.length(Chunk.CHUNK_ID_LENGTH);
    memory.copyBytesToArray(_id, 0, 0, Chunk.CHUNK_ID_LENGTH);
    _chunkSize = readUnsigned32(memory, Chunk.CHUNK_ID_LENGTH);
  }

  /// Constructor. Initialize from byte data. This constructor is used
  /// when writing a file, in that case chunks really are separate
  /// memory areas.
  /// The parameter [chunkdata] is the data without header information, number of bytes
  /// needs to be even
  DefaultChunk.forWrite(final ByteArray id, final ByteArray chunkdata) {
    _id = id;
    _chunkSize = chunkdata.length;
    final ByteArray chunkDataWithHeader =
        ByteArray.length(_chunkSize + Chunk.CHUNK_HEADER_LENGTH);
    _memory = DefaultMemory(chunkDataWithHeader);
    _memory.copyBytesFromArray(id, 0, 0, id.length);
    writeUnsigned32(_memory, id.length, _chunkSize);
    _memory.copyBytesFromArray(chunkdata, 0, id.length + 4, chunkdata.length);
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  String getId() {
    return String.fromCharCodes(_id);
  }

  @override
  int getSize() {
    return _chunkSize;
  }

  @override
  Memory getMemory() {
    return _memory;
  }

  @override
  int getAddress() {
    return _address;
  }
}

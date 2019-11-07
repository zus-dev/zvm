import 'package:zvm/src/base/memory.dart';

/// The basic data structure for an IFF file, a chunk.
abstract class Chunk {
  /// The length of an IFF chunk id in bytes.
  static final int CHUNK_ID_LENGTH = 4;

  /// The length of an IFF chunk size word in bytes.
  static final int CHUNK_SIZEWORD_LENGTH = 4;

  /// The chunk header size.
  static final int CHUNK_HEADER_LENGTH =
      CHUNK_ID_LENGTH + CHUNK_SIZEWORD_LENGTH;

  /// Returns this IFF chunk's id. An id is a 4 byte array.
  String getId();

  /// The chunk data size, excluding id and size word.
  int getSize();

  /// Returns true if this is a valid chunk.
  bool isValid();

  /// Returns a memory object to access the chunk.
  Memory getMemory();

  /// Returns the address of the chunk within the global FORM chunk.
  int getAddress();
}

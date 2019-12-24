import '../../zvm.dart';

/// This class encapsulates the a memory object within an input stream.
class MemoryInputStream extends BytesInputStream {

  /// The memory object this stream is based on.
  Memory _memory;

  /// The position in the stream.
  int _position;

  /// Supports a mark.
  int _mark;

  /// The size of the memory.
  int _size;

  MemoryInputStream(final Memory memory, final int offset,
                           final int size) {
    this._memory = memory;
    _position += offset;
    this._size = size;
  }

  @override
  int read() {
    if (_position >= _size) return -1;
    return _memory.readUnsigned8(_position++).toInt();
  }

  @override
  void mark(final int readLimit) { _mark = _position; }

  @override
  void reset() { _position = _mark; }
}

/// This ring buffer implementation is an efficient representation for a
/// dynamic list structure that should have a limited number of entries and
/// where the oldest n entries can be discarded.
/// This kind of container is particularly useful for undo and history buffers.
class RingBuffer<T> {
  List<T> _elements;
  int _bufferstart = 0;
  int _bufferend = 0;
  int _size = 0;

  RingBuffer(int size) {
    _elements = List<T>(size);
  }

  /// Adds an element to the buffer. If the capacity of the buffer is exceeded,
  /// the oldest element is replaced.
  void add(final T elem) {
    if (_size == _elements.length) {
      _bufferstart = (_bufferstart + 1) % _elements.length;
    } else {
      _size++;
    }
    _elements[_bufferend++] = elem;
    _bufferend = _bufferend % _elements.length;
  }

  /// Replaces the element at the specified index with the specified element.
  void set(final int index, final T elem) {
    _elements[_mapIndex(index)] = elem;
  }

  /// Returns the element at the specified index.
  T get(final int index) {
    return _elements[_mapIndex(index)];
  }

  /// Returns the size of this ring buffer.
  int size() {
    return _size;
  }

  /// Removes the object at the specified index.
  T remove(final int index) {
    if (_size > 0) {
      // remember the removed element
      final T elem = get(index);

      // move the following element by one to the front
      for (int i = index; i < (_size - 1); i++) {
        final int idx1 = _mapIndex(i);
        final int idx2 = _mapIndex(i + 1);
        _elements[idx1] = _elements[idx2];
      }
      _size--;
      _bufferend = (_bufferend - 1) % _elements.length;
      if (_bufferend < 0) _bufferend = _elements.length + _bufferend;
      return elem;
    }
    return null;
  }

  /// Maps a container index to a ring buffer index.
  int _mapIndex(final int index) {
    return (_bufferstart + index) % _elements.length;
  }

  @override
  String toString() {
    final buffer = StringBuffer("{ ");
    for (int i = 0; i < size(); i++) {
      if (i > 0) {
        buffer.write(", ");
      }
      buffer.write(get(i));
    }
    buffer.write(" }");
    return buffer.toString();
  }
}

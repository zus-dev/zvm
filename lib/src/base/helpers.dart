import 'dart:collection';

import 'dart:typed_data';

class Char {
  int code = 0;

  Char([code = 0]) {
    // TODO: code & 0xffff
    assert(code >= 0 && code <= 65535);
    this.code = code;
  }

  int operator &(int other) => this.code & other;

  bool operator ==(other) => other is Char && this.code == other.code;
}

class ByteArray extends ListBase<int> {
  final List<int> delegate;

  ByteArray(this.delegate) : assert(delegate != null);

  /// Creates a [ByteArray] of the specified [length] (in elements), all of
  /// whose elements are initially zero.
  ByteArray.length(int length) : delegate = Uint8List(length);

  int get length => delegate.length;

  set length(int length) {
    delegate.length = length;
  }

  void operator []=(int index, int value) {
    delegate[index] = value;
  }

  int operator [](int index) => delegate[index];

  void add(int value) => delegate.add(value);

  void addAll(Iterable<int> all) => delegate.addAll(all);
}

int byte(int value) {
  assert(value.bitLength <= 8);
  // TODO: Check and trim to the byte? e.g. value & 0xff
  return value;
}

void arraycopy(List src, int srcPos, List dest, int destPos, int length) {
  dest.setRange(destPos, length + destPos, src, srcPos);
}

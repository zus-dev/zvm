import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

/// Unsigned 16 bit value
class Char {
  static final int MIN_VALUE = 0;
  static final int MAX_VALUE = 0xffff;

  int _value = 0;

  Char([int value = 0]) {
    // TODO: code & 0xffff
    // MemoryUtil.toUnsigned16
    assert(value >= MIN_VALUE && value <= MAX_VALUE);
    this._value = value;
  }

  int operator &(int other) => this._value & other;

  bool operator ==(other) => other is Char && this._value == other._value;

  int get code => _value;

  int toInt() => _value;
}

class Byte {
  static final int MIN_VALUE = -128;
  static final int MAX_VALUE = 127;
}

/// Signed 16 bit value
class Short {
  static final int MIN_VALUE = -pow(2, 15);
  static final int MAX_VALUE = pow(2, 15) - 1;
  int _value = 0;

  Short([value = 0]) {
    // TODO: keep in range code & 0xffff
    assert(value >= MIN_VALUE && value <= MAX_VALUE);
    _value = value;
  }

  bool operator >=(int other) => _value >= other;

  bool operator <=(int other) => _value <= other;

  int toInt() => _value;
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

  void operator []=(int index, int value) => delegate[index] = value;

  int operator [](int index) => delegate[index];

  void add(int value) => delegate.add(value);

  void addAll(Iterable<int> all) => delegate.addAll(all);
}

int byte(int value) {
  assert(value.bitLength <= 8 && value >= Byte.MIN_VALUE);
  assert((value | 0xff) ^ 0xff == 0);
  // TODO: Check and trim to the byte? e.g. value & 0xff
  return value;
}

void arraycopy(List src, int srcPos, List dest, int destPos, int length) {
  dest.setRange(destPos, length + destPos, src, srcPos);
}

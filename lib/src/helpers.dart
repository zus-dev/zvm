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

  Char.of(String character) {
    var value = codeOf(character);
    assert(value >= MIN_VALUE && value <= MAX_VALUE);
    this._value = value;
  }

  Char.at(String str, int index) {
    var value = str.codeUnitAt(index);
    assert(value >= MIN_VALUE && value <= MAX_VALUE);
    this._value = value;
  }

  // TODO: Remove this operator
  int operator &(int other) => this._value & other;

  bool operator ==(other) => other is Char && this._value == other._value;

  int get code => _value;

  int toInt() => _value;

  @override
  String toString() => String.fromCharCode(code);

  Char toLowerCase() => Char.of(toString().toLowerCase());
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

  int toInt() => _value;
}

class ByteArray extends ListBase<int> {
  final List<int> delegate;

  ByteArray(this.delegate) : assert(delegate != null);

  /// Creates a [ByteArray] of the specified [length] (in elements), all of
  /// whose elements are initially zero.
  ByteArray.length(int length) : delegate = Uint8List(length);

  ByteArray.fromString(String str) : delegate = _getBytes(str);

  @override
  int get length => delegate.length;

  @override
  set length(int length) {
    delegate.length = length;
  }

  @override
  void operator []=(int index, int value) => delegate[index] = value;

  @override
  int operator [](int index) => delegate[index];

  @override
  void add(int value) => delegate.add(value);

  @override
  void addAll(Iterable<int> all) => delegate.addAll(all);

  String getString() {
    // must be symmetrical to ByteArray.fromString
    return String.fromCharCodes(delegate);
  }

  static List<int> _getBytes(String str) {
    // 1:
    // List<int> bytes = utf8.encode('Hello world');
    // String bar = utf8.decode(bytes);
    // 2:
    // String foo = 'Hello world';
    // List<int> bytes = foo.codeUnits;
    // 3:
    // Iterable<int> bytes = foo.runes;
    // print(bytes.toList());
    return Uint8List.fromList(str.codeUnits);
  }
}

int byte(int value) {
  assert(value.bitLength <= 8 && value >= Byte.MIN_VALUE);
  assert((value | 0xff) ^ 0xff == 0);
  // TODO: Check and trim to the byte? e.g. value & 0xff
  return value;
}

int codeOf(String character) {
  assert(character.length == 1);
  return character.codeUnitAt(0);
}

void arraycopy(List src, int srcPos, List dest, int destPos, int length) {
  dest.setRange(destPos, length + destPos, src, srcPos);
}

String toHexStr(int value, [int width = 2]) {
  if (value == null) {
    return 'null';
  }

  return value.toRadixString(16).padLeft(width, '0');
}

int zeroFillRightShift(int n, int amount) {
  // https://stackoverflow.com/questions/11746504/how-to-do-zero-fill-right-shift-in-dart
  // Zero-fill right shift requires a specific integer size.
  // Since integers in Dart are of arbitrary precision the '>>>' operator doesn't make sense there.
  // The easiest way to emulate a zero-fill right shift is to bit-and the number first.
  // Example:
  // (foo & 0xFFFF) >> 2 // 16 bit zero-fill shift
  // (foo & 0xFFFFFFFF) >> 2 // 32 bit shift.
  //
  // That assumes you have 32-bit unsigned integers and that's ok if you do have.
  return (n & 0xffffffff) >> amount;
}

class IOException implements Exception {
  String cause;

  IOException(this.cause);

  String getMessage() => cause;
}

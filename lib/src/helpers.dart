import 'dart:collection';
import 'dart:io';
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

  // TODO: Add an extension to the String class.
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

  bool isWhitespace() {
    return _isWhitespace(_value);
  }

  /// Returns `true` if [rune] represents a whitespace character.
  ///
  /// The definition of whitespace matches that used in [String.trim] which is
  /// based on Unicode 6.2. This maybe be a different set of characters than the
  /// environment's [RegExp] definition for whitespace, which is given by the
  /// ECMAScript standard: http://ecma-international.org/ecma-262/5.1/#sec-15.10
  ///
  /// Source:
  /// https://github.com/google/quiver-dart/blob/master/lib/strings.dart
  static bool _isWhitespace(int rune) =>
      (rune >= 0x0009 && rune <= 0x000D) ||
      rune == 0x0020 ||
      rune == 0x0085 ||
      rune == 0x00A0 ||
      rune == 0x1680 ||
      rune == 0x180E ||
      (rune >= 0x2000 && rune <= 0x200A) ||
      rune == 0x2028 ||
      rune == 0x2029 ||
      rune == 0x202F ||
      rune == 0x205F ||
      rune == 0x3000 ||
      rune == 0xFEFF;
}

class FilledList {
  static List<Char> ofChar(int length) {
    return List<Char>.generate(length, (_) => Char(0));
  }

  static List<int> ofInt(int length) {
    return List<int>.generate(length, (_) => 0);
  }
}

class Byte {
  static final int MIN_VALUE = -128;
  static final int MAX_VALUE = 127;
}

/// Signed 16 bit value
class Short {
  static final int MIN_VALUE = -pow(2, 15);
  static final int MAX_VALUE = pow(2, 15) - 1;
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

String toHexStrPad4Space(int value) {
  return toHexStr(value, width: 4, padding: ' ');
}

/// $%04x
String toS04x(int value) {
  return "\$" + toHexStr(value, width: 4, padding: '0');
}

/// $%02x
String toS02x(int value) {
  return "\$" + toHexStr(value, width: 2, padding: '0');
}

/// L%02x
String toL02x(int value) {
  return toHex02x("L", value);
}

/// G%02x
String toG02x(int value) {
  return toHex02x("G", value);
}

String toHex02x(String prefix, int value) {
  return prefix + toHexStr(value, width: 2, padding: '0');
}

String toHexStr(int value, {int width = 2, String padding = '0'}) {
  if (value == null) {
    return 'null';
  }

  return value.toRadixString(16).padLeft(width, padding);
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

abstract class Closeable {
  /// Closes this object and releases any resources associated with it.
  void close();
}

// Source:
// https://github.com/dart-lang/sdk/issues/32486
void using<T extends Closeable>(T resource, void Function(T) fn) {
  try {
    fn(resource);
  } finally {
    resource.close();
  }
}

class Logger {
  String _name;

  Logger.getLogger(String name) {
    _name = name;
  }

  void severe(String message) {
    print("SEVR: ${_name}: $message");
  }

  void warning(String message) {
    print("WARN: ${_name}: $message");
  }

  void info(String message) {
    print("INFO: ${_name}: $message");
  }

  void throwing(String className, String methodName, Object err) {
    print("TROW: ${_name}: ${className}: ${methodName}: ${err}");
  }
}

class IOException implements Exception {
  String cause;

  IOException(this.cause);

  String getMessage() => cause;
}

class IllegalArgumentException implements Exception {
  String cause;

  IllegalArgumentException(this.cause);

  String getMessage() => cause;
}

class ArrayIndexOutOfBoundsException implements Exception {
  String cause;

  ArrayIndexOutOfBoundsException(this.cause);

  String getMessage() => cause;
}

class IllegalStateException implements Exception {
  String cause;

  IllegalStateException(this.cause);

  String getMessage() => cause;
}

class UnsupportedOperationException implements Exception {
  String cause;

  UnsupportedOperationException(this.cause);

  String getMessage() => cause;
}

/// Serializable interface
abstract class Serializable {}

/// The Runnable interface should be implemented by any class whose instances
/// are intended to be executed by a thread. The class must define a method
/// of no arguments called run.
abstract class Runnable {
  void run();
}

/// TODO: Implement me!
/// https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ExecutorService.html
class ExecutorService {
  void submit(Runnable task) {
    print("NEW RUNNABLE TASK HAS BEEN SUBMITTED!");
  }
}

/// TODO: Implement me!
/// https://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ExecutorService.html
class Executors {
  static ExecutorService newSingleThreadExecutor() {
    return ExecutorService();
  }
}

// TODO: Delete me!
class Attributes {}

// TODO: SAX XML parser
abstract class DefaultHandler {
  void startElement(final String uri, final String localName,
      final String qname, final Attributes attributes);

  void endElement(final String uri, final String localName, final String qname);

  void characters(final List<Char> ch, final int start, final int length);
}

class SAXParser {
  void parse(Object meminput, Object handler) {
    // TODO: implement me!
    throw UnimplementedError();
  }
}

class SAXParserFactory {
  SAXParserFactory.newInstance();

  SAXParser newSAXParser() {
    return SAXParser();
  }
}

/// This abstract class is the superclass of all classes representing an input stream of bytes.
/// Applications that need to define a subclass of InputStream must always provide a method that returns the next byte of input.
/// https://docs.oracle.com/javase/7/docs/api/java/io/InputStream.html
/// TODO: Fix me!
abstract class BytesInputStream {
  int read();

  void mark(final int readLimit);

  void reset();

  ByteArray readAsBytesSync() {
    throw UnimplementedError();
  }
}

class FileBytesInputStream extends BytesInputStream {
  String fileName;

  FileBytesInputStream(this.fileName);

  @override
  ByteArray readAsBytesSync() {
    final file = File(fileName);
    return ByteArray(file.readAsBytesSync());
  }

  @override
  void mark(int readLimit) {
    // TODO: implement mark
  }

  @override
  int read() {
    // TODO: implement read
    return null;
  }

  @override
  void reset() {
    // TODO: implement reset
  }
}

class URL {
  BytesInputStream openStream() {
    throw UnimplementedError();
  }
}

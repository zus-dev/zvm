import '../../zvm.dart';

/// This class defines an output stream for transcript output (Stream 2).
class TranscriptOutputStream implements OutputStream {
  static final Logger LOG = Logger.getLogger("org.zmpp");
  IOSystem _iosys;
  IZsciiEncoding _encoding;
  bool _enabled = false;

  TranscriptOutputStream(final IOSystem iosys, final IZsciiEncoding encoding) {
    _iosys = iosys;
    _encoding = encoding;
  }

  @override
  void print(final Char zsciiChar) {
    throw UnimplementedError();
  }

  @override
  void select(final bool flag) {
    _enabled = flag;
  }

  @override
  bool isSelected() {
    return _enabled;
  }

  @override
  void flush() {
    throw UnimplementedError();
  }

  @override
  void close() {
    throw UnimplementedError();
  }
}

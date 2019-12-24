import '../../zvm.dart';

class FileInputStream implements InputStream {
  static final Logger _LOG = Logger.getLogger("org.zmpp");
  IOSystem _iosys;
  IZsciiEncoding _encoding;

  FileInputStream(IOSystem iosys, IZsciiEncoding encoding) {
    _iosys = iosys;
    _encoding = encoding;
  }

  @override
  String readLine() {
    throw UnimplementedError();
  }

  @override
  void close() {
    throw UnimplementedError();
  }
}

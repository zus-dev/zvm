import '../../zvm.dart';

/// This class defines an output stream for transcript output (Stream 2).
class TranscriptOutputStream implements OutputStream {
  static final Logger LOG = Logger.getLogger("org.zmpp");
  IOSystem _iosys;
  BufferedWriter _output;
  Writer _transcriptWriter;
  bool _enabled = false;
  StringBuffer _linebuffer;
  IZsciiEncoding _encoding;
  bool _initialized = false;

  TranscriptOutputStream(final IOSystem iosys, final IZsciiEncoding encoding) {
    _iosys = iosys;
    _encoding = encoding;
    _linebuffer = StringBuffer();
  }

  /// Initializes the output file.
  void _initFile() {
    if (!_initialized && _transcriptWriter == null) {
      _transcriptWriter = _iosys.getTranscriptWriter();
      if (_transcriptWriter != null) {
        _output = BufferedWriter(_transcriptWriter);
      }
      _initialized = true;
    }
  }

  @override
  void print(final Char zsciiChar) {
    _initFile();
    if (_output != null) {
      if (zsciiChar.toInt() == IZsciiEncoding.NEWLINE) {
        flush();
      } else if (zsciiChar.toInt() == IZsciiEncoding.DELETE) {
        // TODO: implement deleteCharAt in more efficient way
        // _linebuffer.deleteCharAt(_linebuffer.length() - 1);
        final str = _linebuffer.toString().substring(0, _linebuffer.length - 1);
        _linebuffer = StringBuffer(str);
      } else {
        _linebuffer.write(_encoding.getUnicodeChar(zsciiChar));
      }
      flush();
    }
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
    try {
      if (_output != null) {
        _output.write(_linebuffer.toString());
        _linebuffer = StringBuffer();
      }
    } catch (ex) {
      LOG.throwing("TranscriptOutputStream", "flush", ex);
    }
  }

  @override
  void close() {
    if (_output != null) {
      try {
        _output.close();
        _output = null;
      } catch (ex) {
        LOG.throwing("TranscriptOutputStream", "close", ex);
      }
    }

    if (_transcriptWriter != null) {
      try {
        _transcriptWriter.close();
        _transcriptWriter = null;
      } catch (ex) {
        LOG.throwing("TranscriptOutputStream", "close", ex);
      }
    }
    _initialized = false;
  }
}

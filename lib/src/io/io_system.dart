// TODO: java.io.BufferedWriter extends java.io.Writer
class BufferedWriter extends Writer {
  Writer _writer;

  BufferedWriter(Writer writer) {
    _writer = writer;
  }
}

// TODO: java.io.Writer
abstract class Writer {
  void write(String content) {
    throw UnimplementedError();
  }

  void close() {
    throw UnimplementedError();
  }
}

// TODO: java.io.Reader
abstract class Reader {}

/// Access the file system to implement the file based streams.
abstract class IOSystem {
  /// Returns the transcript output writer.
  Writer getTranscriptWriter();

  /// Returns the reader for input stream.
  Reader getInputStreamReader();
}

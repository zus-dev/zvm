abstract class Writer {
  // TODO: java.io.Writer
}

abstract class Reader {
  // TODO: java.io.Reader
}

/// Access the file system to implement the file based streams.
abstract class IOSystem {
  /// Returns the transcript output writer.
  Writer getTranscriptWriter();

  /// Returns the reader for input stream.
  Reader getInputStreamReader();
}

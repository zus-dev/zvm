/// This interface defines a Z-machine input stream.
abstract class InputStream {
  /// Reads the next available line of ZSCII characters from the stream.
  /// This is somewhat immediate.
  String readLine();

  /// Release underlying resources.
  void close();
}

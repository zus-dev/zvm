import '../../zvm.dart';

/// Input interface implementation.
class InputImpl implements Input, Closeable {
  List<InputStream> _inputStream = List<InputStream>(2);
  int _selectedInputStreamIndex = 0;

  @override
  void close() {
    if (_inputStream != null) {
      for (int i = 0; i < _inputStream.length; i++) {
        if (_inputStream[i] != null) {
          _inputStream[i].close();
        }
      }
    }
  }

  /// Sets an input stream to the specified number.
  void setInputStream(final int streamnumber, final InputStream stream) {
    _inputStream[streamnumber] = stream;
  }

  @override
  void selectInputStream(final int streamnumber) {
    _selectedInputStreamIndex = streamnumber;
  }

  @override
  InputStream getSelectedInputStream() {
    return _inputStream[_selectedInputStreamIndex];
  }
}

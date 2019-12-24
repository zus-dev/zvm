/// A simple exception to report an invalid story file.
class InvalidStoryException implements Exception {
  String cause;

  InvalidStoryException([this.cause]);

  String getMessage() => cause;
}

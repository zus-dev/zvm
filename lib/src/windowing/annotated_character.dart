import '../../zvm.dart';

/// An annotated character for the text grid. This is supposed to save a little
/// memory as opposed to AnnotatedText.
class AnnotatedCharacter implements Serializable {
  Char _character = Char(0);
  TextAnnotation _annotation;
  
  /// Constructor.
  AnnotatedCharacter(TextAnnotation annotation, Char c) {
    this._annotation = annotation;
    this._character = c;
  }
  
  /// Returns the annotation.
  TextAnnotation getAnnotation() { return _annotation; }
  
  /// Returns the character.
  Char getCharacter() { return _character; }
}

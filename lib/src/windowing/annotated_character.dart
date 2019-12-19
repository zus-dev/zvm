import '../../zvm.dart';

/// An annotated character for the text grid. This is supposed to save a little
/// memory as opposed to AnnotatedText.
class AnnotatedCharacter {
  Char character = Char(0);
  TextAnnotation annotation;
  
  /// Constructor.
  AnnotatedCharacter(TextAnnotation annotation, Char c) {
    this.annotation = annotation;
    this.character = c;
  }
  
  /// Returns the annotation.
  TextAnnotation getAnnotation() { return annotation; }
  
  /// Returns the character.
  Char getCharacter() { return character; }
}

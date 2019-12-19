import '../../zvm.dart';

/// An annotated text.
class AnnotatedText implements Serializable {
  TextAnnotation _annotation;
  String _text;

  AnnotatedText(TextAnnotation annotation, String text) {
    _annotation = annotation;
    _text = text;
  }

  AnnotatedText.fromString(String text)
      : this(
            TextAnnotation(
                TextAnnotation.FONT_NORMAL, TextAnnotation.TEXTSTYLE_ROMAN),
            text);

  /// Returns the annotation.
  TextAnnotation getAnnotation() {
    return _annotation;
  }

  /// Returns the text.
  String getText() {
    return _text;
  }
}

import '../../zvm.dart';

/// An annotated text.
class AnnotatedText implements Serializable {
  TextAnnotation annotation;
  String text;

  AnnotatedText(TextAnnotation annotation, String text) {
    this.annotation = annotation;
    this.text = text;
  }

  AnnotatedText.fromString(String text)
      : this(
            TextAnnotation(
                TextAnnotation.FONT_NORMAL, TextAnnotation.TEXTSTYLE_ROMAN),
            text);

  /// Returns the annotation.
  TextAnnotation getAnnotation() {
    return annotation;
  }

  /// Returns the text.
  String getText() {
    return text;
  }
}

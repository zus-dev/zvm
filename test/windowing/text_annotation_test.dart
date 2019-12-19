import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  test('CreateFull', () {
    TextAnnotation annot = TextAnnotation(
        ScreenModel.FONT_NORMAL,
        ScreenModel.TEXTSTYLE_ITALIC,
        ScreenModel.COLOR_BLUE,
        ScreenModel.COLOR_YELLOW);
    assertEquals(ScreenModel.FONT_NORMAL, annot.getFont());
  });
}

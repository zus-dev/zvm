import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

class TestInputLine extends InputLine {
  @override
  int deletePreviousChar(List<Char> inputbuffer, int pointer) {
    inputbuffer.remove(inputbuffer.length - 1);
    return pointer - 1;
  }

  @override
  int addChar(List<Char> inputbuffer,
      int textbuffer, int pointer, Char zchar) {
    inputbuffer.add(zchar);
    return pointer + 1;
  }
}

void main() {
  CommandHistory history;

  setUp(() {
    history = CommandHistory(TestInputLine());
  });

  /**
   * Test if the reset will set the index to size(), which is 0.
   */
  test('ResetInitial', () {
    history.reset();
    assertEquals(0, history.getCurrentIndex());
    List<Char> inputline = List<Char>();
    history.addInputLine(inputline);
    history.reset();
    assertEquals(1, history.getCurrentIndex());
  });

  test('IsHistoryChar', () {
    assertTrue(history.isHistoryChar(Char(IZsciiEncoding.CURSOR_UP)));
    assertTrue(history.isHistoryChar(Char(IZsciiEncoding.CURSOR_DOWN)));
    assertFalse(history.isHistoryChar(Char(IZsciiEncoding.CURSOR_LEFT)));
    assertFalse(history.isHistoryChar(Char.of('a')));
  });
}

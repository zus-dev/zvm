import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  MockMemory memory;
  AlphabetTable alphabetTable;

  setUp(() {
    memory = MockMemory();
    alphabetTable = CustomAlphabetTable(memory, 1000);
  });

  test('GetA0Char', () {
    when(memory.readUnsigned8(1000)).thenReturn(Char(3));
    when(memory.readUnsigned8(1006)).thenReturn(Char(2));

    assertEquals(3, alphabetTable.getA0Char(6));
    assertEquals(2, alphabetTable.getA0Char(12));
    assertEquals(' ', alphabetTable.getA0Char(0));
  });

  test('GetA1Char', () {
    when(memory.readUnsigned8(1026)).thenReturn(Char(3));
    when(memory.readUnsigned8(1032)).thenReturn(Char(2));

    assertEquals(3, alphabetTable.getA1Char(6));
    assertEquals(2, alphabetTable.getA1Char(12));
    assertEquals(' ', alphabetTable.getA1Char(0));
  });

  test('GetA2Char', () {
    when(memory.readUnsigned8(1052)).thenReturn(Char(3));
    when(memory.readUnsigned8(1058)).thenReturn(Char(2));

    assertEquals(3, alphabetTable.getA2Char(6));
    assertEquals(2, alphabetTable.getA2Char(12));
    assertEquals(' ', alphabetTable.getA2Char(0));
    assertEquals('\n', alphabetTable.getA2Char(7));
  });

  test('A0IndexOfNotFound', () {
    for (int i = 0; i < 26; i++) {
      when(memory.readUnsigned8(1000 + i)).thenReturn(Char.of('a'));
    }

    assertEquals(-1, alphabetTable.getA0CharCode(Char.of('@')));
  });

  test('A1IndexOfNotFound', () {
    for (int i = 0; i < 26; i++) {
      when(memory.readUnsigned8(1026 + i)).thenReturn(Char.of('a'));
    }

    assertEquals(-1, alphabetTable.getA1CharCode(Char.of('@')));
  });

  test('A2IndexOfNotFound', () {
    // char 7 is directly returned !!
    when(memory.readUnsigned8(1052)).thenReturn(Char.of('a'));
    for (int i = 2; i < 26; i++) {
      when(memory.readUnsigned8(1052 + i)).thenReturn(Char.of('a'));
    }

    assertEquals(-1, alphabetTable.getA2CharCode(Char.of('@')));
  });
}

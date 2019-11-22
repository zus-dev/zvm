import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  const ADDRESS = 4711;
  MockMemory memory;
  CustomAccentTable accentTable;
  CustomAccentTable noAccentTable;

  setUp(() {
    memory = MockMemory();
    accentTable = CustomAccentTable(memory, ADDRESS);
    noAccentTable = CustomAccentTable(memory, 0);
  });

  test('GetLengthNoTable', () {
    assertEquals(0, noAccentTable.getLength());
  });

  test('GetLength', () {
    when(memory.readUnsigned8(ADDRESS)).thenReturn(Char(3));
    assertEquals(3, accentTable.getLength());
  });

  test('GetAccentNoTable', () {
    assertEquals('?', noAccentTable.getAccent(42));
  });

  test('GetAccent', () {
    when(memory.readUnsigned16(ADDRESS + 7)).thenReturn(Char.of('^'));
    assertEquals('^', accentTable.getAccent(3));
  });

  test('GetIndexOfLowerCase', () {
    // length
    when(memory.readUnsigned8(ADDRESS)).thenReturn(Char(80));
    // reference character
    when(memory.readUnsigned16(ADDRESS + 2 * 6 + 1)).thenReturn(Char.of('B'));
    when(memory.readUnsigned16(ADDRESS + 1)).thenReturn(Char.of('a'));
    when(memory.readUnsigned16(ADDRESS + 2 + 1)).thenReturn(Char.of('b'));
    assertEquals(1, accentTable.getIndexOfLowerCase(6));
    verify(memory.readUnsigned8(ADDRESS)).called(1);
  });

  test('GetIndexOfLowerCaseNotFound', () {
    // length
    when(memory.readUnsigned8(ADDRESS)).thenReturn(Char(2));
    // reference character
    when(memory.readUnsigned16(ADDRESS + 2 * 1 + 1)).thenReturn(Char.of('^'));
    when(memory.readUnsigned16(ADDRESS + 1)).thenReturn(Char.of('a'));
    assertEquals(1, accentTable.getIndexOfLowerCase(1));
    verify(memory.readUnsigned8(ADDRESS)).called(1);
    verify(memory.readUnsigned16(ADDRESS + 2 * 1 + 1)).called(2);
  });
}

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  MockMachine machine;
  MemoryOutputStream output;

  setUp(() {
    machine = MockMachine();
    output = MemoryOutputStream(machine);
  });

  test('PrintVersion5', () {
    when(machine.getVersion()).thenReturn(5);

    // Selection has to be performed prior to printing - ALWAYS !!!
    output.selectWithTable(4711, 0);
    output.print(Char(65));
    output.select(false);

    verify(machine.getVersion()).called(1);
    verify(machine.writeUnsigned8(4713, Char(65))).called(1);
    verify(machine.writeUnsigned16(4711, Char(1))).called(1);
  });

  test('IsSelected', () {
    output.selectWithTable(4711, 0);
    assertTrue(output.isSelected());
  });

  test('UnusedMethods', () {
    output.flush();
    output.close();
  });

  test('SelectMaxNesting', () {
    for (int i = 0; i < 17; i++) {
      output.selectWithTable(4710 + 10 * i, 0);
    }

    verify(machine.halt("maximum nesting depth (16) for stream 3 exceeded"))
        .called(1);
  });
}

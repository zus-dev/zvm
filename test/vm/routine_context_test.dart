import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  RoutineContext context;

  setUp(() {
    context = RoutineContext(2);
  });

  test('Create', () {
    assertEquals(2, context.getNumLocalVariables());
  });

  test('Setters', () {
    context.setLocalVariable(Char(0), Char(72));
    assertEquals(72, context.getLocalVariable(Char(0)));
    context.setLocalVariable(Char(1), Char(76));
    assertEquals(76, context.getLocalVariable(Char(1)));

    expect(() => context.setLocalVariable(Char(2), Char(815)),
        throwsA(TypeMatcher<RangeError>()));

    context.setReturnAddress(0x4711);
    assertEquals(0x4711, context.getReturnAddress());
    context.setReturnVariable(Char(0x13));
    assertEquals(0x13, context.getReturnVariable());
    context.setInvocationStackPointer(Char(1234));
    assertEquals(1234, context.getInvocationStackPointer());
    context.setNumArguments(3);
    assertEquals(3, context.getNumArguments());
  });
}

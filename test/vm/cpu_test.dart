import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  MockMachine machine;
  CpuImpl cpu;
  RoutineContext routineInfo;

  setUp(() {
    machine = MockMachine();
    routineInfo = RoutineContext(3);

    when(machine.getVersion()).thenReturn(5);
    when(machine.readUnsigned16(StoryFileHeader.PROGRAM_START))
        .thenReturn(Char(1000));
    when(machine.readUnsigned16(StoryFileHeader.GLOBALS))
        .thenReturn(Char(5000));

    cpu = CpuImpl(machine);
    cpu.reset();
  });

  test('InitialState', () {
    assertEquals(1000, cpu.getPC());
    assertEquals(0, cpu.getSP());
    assertEquals(0, cpu.getRoutineStackPointer());
  });

  test('SetProgramCounter', () {
    cpu.setPC(1234);
    assertEquals(1234, cpu.getPC());
  });

  test('IncrementProgramCounter', () {
    cpu.setPC(1000);
    cpu.incrementPC(0);
    assertEquals(1000, cpu.getPC());

    cpu.setPC(1000);
    cpu.incrementPC(123);
    assertEquals(1123, cpu.getPC());

    cpu.setPC(1000);
    cpu.incrementPC(-32);
    assertEquals(968, cpu.getPC());
  });

  test('GetVariableType', () {
    assertEquals(VariableType.STACK, CpuImpl.getVariableType(0));
    assertEquals(VariableType.LOCAL, CpuImpl.getVariableType(0x01));
    assertEquals(VariableType.LOCAL, CpuImpl.getVariableType(0x0f));
    assertEquals(VariableType.GLOBAL, CpuImpl.getVariableType(0x10));
    assertEquals(VariableType.GLOBAL, CpuImpl.getVariableType(0xff));
  });

  test('VariableTypes', () {
    assertTrue(VariableType.STACK != VariableType.LOCAL);
    assertTrue(VariableType.LOCAL != VariableType.GLOBAL);
    assertTrue(VariableType.STACK != VariableType.GLOBAL);
  });

  test('GetStackElement', () {
    cpu.setVariable(Char(0), Char(1));
    cpu.setVariable(Char(0), Char(2));
    cpu.setVariable(Char(0), Char(3));
    assertEquals(2, cpu.getStackElement(1));
  });

  test('SetRoutineContexts', () {
    List<RoutineContext> contexts = List<RoutineContext>();
    RoutineContext routineContext = RoutineContext(2);
    contexts.add(routineContext);
    cpu.setRoutineContexts(contexts);

    List<RoutineContext> currentContexts = cpu.getRoutineContexts();
    assertEquals(1, currentContexts.length);
    assertNotSame(contexts, currentContexts);
    assertEquals(routineContext, cpu.getCurrentRoutineContext());
  });

  test('GetCurrentRoutineContext', () {
    // Initialize the routine context
    RoutineContext routineContext = RoutineContext(0);

    // simulate a call
    cpu.pushRoutineContext(routineContext);

    // We can call this three times and it will stay the same
    assertEquals(routineContext, cpu.getCurrentRoutineContext());
    assertEquals(routineContext, cpu.getCurrentRoutineContext());
    assertEquals(routineContext, cpu.getCurrentRoutineContext());
  });

  test('GetSetStackTopElement', () {
    // initialize stack
    cpu.setVariable(Char(0), Char(0));
    cpu.setStackTop(Char(42));
    assertEquals(1, cpu.getSP());
    assertEquals(42, cpu.getStackTop());
    assertEquals(1, cpu.getSP());
  });

  test('GetStackTopElementStackEmpty', () {
    expect(
        () => cpu.getStackTop(),
        throwsA((e) =>
            e is ArrayIndexOutOfBoundsException && e.getMessage().isNotEmpty));
  });

  test('GetVariableStackNonEmptyNoRoutineContext', () {
    // Write something to the stack now
    cpu.setVariable(Char(0), Char(4711));
    int oldStackPointer = cpu.getSP().toInt();
    int value = cpu.getVariable(Char(0)).toInt();
    assertEquals(oldStackPointer - 1, cpu.getSP());
    assertEquals(value, 4711);
  });

  test('GetVariableStackNonEmptyWithRoutineContext', () {
    // Write something to the stack now
    cpu.setVariable(Char(0), Char(4711));

    RoutineContext routineContext = RoutineContext(3);
    cpu.pushRoutineContext(routineContext);

    // Write a new value to the stack within the routine
    cpu.setVariable(Char(0), Char(4712));

    int oldStackPointer = cpu.getSP().toInt();
    int value = cpu.getVariable(Char(0)).toInt();
    assertEquals(oldStackPointer - 1, cpu.getSP());
    assertEquals(value, 4712);
  });

  test('SetVariableStack', () {
    int oldStackPointer = cpu.getSP().toInt();
    cpu.setVariable(Char(0), Char(213));
    assertEquals(oldStackPointer + 1, cpu.getSP());
  });

  test('GetLocalVariableIllegal', () {
    expect(
        () => cpu.getVariable(Char(1)),
        throwsA((e) =>
            e is IllegalStateException &&
            e.getMessage() == "no routine context set"));

    cpu.pushRoutineContext(routineInfo);

    expect(
        () => cpu.getVariable(Char(5)),
        throwsA((e) =>
            e is IllegalStateException &&
            e.getMessage() == "access to non-existent local variable: 4"));
  });

  test('SetLocalVariable', () {
    expect(
        () => cpu.setVariable(Char(1), Char(4711)),
        throwsA((e) =>
            e is IllegalStateException &&
            "no routine context set" == e.getMessage()));

    cpu.pushRoutineContext(routineInfo);
    cpu.setVariable(Char(1), Char(4711)); // Local variable 0
    assertEquals(4711, cpu.getVariable(Char(1)));

    // access a non-existent variable
    expect(
        () => cpu.setVariable(Char(6), Char(2312)),
        throwsA((e) =>
            e is IllegalStateException &&
            "access to non-existent local variable: 5" == e.getMessage()));
  });

  test('PopRoutineContextIllegal', () {
    expect(
        () => cpu.returnWith(Char(42)),
        throwsA((e) =>
            e is IllegalStateException &&
            "no routine context active" == e.getMessage()));
  });

  test('CallAndReturn', () {
    // Setup the environment
    cpu.setVariable(Char(0), Char(10)); // write something on the stack
    int oldSp = cpu.getSP().toInt();
    // Use addresses, which exceed 16 Bit
    cpu.setPC(0x15747);
    int returnAddress = 0x15749;

    // Initialize the routine context
    RoutineContext routineContext = RoutineContext(0);
    routineContext.setReturnVariable(Char(0x12));

    // simulate a call
    routineContext.setReturnAddress(
        returnAddress); // save the return address in the context
    cpu.pushRoutineContext(routineContext);
    cpu.setPC(0x15815);

    // assert that the context has saved the old stack pointer
    assertEquals(oldSp, routineContext.getInvocationStackPointer());

    // simulate some stack pushes
    cpu.setVariable(Char(0), Char(213));
    cpu.setVariable(Char(0), Char(214));
    cpu.setVariable(Char(0), Char(215));

    assertNotSame(oldSp, cpu.getSP());
    cpu.returnWith(Char(42));
    assertEquals(returnAddress, cpu.getPC());
    assertEquals(oldSp, cpu.getSP());

    // Set the variable
    verify(machine.writeUnsigned16(5004, Char(42))).called(1);
  });

  test('TranslatePackedAddressV3', () {
    when(machine.getVersion()).thenReturn(3);

    int byteAddressR = cpu.unpackRoutineAddress(Char(65000));
    int byteAddressS = cpu.unpackStringAddress(Char(65000));
    assertEquals(65000 * 2, byteAddressR);
    assertEquals(65000 * 2, byteAddressS);

    verify(machine.getVersion()).called(greaterThan(1));
  });

  test('TranslatePackedAddressV4', () {
    when(machine.getVersion()).thenReturn(4);

    int byteAddressR = cpu.unpackRoutineAddress(Char(65000));
    int byteAddressS = cpu.unpackStringAddress(Char(65000));
    assertEquals(65000 * 4, byteAddressR);
    assertEquals(65000 * 4, byteAddressS);

    verify(machine.getVersion()).called(greaterThan(1));
  });

  test('TranslatePackedAddressV7', () {
    when(machine.getVersion()).thenReturn(7);
    // routine offset
    when(machine.readUnsigned16(0x28)).thenReturn(Char(5));
    // static string offset
    when(machine.readUnsigned16(0x2a)).thenReturn(Char(6));

    int byteAddressR = cpu.unpackRoutineAddress(Char(65000));
    int byteAddressS = cpu.unpackStringAddress(Char(65000));
    assertEquals(65000 * 4 + 8 * 5, byteAddressR);
    assertEquals(65000 * 4 + 8 * 6, byteAddressS);

    verify(machine.getVersion()).called(greaterThan(1));
    // routine offset
    verify(machine.readUnsigned16(0x28)).called(1);
    // static string offset
    verify(machine.readUnsigned16(0x2a)).called(1);
  });

  test('TranslatePackedAddressV8', () {
    when(machine.getVersion()).thenReturn(8);

    int byteAddressR = cpu.unpackRoutineAddress(Char(65000));
    int byteAddressS = cpu.unpackStringAddress(Char(65000));
    assertEquals(65000 * 8, byteAddressR);
    assertEquals(65000 * 8, byteAddressS);

    verify(machine.getVersion()).called(greaterThan(1));
  });
}

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

/// A Stub instruction class that exposes the protected methods to test
/// their behaviour.
class StubInstruction extends AbstractInstruction {
  StubInstruction(Machine machine, int opcodeNum, List<Operand> operands,
      Char storeVar, BranchInfo branchInfo, int opcodeLength)
      : super(machine, opcodeNum, operands, storeVar, branchInfo, opcodeLength);

  @override
  int getNumOperands() {
    return super.getNumOperands();
  }

  @override
  Char getUnsignedValue(int operandNum) {
    return super.getUnsignedValue(operandNum);
  }

  @override
  int getSignedValue(int operandNum) {
    return super.getSignedValue(operandNum);
  }

  @override
  int getSignedVarValue(Char varnum) {
    return super.getSignedVarValue(varnum);
  }

  @override
  void setSignedVarValue(Char varnum, int value) {
    super.setSignedVarValue(varnum, value);
  }

  @override
  void storeUnsignedResult(Char value) {
    super.storeUnsignedResult(value);
  }

  @override
  void storeSignedResult(int value) {
    super.storeSignedResult(value);
  }

  @override
  void nextInstruction() {
    super.nextInstruction();
  }

  @override
  void branchOnTest(bool cond) {
    super.branchOnTest(cond);
  }

  @override
  void returnFromRoutine(Char retval) {
    super.returnFromRoutine(retval);
  }

  @override
  void call(int numArgs) {
    super.call(numArgs);
  }

  @override
  void callAddress(Char packedRoutineAddress, List<Char> args) {
    super.callAddress(packedRoutineAddress, args);
  }

  @override
  OperandCount getOperandCount() {
    return null;
  }

  void execute() {}
}

void main() {
  final Char STD_STOREVAR = Char(6);
  MockMachine machine;

  setUp(() {
    machine = MockMachine();
  });

  StubInstruction createStubInstruction(List<Operand> operands) {
    int opcodeNum = 12;
    Char storeVar = STD_STOREVAR;
    BranchInfo branchInfo = BranchInfo(true, 0, 0, 0);
    int opcodeLength = 5;

    return StubInstruction(
        machine, opcodeNum, operands, storeVar, branchInfo, opcodeLength);
  }

  StubInstruction createStdInstruction() {
    final stackOperand = Operand(Operand.TYPENUM_VARIABLE, Char(0x00));
    final varOperand = Operand(Operand.TYPENUM_VARIABLE, Char(0x11));
    final smallConstOperand =
        Operand(Operand.TYPENUM_SMALL_CONSTANT, Char(0xbe));
    final largeConstOperand =
        Operand(Operand.TYPENUM_LARGE_CONSTANT, Char(0xface));
    return createStubInstruction(
        [stackOperand, varOperand, smallConstOperand, largeConstOperand]);
  }

  test('CreateInstructionInfo', () {
    assertEquals(4, createStdInstruction().getNumOperands());
  });

  test('GetUnsignedValue', () {
    when(machine.getVariable(Char(0x00))).thenReturn(Char(0xcafe));
    when(machine.getVariable(Char(0x11))).thenReturn(Char(0xdeca));

    StubInstruction instr = createStdInstruction();
    assertEquals(0xcafe, instr.getUnsignedValue(0));
    assertEquals(0xdeca, instr.getUnsignedValue(1));
    assertEquals(0x00be, instr.getUnsignedValue(2));
    assertEquals(0xface, instr.getUnsignedValue(3));

    verify(machine.getVariable(Char(0x00))).called(1);
    verify(machine.getVariable(Char(0x11))).called(1);
  });

  test('GetSignedValue', () {
    when(machine.getVariable(Char(0x00))).thenReturn(Char(0xcafe));
    when(machine.getVariable(Char(0x11))).thenReturn(Char(0xdeca));

    StubInstruction instr = createStdInstruction();
    assertEquals(unsignedToSigned16(Char(0xcafe)), instr.getSignedValue(0));
    assertEquals(unsignedToSigned16(Char(0xdeca)), instr.getSignedValue(1));
    // This is interesting, on small constants, it returns an unsigned !
    assertEquals(unsignedToSigned16(Char(0xbe)), instr.getSignedValue(2));
    assertEquals(unsignedToSigned16(Char(0xface)), instr.getSignedValue(3));

    verify(machine.getVariable(Char(0x00))).called(1);
    verify(machine.getVariable(Char(0x11))).called(1);
  });

  test('GetSignedVarValue', () {
    when(machine.getVariable((Char(0x03)))).thenReturn(Char(0xfffe));

    StubInstruction instr = createStdInstruction();
    assertEquals(-2, instr.getSignedVarValue(Char(3)));

    verify(machine.getVariable(Char(0x03))).called(1);
  });

  test('SetSignedVarValue', () {
    StubInstruction instr = createStdInstruction();
    instr.setSignedVarValue(Char(3), -2);

    verify(machine.setVariable(Char(3), Char(0xfffe))).called(1);
  });

  test('StoreUnsignedResult', () {
    StubInstruction instr = createStdInstruction();
    instr.storeUnsignedResult(Char(0xfeee));
    verify(machine.setVariable(STD_STOREVAR, Char(0xfeee))).called(1);
  });

  test('StoreSignedResult', () {
    StubInstruction instr = createStdInstruction();
    instr.storeSignedResult(-3);

    verify(machine.setVariable(STD_STOREVAR, Char(0xfffd))).called(1);
  });
}

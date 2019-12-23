import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

class C1OpMock extends C1OpInstruction {
  bool nextInstructionCalled;
  bool returned;
  Char returnValue;
  bool branchOnTestCalled;
  bool branchOnTestCondition;

  C1OpMock(Machine machine, int opcode, List<Operand> operands, Char storeVar)
      : super(machine, opcode, operands, storeVar, null, 3);

  @override
  void nextInstruction() {
    nextInstructionCalled = true;
  }

  @override
  void returnFromRoutine(Char retval) {
    returned = true;
    returnValue = retval;
  }

  @override
  void branchOnTest(bool flag) {
    branchOnTestCalled = true;
    branchOnTestCondition = flag;
  }
}

void main() {
  MockMachine machine;

  void setupStoryVersion(final int version) {
    when(machine.getVersion()).thenReturn(version);
  }

  void verifyStoryVersion(final int version) {
    verify(machine.getVersion()).called(greaterThan(0));
  }

  setUp(() {
    machine = MockMachine();
  });

  C1OpMock createInstructionMock(int opcode, int typenum, Char value,
      [Char storevar]) {
    Operand operand1 = Operand(typenum, value);
    C1OpMock result =
    C1OpMock(machine, opcode, [operand1], storevar ?? Char(0));
    return result;
  }

  // ***********************************************************************
  // ********* INC
  // ******************************************

  test('Inc', () {
    when(machine.getVariable(Char(2))).thenReturn(signedToUnsigned16(-1));

    C1OpMock inc = createInstructionMock(
        Instruction.C1OP_INC, Operand.TYPENUM_SMALL_CONSTANT, Char(2));
    inc.execute();
    assertTrue(inc.nextInstructionCalled);

    verify(machine.getVariable(Char(2))).called(1);
    verify(machine.setVariable(Char(2), Char(0))).called(1);
  });

  // ***********************************************************************
  // ********* DEC
  // ******************************************

  test('Dec', () {
    when(machine.getVariable(Char(6))).thenReturn(Char(123));

    C1OpMock dec = createInstructionMock(
        Instruction.C1OP_DEC, Operand.TYPENUM_SMALL_CONSTANT, Char(6));
    dec.execute();
    assertTrue(dec.nextInstructionCalled);

    verify(machine.getVariable(Char(6))).called(1);
    verify(machine.setVariable(Char(6), Char(122))).called(1);
  });

  test('Dec0', () {
    when(machine.getVariable(Char(7))).thenReturn(Char(0));

    C1OpMock dec = createInstructionMock(
        Instruction.C1OP_DEC, Operand.TYPENUM_SMALL_CONSTANT, Char(7));
    dec.execute();
    assertTrue(dec.nextInstructionCalled);

    verify(machine.getVariable(Char(7))).called(1);
    verify(machine.setVariable(Char(7), signedToUnsigned16(-1))).called(1);
  });

  // ***********************************************************************
  // ********* GET_PARENT
  // ******************************************

  test('GetParent', () {
    when(machine.getParent(2)).thenReturn(27);

    Char storevar = Char(0x10);
    C1OpMock get_parent = createInstructionMock(Instruction.C1OP_GET_PARENT,
        Operand.TYPENUM_SMALL_CONSTANT, Char(0x02), storevar);
    get_parent.execute();
    assertTrue(get_parent.nextInstructionCalled);

    verify(machine.getParent(2)).called(1);
    verify(machine.setVariable(Char(0x10), Char(27))).called(1);
  });

  // ***********************************************************************
  // ********* JUMP
  // ******************************************

  test('Jump', () {
    C1OpMock jump = createInstructionMock(
        Instruction.C1OP_JUMP, Operand.TYPENUM_LARGE_CONSTANT, Char(0x4711));
    jump.execute();

    verify(machine.incrementPC(18194)).called(1);
  });

  // ***********************************************************************
  // ********* LOAD
  // ******************************************

  test('LoadOperandIsVariable', () {
    // Simulate: value in variable 1 is to, indicating value is retrieved from
    // variable 2

    when(machine.getVariable(Char(1))).thenReturn(Char(2));
    when(machine.getVariable(Char(2))).thenReturn(Char(4711));

    Char storevar = Char(0x12);
    C1OpMock load = createInstructionMock(
        Instruction.C1OP_LOAD, Operand.TYPENUM_VARIABLE, Char(0x01), storevar);
    load.execute();
    assertTrue(load.nextInstructionCalled);

    verify(machine.getVariable(Char(1))).called(1);
    verify(machine.getVariable(Char(2))).called(1);
    verify(machine.setVariable(Char(0x12), Char(4711))).called(1);
  });

  test('LoadOperandIsConstant', () {
    when(machine.getVariable(Char(1))).thenReturn(Char(4715));

    Char storevar = Char(0x13);
    C1OpMock load = createInstructionMock(Instruction.C1OP_LOAD,
        Operand.TYPENUM_SMALL_CONSTANT, Char(0x01), storevar);
    load.execute();
    assertTrue(load.nextInstructionCalled);

    verify(machine.getVariable(Char(1))).called(1);
    verify(machine.setVariable(Char(0x13), Char(4715))).called(1);
  });

  // Standard 1.1: Stack reference, the top of stack is read only, not popped

  test('LoadOperandReferencesStack', () {
    when(machine.getStackTop()).thenReturn(Char(4715));

    Char storevar = Char(0x13);
    C1OpMock load = createInstructionMock(Instruction.C1OP_LOAD,
        Operand.TYPENUM_SMALL_CONSTANT, Char(0x00), storevar);
    load.execute();
    assertTrue(load.nextInstructionCalled);

    verify(machine.getStackTop()).called(1);
    verify(machine.setVariable(Char(0x13), Char(4715))).called(1);
  });

  // ***********************************************************************
  // ********* JZ
  // ******************************************

  // Situation 1:
  // Sets operand != 0, so the jump will not be performed

  test('JzBranchIfTrueNotZero', () {
    C1OpMock jz = createInstructionMock(
        Instruction.C1OP_JZ, Operand.TYPENUM_SMALL_CONSTANT, Char(0x01));
    jz.execute();
    assertTrue(jz.branchOnTestCalled);
    assertFalse(jz.branchOnTestCondition);
  });

  // Situation 2:
  // Is zero, and branch offset will be 0, so return false from current
  // routine

  test('JzBranchIfTrueIsZero', () {
    C1OpMock jz = createInstructionMock(
        Instruction.C1OP_JZ, Operand.TYPENUM_SMALL_CONSTANT, Char(0x00));
    jz.execute();
    assertTrue(jz.branchOnTestCalled);
    assertTrue(jz.branchOnTestCondition);
  });

  // ***********************************************************************
  // ********* GET_SIBLING
  // ******************************************

  // Object has no next sibling

  test('GetSiblingIs0', () {
    when(machine.getSibling(8)).thenReturn(0);

    Char storevar = Char(0x01);
    C1OpMock get_sibling = createInstructionMock(Instruction.C1OP_GET_SIBLING,
        Operand.TYPENUM_SMALL_CONSTANT, Char(0x08), storevar);
    get_sibling.execute();
    assertTrue(get_sibling.branchOnTestCalled);
    assertFalse(get_sibling.branchOnTestCondition);

    verify(machine.getSibling(8)).called(1);
    verify(machine.setVariable(Char(0x01), Char(0))).called(1);
  });

  test('GetSiblingHasSibling', () {
    when(machine.getSibling(6)).thenReturn(152);

    // Object 6 has 152 as its sibling
    Char storevar = Char(0x01);
    C1OpMock get_sibling = createInstructionMock(Instruction.C1OP_GET_SIBLING,
        Operand.TYPENUM_SMALL_CONSTANT, Char(0x06), storevar);
    get_sibling.execute();
    assertTrue(get_sibling.branchOnTestCalled);
    assertTrue(get_sibling.branchOnTestCondition);

    verify(machine.getSibling(6)).called(1);
    verify(machine.setVariable(Char(0x01), Char(152))).called(1);
  });

  // ***********************************************************************
  // ********* GET_CHILD
  // ******************************************

  test('GetChildOfObject0', () {
    // Object 0 does not exist
    C1OpMock get_child = createInstructionMock(
        Instruction.C1OP_GET_CHILD, Operand.TYPENUM_SMALL_CONSTANT, Char(0x00));
    get_child.execute();
    assertTrue(get_child.branchOnTestCalled);
    assertFalse(get_child.branchOnTestCondition);

    verify(machine.warn("@get_child illegal access to object 0")).called(1);
    verify(machine.setVariable(Char(0x00), Char(0))).called(1);
  });

  test('GetChildIs0', () {
    when(machine.getChild(4)).thenReturn(0);

    // Object 4 has no child
    Char storevar = Char(0x01);
    C1OpMock get_child = createInstructionMock(Instruction.C1OP_GET_CHILD,
        Operand.TYPENUM_SMALL_CONSTANT, Char(0x04), storevar);
    get_child.execute();
    assertTrue(get_child.branchOnTestCalled);
    assertFalse(get_child.branchOnTestCondition);

    verify(machine.getChild(4)).called(1);
    verify(machine.setVariable(Char(0x01), Char(0))).called(1);
  });

  test('GetChildAndBranch', () {
    when(machine.getChild(7)).thenReturn(41);

    // Object 7 has 41 as its child
    Char storevar = Char(0x02);
    C1OpMock get_child = createInstructionMock(Instruction.C1OP_GET_CHILD,
        Operand.TYPENUM_SMALL_CONSTANT, Char(0x07), storevar);
    get_child.execute();
    assertTrue(get_child.branchOnTestCalled);
    assertTrue(get_child.branchOnTestCondition);

    verify(machine.getChild(7)).called(1);
    verify(machine.setVariable(Char(0x02), Char(41))).called(1);
  });

  // ***********************************************************************
  // ********* PRINT_ADDR
  // ******************************************

  test('PrintAddr', () {
    C1OpMock print_addr = createInstructionMock(Instruction.C1OP_PRINT_ADDR,
        Operand.TYPENUM_LARGE_CONSTANT, Char(0x28bc));
    print_addr.execute();
    assertTrue(print_addr.nextInstructionCalled);

    verify(machine.printZString(0x28bc)).called(1);
  });

  // ***********************************************************************
  // ********* PRINT_PADDR
  // ******************************************

  test('PrintPaddr', () {
    when(machine.unpackStringAddress(Char(0x145e))).thenReturn(1234);

    C1OpMock print_paddr = createInstructionMock(Instruction.C1OP_PRINT_PADDR,
        Operand.TYPENUM_LARGE_CONSTANT, Char(0x145e));
    print_paddr.execute();
    assertTrue(print_paddr.nextInstructionCalled);

    verify(machine.unpackStringAddress(Char(0x145e))).called(1);
    verify(machine.printZString(1234)).called(1);
  });

  // ***********************************************************************
  // ********* RET
  // ******************************************

  test('Ret', () {
    C1OpMock ret = createInstructionMock(
        Instruction.C1OP_RET, Operand.TYPENUM_LARGE_CONSTANT, Char(0x145e));
    ret.execute();
    assertTrue(ret.returned);
    assertEquals(0x145e, ret.returnValue);
  });

  test('RetWithVariable', () {
    when(machine.getVariable(Char(1))).thenReturn(Char(0x23));

    C1OpMock ret = createInstructionMock(
        Instruction.C1OP_RET, Operand.TYPENUM_VARIABLE, Char(0x01));
    ret.execute();
    assertTrue(ret.returned);
    assertEquals(0x23, ret.returnValue);

    verify(machine.getVariable(Char(1))).called(1);
  });

  // ***********************************************************************
  // ********* PRINT_OBJ
  // ******************************************

  test('PrintObj', () {
    when(machine.getPropertiesDescriptionAddress(3)).thenReturn(4712);

    C1OpMock print_obj = createInstructionMock(
        Instruction.C1OP_PRINT_OBJ, Operand.TYPENUM_SMALL_CONSTANT, Char(0x03));
    print_obj.execute();
    assertTrue(print_obj.nextInstructionCalled);

    verify(machine.getPropertiesDescriptionAddress(3)).called(1);
    verify(machine.printZString(4712)).called(1);
  });

  // ***********************************************************************
  // ********* REMOVE_OBJ
  // ******************************************

  test('RemoveObj', () {
    C1OpMock remove_obj = createInstructionMock(Instruction.C1OP_REMOVE_OBJ,
        Operand.TYPENUM_SMALL_CONSTANT, Char(0x03));
    remove_obj.execute();
    assertTrue(remove_obj.nextInstructionCalled);

    verify(machine.removeObject(0x03)).called(1);
  });

  // ***********************************************************************
  // ********* GET_PROP_LEN
  // ******************************************

  test('GetPropLen', () {
    when(machine.getPropertyLength(0x1889)).thenReturn(4);

    Char storeVar = Char(0x15);
    C1OpMock get_prop_len = createInstructionMock(Instruction.C1OP_GET_PROP_LEN,
        Operand.TYPENUM_LARGE_CONSTANT, Char(0x1889), storeVar);
    get_prop_len.execute();
    assertTrue(get_prop_len.nextInstructionCalled);

    verify(machine.getPropertyLength(0x1889)).called(1);
    verify(machine.setVariable(Char(0x15), Char(4))).called(1);
  });

  // ***********************************************************************
  // ********* CALL_1S
  // ******************************************

  test('Call1SIllegalInVersion3', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertFalse(infoDb.isValid(OperandCount.C1OP, Instruction.C1OP_CALL_1S, 3));
  });

  // ***********************************************************************
  // ********* Version 4
  // ******************************************
  // ***********************************************************************
  // ********* NOT
  // ******************************************

  test('Not', () {
    setupStoryVersion(4);

    // Create instruction
    Char storevar = Char(0x12);
    C1OpMock not = createInstructionMock(Instruction.C1OP_NOT,
        Operand.TYPENUM_LARGE_CONSTANT, Char(0xaaaa), storevar);
    not.execute();
    assertTrue(not.nextInstructionCalled);

    verify(machine.setVariable(Char(0x12), Char(0x5555))).called(1);

    verifyStoryVersion(4);
  });

  // ***********************************************************************
  // ********* CALL_1S
  // ******************************************

  test('Call1s', () {
    setupStoryVersion(4);
    final List<Char> args = [];
    when(machine.getPC()).thenReturn(4620);

    C1OpMock call1s = createInstructionMock(
        Instruction.C1OP_CALL_1S, Operand.TYPENUM_LARGE_CONSTANT, Char(4611));
    call1s.execute();

    verify(machine.getPC()).called(1);
    verify(machine.call(Char(4611), 4623, args, Char(0))).called(1);

    verifyStoryVersion(4);
  });

  test('StoresResultV4', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertTrue(infoDb
        .getInfo(OperandCount.C1OP, Instruction.C1OP_GET_SIBLING, 4)
        .isStore());
    assertTrue(infoDb
        .getInfo(OperandCount.C1OP, Instruction.C1OP_GET_CHILD, 4)
        .isStore());
    assertTrue(infoDb
        .getInfo(OperandCount.C1OP, Instruction.C1OP_GET_PARENT, 4)
        .isStore());
    assertTrue(infoDb
        .getInfo(OperandCount.C1OP, Instruction.C1OP_GET_PROP_LEN, 4)
        .isStore());
    assertTrue(
        infoDb.getInfo(OperandCount.C1OP, Instruction.C1OP_LOAD, 4).isStore());
    assertTrue(
        infoDb.getInfo(OperandCount.C1OP, Instruction.C1OP_NOT, 4).isStore());
    assertTrue(infoDb
        .getInfo(OperandCount.C1OP, Instruction.C1OP_CALL_1S, 4)
        .isStore());
    assertFalse(
        infoDb.getInfo(OperandCount.C1OP, Instruction.C1OP_DEC, 4).isStore());
  });

  test('IsBranchV4', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertTrue(
        infoDb.getInfo(OperandCount.C1OP, Instruction.C1OP_JZ, 4).isBranch());
    assertTrue(infoDb
        .getInfo(OperandCount.C1OP, Instruction.C1OP_GET_SIBLING, 4)
        .isBranch());
    assertTrue(infoDb
        .getInfo(OperandCount.C1OP, Instruction.C1OP_GET_CHILD, 4)
        .isBranch());
    assertFalse(infoDb
        .getInfo(OperandCount.C1OP, Instruction.C1OP_GET_PARENT, 4)
        .isBranch());
  });

  test('StoresResultV5', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertFalse(infoDb
        .getInfo(OperandCount.C1OP, Instruction.C1OP_CALL_1N, 5)
        .isStore());
  });
}

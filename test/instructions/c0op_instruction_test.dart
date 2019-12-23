import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

class C0OpMock extends C0OpInstruction {
  bool nextInstructionCalled = false;
  bool returned = false;
  Char returnValue = Char(0);
  bool branchOnTestCalled = false;
  bool branchOnTestCondition = false;

  C0OpMock(Machine machine, int opcode)
      : super(machine, opcode, List<Operand>(0), null, Char(0), null, 0);

  C0OpMock.str(Machine machine, int opcode, String str)
      : super(machine, opcode, List<Operand>(0), str, Char(0), null, 11);

  C0OpMock.operands(Machine machine, int opcode, List<Operand> operands)
      : super(machine, opcode, operands, null, Char(0), null, 0);

  C0OpMock.storeVar(Machine machine, int opcode, Char storeVar)
      : super(machine, opcode, List<Operand>(0), null, storeVar, null, 0);

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

  test('IsBranchV3', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertTrue(
        infoDb.getInfo(OperandCount.C0OP, Instruction.C0OP_SAVE, 3).isBranch());
    assertTrue(infoDb
        .getInfo(OperandCount.C0OP, Instruction.C0OP_RESTORE, 3)
        .isBranch());
    assertTrue(infoDb
        .getInfo(OperandCount.C0OP, Instruction.C0OP_VERIFY, 3)
        .isBranch());
    assertFalse(infoDb
        .getInfo(OperandCount.C0OP, Instruction.C0OP_NEW_LINE, 3)
        .isBranch());
  });

  test('StoresResultV3', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertFalse(
        infoDb.getInfo(OperandCount.C0OP, Instruction.C0OP_SAVE, 3).isStore());
    assertFalse(infoDb
        .getInfo(OperandCount.C0OP, Instruction.C0OP_RESTORE, 3)
        .isStore());
  });

  test('IsBranchV4', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertFalse(
        infoDb.getInfo(OperandCount.C0OP, Instruction.C0OP_SAVE, 4).isBranch());
    assertFalse(infoDb
        .getInfo(OperandCount.C0OP, Instruction.C0OP_RESTORE, 4)
        .isBranch());
  });

  test('StoresResultV4', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertTrue(
        infoDb.getInfo(OperandCount.C0OP, Instruction.C0OP_SAVE, 4).isStore());
    assertTrue(infoDb
        .getInfo(OperandCount.C0OP, Instruction.C0OP_RESTORE, 4)
        .isStore());
  });

  test('IllegalInV4', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertFalse(
        infoDb.isValid(OperandCount.C0OP, Instruction.C0OP_SHOW_STATUS, 4));
  });

  test('StoresResultV5', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertTrue(
        infoDb.getInfo(OperandCount.C0OP, Instruction.C0OP_POP, 5).isStore());
  });

  test('IllegalInV5', () {
    InstructionInfoDb infoDb = InstructionInfoDb.getInstance();
    assertFalse(infoDb.isValid(OperandCount.C0OP, Instruction.C0OP_SAVE, 5));
    assertFalse(infoDb.isValid(OperandCount.C0OP, Instruction.C0OP_RESTORE, 5));
    assertFalse(
        infoDb.isValid(OperandCount.C0OP, Instruction.C0OP_SHOW_STATUS, 5));
  });

  // ***********************************************************************
  // ********* RFALSE
  // ******************************************

  test('Rtrue', () {
    C0OpMock rtrue = C0OpMock(machine, Instruction.C0OP_RTRUE);
    rtrue.execute();
    assertTrue(rtrue.returned);
    assertEquals(Instruction.TRUE, rtrue.returnValue);
  });

  // ***********************************************************************
  // ********* RTRUE
  // ******************************************

  test('Rfalse', () {
    C0OpMock rfalse = C0OpMock(machine, Instruction.C0OP_RFALSE);
    rfalse.execute();
    assertTrue(rfalse.returned);
    assertEquals(Instruction.FALSE, rfalse.returnValue);
  });

  // ***********************************************************************
  // ********* NOP
  // ******************************************

  test('Nop', () {
    C0OpMock nop = C0OpMock(machine, Instruction.C0OP_NOP);
    nop.execute();
    assertTrue(nop.nextInstructionCalled);
  });

  // ***********************************************************************
  // ********* SAVE
  // ******************************************

  test('SaveSuccess', () {
    setupStoryVersion(3);
    when(machine.getPC()).thenReturn(1234);
    when(machine.save(any)).thenReturn(true);

    C0OpMock save = C0OpMock(machine, Instruction.C0OP_SAVE);
    save.execute();
    assertTrue(save.branchOnTestCalled);
    assertTrue(save.branchOnTestCondition);

    verify(machine.getPC()).called(1);
    verify(machine.save(any)).called(1);
    verifyStoryVersion(3);
  });

  test('SaveFail', () {
    setupStoryVersion(3);
    when(machine.getPC()).thenReturn(1234);
    when(machine.save(any)).thenReturn(false);

    C0OpMock save = C0OpMock(machine, Instruction.C0OP_SAVE);
    save.execute();
    assertTrue(save.branchOnTestCalled);
    assertFalse(save.branchOnTestCondition);

    verify(machine.getPC()).called(1);
    verify(machine.save(any)).called(1);
    verifyStoryVersion(3);
  });

  test('RestoreSuccess', () {
    setupStoryVersion(3);
    final PortableGameState gamestate = PortableGameState();
    when(machine.restore()).thenReturn(gamestate);

    C0OpMock restore = C0OpMock(machine, Instruction.C0OP_RESTORE);
    restore.execute();
    assertFalse(restore.nextInstructionCalled);

    verify(machine.restore()).called(1);
    verifyStoryVersion(3);
  });

  test('RestoreFail', () {
    setupStoryVersion(3);
    when(machine.restore()).thenReturn(null);

    C0OpMock restore = C0OpMock(machine, Instruction.C0OP_RESTORE);
    restore.execute();
    assertTrue(restore.nextInstructionCalled);

    verify(machine.restore()).called(1);
    verifyStoryVersion(3);
  });

  test('Restart', () {
    C0OpMock restart = C0OpMock(machine, Instruction.C0OP_RESTART);
    restart.execute();
    verify(machine.restart()).called(1);
  });

  test('Quit', () {
    C0OpMock quit = C0OpMock(machine, Instruction.C0OP_QUIT);
    quit.execute();
    verify(machine.quit()).called(1);
  });

  test('NewLine', () {
    C0OpMock newline = C0OpMock(machine, Instruction.C0OP_NEW_LINE);
    newline.execute();
    assertTrue(newline.nextInstructionCalled);
    verify(machine.newline()).called(1);
  });

  test('RetPopped', () {
    when(machine.getVariable(Char(0))).thenReturn(Char(15));
    C0OpMock ret_popped = C0OpMock(machine, Instruction.C0OP_RET_POPPED);
    ret_popped.execute();
    assertTrue(ret_popped.returned);
    assertEquals(15, ret_popped.returnValue);
    verify(machine.getVariable(Char(0))).called(1);
  });

  test('Pop', () {
    setupStoryVersion(3);
    when(machine.getVariable(Char(0))).thenReturn(Char(42));

    C0OpMock pop = C0OpMock(machine, Instruction.C0OP_POP);
    pop.execute();
    assertTrue(pop.nextInstructionCalled);

    verify(machine.getVariable(Char(0))).called(1);
    verifyStoryVersion(3);
  });

  // ***********************************************************************
  // ********* VERIFY
  // ******************************************
  test('VerifyTrue', () {
    when(machine.hasValidChecksum()).thenReturn(true);

    C0OpMock _verify = C0OpMock(machine, Instruction.C0OP_VERIFY);
    _verify.execute();
    assertTrue(_verify.branchOnTestCalled);
    assertTrue(_verify.branchOnTestCondition);

    verify(machine.hasValidChecksum()).called(1);
  });

  test('VerifyFalse', () {
    when(machine.hasValidChecksum()).thenReturn(false);

    C0OpMock _verify = C0OpMock(machine, Instruction.C0OP_VERIFY);
    _verify.execute();
    assertTrue(_verify.branchOnTestCalled);
    assertFalse(_verify.branchOnTestCondition);

    verify(machine.hasValidChecksum()).called(1);
  });

  test('ShowStatus', () {
    C0OpMock showstatus = C0OpMock(machine, Instruction.C0OP_SHOW_STATUS);
    showstatus.execute();
    assertTrue(showstatus.nextInstructionCalled);
    verify(machine.updateStatusLine()).called(1);
  });

  // ***********************************************************************
  // ********* Version 4
  // ******************************************

  test('SaveSuccessV4', () {
    setupStoryVersion(4);
    when(machine.getPC()).thenReturn(1234);
    when(machine.save(any)).thenReturn(true);

    C0OpMock save = C0OpMock(machine, Instruction.C0OP_SAVE);
    save.execute();
    assertTrue(save.nextInstructionCalled);

    verify(machine.getPC()).called(1);
    verify(machine.save(any)).called(1);
    verify(machine.setVariable(Char(0), Char(1))).called(1);
    verifyStoryVersion(4);
  });

  test('RestoreSuccessV4', () {
    setupStoryVersion(4);
    final PortableGameState gamestate = PortableGameState();

    when(machine.restore()).thenReturn(gamestate);
    when(machine.readUnsigned8(0)).thenReturn(Char(5));

    C0OpMock restore = C0OpMock(machine, Instruction.C0OP_RESTORE);
    restore.execute();
    assertFalse(restore.nextInstructionCalled);

    verify(machine.restore()).called(1);
    // Store variable
    verify(machine.setVariable(Char(5), Char(2))).called(1);
    verify(machine.readUnsigned8(0)).called(1);
    verifyStoryVersion(4);
  });

  test('RestoreFailV4', () {
    setupStoryVersion(4);

    when(machine.restore()).thenReturn(null);

    C0OpMock restore = C0OpMock(machine, Instruction.C0OP_RESTORE);
    restore.execute();
    assertTrue(restore.nextInstructionCalled);

    verify(machine.restore()).called(1);
    verify(machine.setVariable(Char(0), Char(0))).called(1);

    verifyStoryVersion(4);
  });

  // ***********************************************************************
  // ********* Version 5
  // ******************************************

  test('Catch', () {
    setupStoryVersion(5);
    final List<RoutineContext> routineContexts = List<RoutineContext>();
    routineContexts.add(RoutineContext(1));
    routineContexts.add(RoutineContext(0));
    routineContexts.add(RoutineContext(2));

    when(machine.getRoutineContexts()).thenReturn(routineContexts);

    C0OpMock zcatch =
        C0OpMock.storeVar(machine, Instruction.C0OP_POP, Char(0x12));
    zcatch.execute();
    assertTrue(zcatch.nextInstructionCalled);

    verify(machine.getRoutineContexts()).called(1);
    verify(machine.setVariable(Char(0x12), Char(2))).called(1);
    verifyStoryVersion(5);
  });

  // ***********************************************************************
  // ********* Printing
  // ******************************************

  test('Print', () {
    C0OpMock print = C0OpMock.str(machine, Instruction.C0OP_PRINT, "Hallo");
    print.execute();
    assertTrue(print.nextInstructionCalled);

    verify(machine.print("Hallo")).called(1);
  });

  test('PrintRet', () {
    C0OpMock print_ret =
        C0OpMock.str(machine, Instruction.C0OP_PRINT_RET, "HalloRet");
    print_ret.execute();
    assertTrue(print_ret.returned);
    assertEquals(Char(1), print_ret.returnValue);

    verify(machine.print("HalloRet")).called(1);
    verify(machine.newline()).called(1);
  });
}

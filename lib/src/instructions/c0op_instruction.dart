import '../../zvm.dart';

/// Instruction of form 0Op.
class C0OpInstruction extends AbstractInstruction {
  String _str;

  C0OpInstruction(Machine machine, int opcodeNum, List<Operand> operands,
      String str, Char storeVar, BranchInfo branchInfo, int opcodeLength)
      : super(
            machine, opcodeNum, operands, storeVar, branchInfo, opcodeLength) {
    this._str = str;
  }

  @override
  OperandCount getOperandCount() {
    return OperandCount.C0OP;
  }

  @override
  void execute() {
    switch (getOpcodeNum()) {
      case Instruction.C0OP_RTRUE:
        returnFromRoutine(Instruction.TRUE);
        break;
      case Instruction.C0OP_RFALSE:
        returnFromRoutine(Instruction.FALSE);
        break;
      case Instruction.C0OP_PRINT:
        getMachine().print(_str);
        nextInstruction();
        break;
      case Instruction.C0OP_PRINT_RET:
        getMachine().print(_str);
        getMachine().newline();
        returnFromRoutine(Instruction.TRUE);
        break;
      case Instruction.C0OP_NOP:
        nextInstruction();
        break;
      case Instruction.C0OP_SAVE:
        saveToStorage(getMachine().getPC() + 1);
        break;
      case Instruction.C0OP_RESTORE:
        restoreFromStorage();
        break;
      case Instruction.C0OP_RESTART:
        getMachine().restart();
        break;
      case Instruction.C0OP_QUIT:
        getMachine().quit();
        break;
      case Instruction.C0OP_RET_POPPED:
        returnFromRoutine(getMachine().getVariable(Char(0)));
        break;
      case Instruction.C0OP_POP:
        if (getMachine().getVersion() < 5) {
          _pop();
        } else {
          _z_catch();
        }
        break;
      case Instruction.C0OP_NEW_LINE:
        getMachine().newline();
        nextInstruction();
        break;
      case Instruction.C0OP_SHOW_STATUS:
        getMachine().updateStatusLine();
        nextInstruction();
        break;
      case Instruction.C0OP_VERIFY:
        branchOnTest(getMachine().hasValidChecksum());
        break;
      case Instruction.C0OP_PIRACY:
        branchOnTest(true);
        break;
      default:
        throwInvalidOpcode();
    }
  }

  /// Determines whether this instruction is a print instruction.
  bool _isPrint() {
    return InstructionInfoDb.getInstance()
        .getInfo(getOperandCount(), getOpcodeNum(), getStoryVersion())
        .isPrint();
  }

  /// Returns string representation of operands.
  @override
  String getOperandString() {
    if (_isPrint()) {
      return '"${_str}"';
    }
    return super.getOperandString();
  }

  /// Pop instruction.
  void _pop() {
    getMachine().getVariable(Char(0));
    nextInstruction();
  }

  /// Catch instruction.
  void _z_catch() {
    // Stores the index of the current stack frame
    storeUnsignedResult(Char(getMachine().getRoutineContexts().length - 1));
    nextInstruction();
  }
}

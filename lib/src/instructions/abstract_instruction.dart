import '../../zvm.dart';

/// Branch information.
class BranchInfo {
  bool branchOnTrue = false;
  int numOffsetBytes = 0;
  int addressAfterBranchData = 0;
  int branchOffset = 0;

  BranchInfo(bool branchOnTrue, int numOffsetBytes, int addressAfterBranchData,
      int branchOffset) {
    this.branchOnTrue = branchOnTrue;
    this.numOffsetBytes = numOffsetBytes;
    this.addressAfterBranchData = addressAfterBranchData;
    this.branchOffset = branchOffset;
  }
}

/// An abstract instruction to replace the old instruction scheme.
/// Goes with the NewInstructionDecoder.
abstract class AbstractInstruction implements Instruction {
  Machine _machine;
  int _opcodeNum = 0;
  List<Operand> _operands;
  Char _storeVariable = Char(0);
  BranchInfo _branchInfo;
  int _opcodeLength = 0;

  AbstractInstruction(Machine machine, int opcodeNum, List<Operand> operands,
      Char storeVar, BranchInfo branchInfo, int opcodeLength) {
    _machine = machine;
    _opcodeNum = opcodeNum;
    _operands = operands;
    _storeVariable = storeVar;
    _branchInfo = branchInfo;
    _opcodeLength = opcodeLength;
  }

  /// Returns the machine object.
  Machine getMachine() {
    return _machine;
  }

  /// Returns the story version.
  int getStoryVersion() {
    return _machine.getVersion();
  }

  /// Returns the operand count.
  OperandCount getOperandCount();

  /// The opcode length is a crucial attribute for program control, expose it
  /// for testing.
  int getLength() {
    return _opcodeLength;
  }

  /// Returns the instruction's opcode.
  int getOpcodeNum() {
    return _opcodeNum;
  }

  /// Determines whether this instruction stores a result.
  bool storesResult() {
    return InstructionInfoDb.getInstance()
        .getInfo(getOperandCount(), _opcodeNum, _machine.getVersion())
        .isStore();
  }

  // *********************************************************************
  // ******** Variable access
  // ***********************************

  /// Returns the number of operands.
  int getNumOperands() {
    return _operands.length;
  }

  /// Converts the specified value into a signed value, depending on the
  /// type of the operand. If the operand is LARGE_CONSTANT or VARIABLE,
  /// the value is treated as a 16 bit signed integer, if it is SMALL_CONSTANT,
  /// it is treated as an 8 bit signed integer.
  int getSignedValue(final int operandNum) {
    /*
    // I am not sure if this is ever applicable....
    if (operands[operandNum].getType() == OperandType.SMALL_CONSTANT) {
      return MemoryUtil.unsignedToSigned8(getUnsignedValue(operandNum));
    }*/
    return unsignedToSigned16(getUnsignedValue(operandNum)).toInt();
  }

  /// A method to return the signed representation of the contents of a variable
  int getSignedVarValue(Char varnum) {
    return unsignedToSigned16(getMachine().getVariable(varnum)).toInt();
  }

  /// A method to set a signed 16 Bit integer to the specified variable.
  void setSignedVarValue(Char varnum, int value) {
    getMachine().setVariable(varnum, signedToUnsigned16(Short(value)));
  }

  /// Retrieves the value of the specified operand as an unsigned 16 bit
  /// integer.
  Char getUnsignedValue(final int operandNum) {
    final Operand operand = _operands[operandNum];
    switch (operand.getType()) {
      case OperandType.VARIABLE:
        return getMachine().getVariable(operand.getValue());
      case OperandType.SMALL_CONSTANT:
      case OperandType.LARGE_CONSTANT:
      default:
        return operand.getValue();
    }
  }

  /// Stores the specified value in the result variable.
  void storeUnsignedResult(final Char value) {
    getMachine().setVariable(_storeVariable, value);
  }

  /// Stores a signed value in the result variable.
  void storeSignedResult(final int value) {
    storeUnsignedResult(signedToUnsigned16(Short(value)));
  }

  // *********************************************************************
  // ******** Program flow control
  // ***********************************

  /// Advances the program counter to the next instruction.
  void nextInstruction() {
    _machine.incrementPC(_opcodeLength);
  }

  /// Performs a branch, depending on the state of the condition flag.
  /// If branchIfConditionTrue is true, the branch will be performed if
  /// condition is true, if branchIfCondition is false, the branch will
  /// be performed if condition is false.
  void branchOnTest(final bool condition) {
    final bool test = _branchInfo.branchOnTrue ? condition : !condition;
    //System.out.printf("ApplyBranch, offset: %d, opcodeLength: %d,
    //                  branchIfTrue: %b, test: %b\n",
    //                  branchInfo.branchOffset, opcodeLength,
    //                  branchInfo.branchOnTrue, test);
    if (test) {
      _applyBranch();
    } else {
      nextInstruction();
    }
  }

  /// Applies a jump by applying the branch formula on the pc given the specified
  /// offset.
  void _applyBranch() {
    _machine.doBranch(_branchInfo.branchOffset, _opcodeLength);
  }

  /// This function returns from the current routine, setting the return value
  /// into the specified return variable.
  void returnFromRoutine(final Char returnValue) {
    _machine.returnWith(returnValue);
  }

  /// Calls in the Z-machine are all very similar and only differ in the
  /// number of arguments.
  void call(final int numArgs) {
    final Char packedAddress = getUnsignedValue(0);
    final List<Char> args = List<Char>(numArgs);
    for (int i = 0; i < numArgs; i++) {
      args[i] = getUnsignedValue(i + 1);
    }
    callAddress(packedAddress, args);
  }

  /// Perform a call to a packed address.
  void callAddress(final Char packedRoutineAddress, final List<Char> args) {
    if (packedRoutineAddress.toInt() == 0) {
      if (storesResult()) {
        // only if this instruction stores a result
        storeUnsignedResult(Instruction.FALSE);
      }
      nextInstruction();
    } else {
      final int returnAddress = getMachine().getPC() + _opcodeLength;
      final Char returnVariable =
          storesResult() ? _storeVariable : RoutineContext.DISCARD_RESULT;
      _machine.call(packedRoutineAddress, returnAddress, args, returnVariable);
    }
  }

  /// Halt the virtual machine with an error message about this instruction.
  void throwInvalidOpcode() {
    _machine.halt("illegal instruction, operand count: " +
        getOperandCount().toString() +
        " opcode: " +
        _opcodeNum.toString());
  }

  /// Save game state to persistent storage.
  void saveToStorage(final int pc) {
    // This is a little tricky: In version 3, the program counter needs to
    // point to the branch offset, and not to an instruction position
    // In version 4, this points to the store variable. In both cases this
    // address is the instruction address + 1
    final bool success = getMachine().save(pc);

    if (_machine.getVersion() <= 3) {
      //int target = getMachine().getProgramCounter() + getLength();
      //target--; // point to the previous branch offset
      //bool success = getMachine().save(target);
      branchOnTest(success);
    } else {
      // changed behaviour in version >= 4
      storeUnsignedResult(success ? Instruction.TRUE : Instruction.FALSE);
      nextInstruction();
    }
  }

  /// Restore game from persistent storage.
  void restoreFromStorage() {
    final PortableGameState gamestate = getMachine().restore();
    if (_machine.getVersion() <= 3) {
      if (gamestate == null) {
        // If failure on restore, just continue
        nextInstruction();
      }
    } else {
      // changed behaviour in version >= 4
      if (gamestate == null) {
        storeUnsignedResult(Instruction.FALSE);
        // If failure on restore, just continue
        nextInstruction();
      } else {
        final Char storevar = gamestate.getStoreVariable(getMachine());
        getMachine().setVariable(storevar, Instruction.RESTORE_TRUE);
      }
    }
  }

  /// Returns the window for a given window number.
  Window6 getWindow(final int windownum) {
    return (windownum == ScreenModel.CURRENT_WINDOW)
        ? getMachine().getScreen6().getSelectedWindow()
        : getMachine().getScreen6().getWindow(windownum);
  }

  /// Helper function
  bool isOutput() {
    return InstructionInfoDb.getInstance()
        .getInfo(getOperandCount(), _opcodeNum, getStoryVersion())
        .isOutput();
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();
    buffer.write(InstructionInfoDb.getInstance()
        .getInfo(getOperandCount(), _opcodeNum, getStoryVersion())
        .getName());
    buffer.write(" ");
    buffer.write(getOperandString());
    if (storesResult()) {
      buffer.write(" -> ");
      buffer.write(_getVarName(_storeVariable.toInt()));
    }
    return buffer.toString();
  }

  /// Returns the string representation of the specified variable.
  String _getVarName(final int varnum) {
    if (varnum == 0) {
      return "(SP)";
    } else if (varnum <= 15) {
      return toL02x(varnum - 1);
    } else {
      return toG02x(varnum - 16);
    }
  }

  /// Returns the value of the specified variable.
  String _getVarValue(final Char varnum) {
    Char value = Char(0);
    if (varnum.toInt() == 0) {
      value = _machine.getStackTop();
    } else {
      value = _machine.getVariable(varnum);
    }
    return toS04x(value);
  }

  /// Returns the string representation of the operands.
  String getOperandString() {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < getNumOperands(); i++) {
      if (i > 0) {
        buffer.write(", ");
      }
      final Operand operand = _operands[i];
      switch (operand.getType()) {
        case OperandType.SMALL_CONSTANT:
          buffer.write(toS02x(operand.getValue()));
          break;
        case OperandType.LARGE_CONSTANT:
          buffer.write(toS04x(operand.getValue()));
          break;
        case OperandType.VARIABLE:
          buffer.write(_getVarName(operand.getValue().toInt()));
          buffer.write("[");
          buffer.write(_getVarValue(operand.getValue()));
          buffer.write("]");
          break;
        default:
          break;
      }
    }
    return buffer.toString();
  }
}

import '../../zvm.dart';

/// Implementation for 2OP operand count instructions.
class C2OpInstruction extends AbstractInstruction {
  C2OpInstruction(Machine machine, int opcodeNum, List<Operand> operands,
      Char storeVar, BranchInfo branchInfo, int opcodeLength)
      : super(machine, opcodeNum, operands, storeVar, branchInfo, opcodeLength);

  @override
  OperandCount getOperandCount() {
    return OperandCount.C2OP;
  }

  @override
  void execute() {
    switch (getOpcodeNum()) {
      case Instruction.C2OP_JE:
        _je();
        break;
      case Instruction.C2OP_JL:
        _jl();
        break;
      case Instruction.C2OP_JG:
        _jg();
        break;
      case Instruction.C2OP_JIN:
        _jin();
        break;
      case Instruction.C2OP_DEC_CHK:
        _dec_chk();
        break;
      case Instruction.C2OP_INC_CHK:
        _inc_chk();
        break;
      case Instruction.C2OP_TEST:
        _test();
        break;
      case Instruction.C2OP_OR:
        _or();
        break;
      case Instruction.C2OP_AND:
        _and();
        break;
      case Instruction.C2OP_TEST_ATTR:
        _test_attr();
        break;
      case Instruction.C2OP_SET_ATTR:
        _set_attr();
        break;
      case Instruction.C2OP_CLEAR_ATTR:
        _clear_attr();
        break;
      case Instruction.C2OP_STORE:
        _store();
        break;
      case Instruction.C2OP_INSERT_OBJ:
        _insert_obj();
        break;
      case Instruction.C2OP_LOADW:
        _loadw();
        break;
      case Instruction.C2OP_LOADB:
        _loadb();
        break;
      case Instruction.C2OP_GET_PROP:
        _get_prop();
        break;
      case Instruction.C2OP_GET_PROP_ADDR:
        _get_prop_addr();
        break;
      case Instruction.C2OP_GET_NEXT_PROP:
        _get_next_prop();
        break;
      case Instruction.C2OP_ADD:
        _add();
        break;
      case Instruction.C2OP_SUB:
        _sub();
        break;
      case Instruction.C2OP_MUL:
        _mul();
        break;
      case Instruction.C2OP_DIV:
        _div();
        break;
      case Instruction.C2OP_MOD:
        _mod();
        break;
      case Instruction.C2OP_CALL_2S:
        call(1);
        break;
      case Instruction.C2OP_CALL_2N:
        call(1);
        break;
      case Instruction.C2OP_SET_COLOUR:
        _set_colour();
        break;
      case Instruction.C2OP_THROW:
        _z_throw();
        break;
      default:
        throwInvalidOpcode();
    }
  }

  /// JE instruction.
  void _je() {
    bool equalsFollowing = false;
    final Char op1 = getUnsignedValue(0);
    if (getNumOperands() <= 1) {
      getMachine()
          .halt("je expects at least two operands, only " + "one provided");
    } else {
      for (int i = 1; i < getNumOperands(); i++) {
        Char value = getUnsignedValue(i);
        if (op1 == value) {
          equalsFollowing = true;
          break;
        }
      }
      branchOnTest(equalsFollowing);
    }
  }

  /// JL instruction.
  void _jl() {
    final int op1 = getSignedValue(0);
    final int op2 = getSignedValue(1);
    //System.out.printf("Debugging jl op1: %d op2: %d\n", op1, op2);
    branchOnTest(op1 < op2);
  }

  /// JG instruction.
  void _jg() {
    final int op1 = getSignedValue(0);
    final int op2 = getSignedValue(1);
    branchOnTest(op1 > op2);
  }

  /// JIN instruction.
  void _jin() {
    final int obj1 = getUnsignedValue(0).toInt();
    final int obj2 = getUnsignedValue(1).toInt();
    int parentOfObj1 = 0;

    if (obj1 > 0) {
      parentOfObj1 = getMachine().getParent(obj1);
    } else {
      getMachine().warn("@jin illegal access to object ${obj1}");
    }
    branchOnTest(parentOfObj1 == obj2);
  }

  /// DEC_CHK instruction.
  void _dec_chk() {
    final Char varnum = getUnsignedValue(0);
    final int value = getSignedValue(1);
    final int varValue = getSignedVarValue(varnum) - 1;
    setSignedVarValue(varnum, varValue);
    branchOnTest(varValue < value);
  }

  /// INC_CHK instruction.
  void _inc_chk() {
    final Char varnum = getUnsignedValue(0);
    final int value = getSignedValue(1);
    final int varValue = getSignedVarValue(varnum) + 1;
    setSignedVarValue(varnum, varValue);
    branchOnTest(varValue > value);
  }

  /// TEST instruction.
  void _test() {
    final int op1 = getUnsignedValue(0).toInt();
    final int op2 = getUnsignedValue(1).toInt();
    branchOnTest((op1 & op2) == op2);
  }

  /// OR instruction.
  void _or() {
    final int op1 = getUnsignedValue(0).toInt();
    final int op2 = getUnsignedValue(1).toInt();
    storeUnsignedResult(Char((op1 | op2) & 0xffff));
    nextInstruction();
  }

  /// AND instruction.
  void _and() {
    final int op1 = getUnsignedValue(0).toInt();
    final int op2 = getUnsignedValue(1).toInt();
    storeUnsignedResult(Char((op1 & op2) & 0xffff));
    nextInstruction();
  }

  /// ADD instruction.
  void _add() {
    final int op1 = getSignedValue(0);
    final int op2 = getSignedValue(1);
    storeSignedResult(op1 + op2);
    nextInstruction();
  }

  /// SUB instruction.
  void _sub() {
    final int op1 = getSignedValue(0);
    final int op2 = getSignedValue(1);
    storeSignedResult(op1 - op2);
    nextInstruction();
  }

  /// MUL instruction.
  void _mul() {
    final int op1 = getSignedValue(0);
    final int op2 = getSignedValue(1);
    storeSignedResult(op1 * op2);
    nextInstruction();
  }

  /// DIV instruction.
  void _div() {
    final int op1 = getSignedValue(0);
    final int op2 = getSignedValue(1);
    if (op2 == 0) {
      getMachine().halt("@div division by zero");
    } else {
      storeSignedResult(op1 ~/ op2);
      nextInstruction();
    }
  }

  /// MOD instruction.
  void _mod() {
    final int op1 = getSignedValue(0);
    final int op2 = getSignedValue(1);
    if (op2 == 0) {
      getMachine().halt("@mod division by zero");
    } else {
      storeSignedResult(op1 % op2);
      nextInstruction();
    }
  }

  /// TEST_ATTR instruction.
  void _test_attr() {
    final int obj = getUnsignedValue(0).toInt();
    final int attr = getUnsignedValue(1).toInt();
    if (obj > 0 && _isValidAttribute(attr)) {
      branchOnTest(getMachine().isAttributeSet(obj, attr));
    } else {
      getMachine().warn("@test_attr illegal access to object ${obj}");
      branchOnTest(false);
    }
  }

  /// SET_ATTR instruction.
  void _set_attr() {
    final int obj = getUnsignedValue(0).toInt();
    final int attr = getUnsignedValue(1).toInt();
    if (obj > 0 && _isValidAttribute(attr)) {
      getMachine().setAttribute(obj, attr);
    } else {
      getMachine()
          .warn("@set_attr illegal access to object ${obj}" + " attr: ${attr}");
    }
    nextInstruction();
  }

  /// CLEAR_ATTR instruction.
  void _clear_attr() {
    final int obj = getUnsignedValue(0).toInt();
    final int attr = getUnsignedValue(1).toInt();
    if (obj > 0 && _isValidAttribute(attr)) {
      getMachine().clearAttribute(obj, attr);
    } else {
      getMachine().warn(
          "@clear_attr illegal access to object ${obj}" + " attr: ${attr}");
    }
    nextInstruction();
  }

  /// STORE instruction.
  void _store() {
    final Char varnum = getUnsignedValue(0);
    final Char value = getUnsignedValue(1);
    // Handle stack variable as a special case (standard 1.1)
    if (varnum.toInt() == 0) {
      getMachine().setStackTop(value);
    } else {
      getMachine().setVariable(varnum, value);
    }
    nextInstruction();
  }

  /// INSERT_OBJ instruction.
  void _insert_obj() {
    final int obj = getUnsignedValue(0).toInt();
    final int dest = getUnsignedValue(1).toInt();
    if (obj > 0 && dest > 0) {
      getMachine().insertObject(dest, obj);
    } else {
      getMachine().warn(
          "@insert_obj with object 0 called, obj: ${obj}" + ", dest: ${dest}");
    }
    nextInstruction();
  }

  /// LOADB instruction.
  void _loadb() {
    final int arrayAddress = getUnsignedValue(0).toInt();
    final int index = getUnsignedValue(1).toInt();
    final int memAddress = (arrayAddress + index) & 0xffff;
    storeUnsignedResult(getMachine().readUnsigned8(memAddress));
    nextInstruction();
  }

  /// LOADW instruction.
  void _loadw() {
    final int arrayAddress = getUnsignedValue(0).toInt();
    final int index = getUnsignedValue(1).toInt();
    final int memAddress = (arrayAddress + 2 * index) & 0xffff;
    storeUnsignedResult(getMachine().readUnsigned16(memAddress));
    nextInstruction();
  }

  /// GET_PROP instruction.
  void _get_prop() {
    final int obj = getUnsignedValue(0).toInt();
    final int property = getUnsignedValue(1).toInt();

    if (obj > 0) {
      Char value = getMachine().getProperty(obj, property);
      storeUnsignedResult(value);
    } else {
      getMachine().warn("@get_prop illegal access to object ${obj}");
    }
    nextInstruction();
  }

  /// GET_PROP_ADDR instruction.
  void _get_prop_addr() {
    final int obj = getUnsignedValue(0).toInt();
    final int property = getUnsignedValue(1).toInt();
    if (obj > 0) {
      Char value =
          Char(getMachine().getPropertyAddress(obj, property) & 0xffff);
      storeUnsignedResult(value);
    } else {
      getMachine().warn("@get_prop_addr illegal access to object ${obj}");
    }
    nextInstruction();
  }

  /// GET_NEXT_PROP instruction.
  void _get_next_prop() {
    final int obj = getUnsignedValue(0).toInt();
    final int property = getUnsignedValue(1).toInt();
    Char value = Char(0);
    if (obj > 0) {
      value = Char(getMachine().getNextProperty(obj, property) & 0xffff);
      storeUnsignedResult(value);
      nextInstruction();
    } else {
      // issue warning and continue
      getMachine().warn("@get_next_prop illegal access to object ${obj}");
      nextInstruction();
    }
  }

  /// SET_COLOUR instruction.
  void _set_colour() {
    int window = ScreenModel.CURRENT_WINDOW;
    if (getNumOperands() == 3) {
      window = getSignedValue(2);
    }
    getMachine().getScreen().setForeground(getSignedValue(0), window);
    getMachine().getScreen().setBackground(getSignedValue(1), window);
    nextInstruction();
  }

  /// THROW instruction.
  void _z_throw() {
    final Char returnValue = getUnsignedValue(0);
    final int stackFrame = getUnsignedValue(1).toInt();

    // Unwind the stack
    final int currentStackFrame = getMachine().getRoutineContexts().length - 1;
    if (currentStackFrame < stackFrame) {
      getMachine().halt("@throw from an invalid stack frame state");
    } else {
      // Pop off the routine contexts until the specified stack frame is
      // reached
      final int diff = currentStackFrame - stackFrame;
      for (int i = 0; i < diff; i++) {
        getMachine().returnWith(Char(0));
      }

      // and return with the return value
      returnFromRoutine(returnValue);
    }
  }

  /// Checks if the specified attribute is valid
  bool _isValidAttribute(final int attribute) {
    final int numAttr = getStoryVersion() <= 3 ? 32 : 48;
    return attribute >= 0 && attribute < numAttr;
  }
}

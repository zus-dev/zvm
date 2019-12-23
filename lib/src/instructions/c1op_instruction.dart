import '../../zvm.dart';

/// Implementation of 1OP instructions.
class C1OpInstruction extends AbstractInstruction {
  C1OpInstruction(Machine machine, int opcodeNum, List<Operand> operands,
      Char storeVar, BranchInfo branchInfo, int opcodeLength)
      : super(machine, opcodeNum, operands, storeVar, branchInfo, opcodeLength);

  @override
  OperandCount getOperandCount() {
    return OperandCount.C1OP;
  }

  @override
  void execute() {
    switch (getOpcodeNum()) {
      case Instruction.C1OP_JZ:
        _jz();
        break;
      case Instruction.C1OP_GET_SIBLING:
        _get_sibling();
        break;
      case Instruction.C1OP_GET_CHILD:
        _get_child();
        break;
      case Instruction.C1OP_GET_PARENT:
        _get_parent();
        break;
      case Instruction.C1OP_GET_PROP_LEN:
        _get_prop_len();
        break;
      case Instruction.C1OP_INC:
        _inc();
        break;
      case Instruction.C1OP_DEC:
        _dec();
        break;
      case Instruction.C1OP_PRINT_ADDR:
        _print_addr();
        break;
      case Instruction.C1OP_REMOVE_OBJ:
        _remove_obj();
        break;
      case Instruction.C1OP_PRINT_OBJ:
        _print_obj();
        break;
      case Instruction.C1OP_JUMP:
        _jump();
        break;
      case Instruction.C1OP_RET:
        _ret();
        break;
      case Instruction.C1OP_PRINT_PADDR:
        _print_paddr();
        break;
      case Instruction.C1OP_LOAD:
        _load();
        break;
      case Instruction.C1OP_NOT:
        if (getStoryVersion() <= 4) {
          _not();
        } else {
          _call_1n();
        }
        break;
      case Instruction.C1OP_CALL_1S:
        _call_1s();
        break;
      default:
        throwInvalidOpcode();
    }
  }

  /// INC instruction.
  void _inc() {
    final Char varNum = getUnsignedValue(0);
    final int value = getSignedVarValue(varNum);
    setSignedVarValue(varNum, value + 1);
    nextInstruction();
  }

  /// DEC instruction.
  void _dec() {
    final Char varNum = getUnsignedValue(0);
    final int value = getSignedVarValue(varNum);
    setSignedVarValue(varNum, value - 1);
    nextInstruction();
  }

  /// NOT instruction.
  void _not() {
    final int notvalue = ~getUnsignedValue(0).toInt();
    storeUnsignedResult(Char(notvalue & 0xffff));
    nextInstruction();
  }

  /// JUMP instruction.
  void _jump() {
    getMachine().incrementPC(getSignedValue(0) + 1);
  }

  /// LOAD instruction.
  void _load() {
    final Char varnum = getUnsignedValue(0);
    final Char value = varnum.toInt() == 0
        ? getMachine().getStackTop()
        : getMachine().getVariable(varnum);
    storeUnsignedResult(value);
    nextInstruction();
  }

  /// JZ instruction.
  void _jz() {
    branchOnTest(getUnsignedValue(0).toInt() == 0);
  }

  /// GET_PARENT instruction.
  void _get_parent() {
    final int obj = getUnsignedValue(0).toInt();
    int parent = 0;
    if (obj > 0) {
      parent = getMachine().getParent(obj);
    } else {
      getMachine().warn("@get_parent illegal access to object ${obj}");
    }
    storeUnsignedResult(Char(parent & 0xffff));
    nextInstruction();
  }

  /// GET_SIBLING instruction.
  void _get_sibling() {
    final int obj = getUnsignedValue(0).toInt();
    int sibling = 0;
    if (obj > 0) {
      sibling = getMachine().getSibling(obj);
    } else {
      getMachine().warn("@get_sibling illegal access to object ${obj}");
    }
    storeUnsignedResult(Char(sibling & 0xffff));
    branchOnTest(sibling > 0);
  }

  /// GET_CHILD instruction.
  void _get_child() {
    final int obj = getUnsignedValue(0).toInt();
    int child = 0;
    if (obj > 0) {
      child = getMachine().getChild(obj);
    } else {
      getMachine().warn("@get_child illegal access to object ${obj}");
    }
    storeUnsignedResult(Char(child & 0xffff));
    branchOnTest(child > 0);
  }

  /// PRINT_ADDR instruction.
  void _print_addr() {
    getMachine().printZString(getUnsignedValue(0).toInt());
    nextInstruction();
  }

  /// PRINT_PADDR instruction.
  void _print_paddr() {
    getMachine()
        .printZString(getMachine().unpackStringAddress(getUnsignedValue(0)));
    nextInstruction();
  }

  /// RET instruction.
  void _ret() {
    returnFromRoutine(getUnsignedValue(0));
  }

  /// PRINT_OBJ instruction.
  void _print_obj() {
    final int obj = getUnsignedValue(0).toInt();
    if (obj > 0) {
      getMachine()
          .printZString(getMachine().getPropertiesDescriptionAddress(obj));
    } else {
      getMachine().warn("@print_obj illegal access to object ${obj}");
    }
    nextInstruction();
  }

  /// REMOVE_OBJ instruction.
  void _remove_obj() {
    final int obj = getUnsignedValue(0).toInt();
    if (obj > 0) {
      getMachine().removeObject(obj);
    }
    nextInstruction();
  }

  /// GET_PROP_LEN instruction.
  void _get_prop_len() {
    final int propertyAddress = getUnsignedValue(0).toInt();
    final Char proplen = Char(getMachine().getPropertyLength(propertyAddress));
    storeUnsignedResult(proplen);
    nextInstruction();
  }

  /// CALL_1S instruction.
  void _call_1s() {
    call(0);
  }

  /// CALL_1N instruction.
  void _call_1n() {
    call(0);
  }
}

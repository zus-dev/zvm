import '../../zvm.dart';

/// The revised instruction decoder, a direct port from the Erlang implementation
/// of ZMPP (Schmalz). This decoding scheme is considerably simpler and stores
/// more useful information than the previous one.
class InstructionDecoder implements Serializable {
  static final int _EXTENDED_MASK = 0xbe;
  static final int _VAR_MASK = 0xc0; // 2#11000000
  static final int _SHORT_MASK = 0x80; // 2#10000000
  static final int _LOWER_4_BITS = 0x0f; // 2#00001111
  static final int _LOWER_5_BITS = 0x1f; // 2#00011111
  static final int _LOWER_6_BITS = 0x3f; // 2#00111111
  static final int _BITS_4_5 = 0x30; // 2#00110000
  static final int _BIT_7 = 0x80; // 2#10000000
  static final int _BIT_6 = 0x40; // 2#01000000
  static final int _BIT_5 = 0x20; // 2#00100000
  static final int _LEN_OPCODE = 1;
  static final int _LEN_LONG_OPERANDS = 2;
  static final int _LEN_STORE_VARIABLE = 1;
  static final InstructionInfoDb _INFO_DB = InstructionInfoDb.getInstance();
  static final BranchInfo _DUMMY_BRANCH_INFO = BranchInfo(false, 0, 0, 0);
  static final List<int> _NO_OPERAND_TYPES = List<int>(0);
  static final List<Char> _NO_OPERANDS = List<Char>(0);

  static final int _NUM_OPERAND_TYPES_PER_BYTE = 4;

  static final int _WORD_14_UNSIGNED_MAX = 16383;
  static final int _WORD_14_SIGNED_MAX = 8191;

  Machine _machine;

  /// Initialize decoder with a valid machine object.
  void initialize(Machine machine) {
    _machine = machine;
  }

  /// Decode the instruction at the specified address.
  Instruction decodeInstruction(final int instructionAddress) {
    Instruction instr;
    Char byte1 = _machine.readUnsigned8(instructionAddress);
    InstructionForm form = _getForm(byte1);
    switch (form) {
      case InstructionForm.SHORT:
        instr = _decodeShort(instructionAddress, byte1);
        break;
      case InstructionForm.LONG:
        instr = _decodeLong(instructionAddress, byte1);
        break;
      case InstructionForm.VARIABLE:
        instr = _decodeVariable(instructionAddress, byte1);
        break;
      case InstructionForm.EXTENDED:
        instr = _decodeExtended(instructionAddress);
        break;
      default:
        print("unrecognized form: ${form}");
        break;
    }
    return instr;
  }

  /// Decodes an instruction in int form.
  Instruction _decodeShort(int instrAddress, Char byte1) {
    OperandCount opCount = (byte1 & _BITS_4_5) == _BITS_4_5
        ? OperandCount.C0OP
        : OperandCount.C1OP;
    int opcodeNum = byte1 & _LOWER_4_BITS;
    InstructionInfo info =
        _INFO_DB.getInfo(opCount, opcodeNum, _machine.getVersion());
    if (info == null) {
      print(
        "ILLEGAL SHORT operation, instrAddr: ${toS04x(instrAddress)}, OC: ${opCount}, " +
            "opcode: #${toS02x(opcodeNum)}, Version: ${_machine.getVersion()}\n",
      );
      //infoDb.printKeys();
      throw UnsupportedOperationException("Exit !!");
    }
    int zsciiLength = 0;

    // extract operand
    String str;
    Char operand = Char(0);
    List<int> operandTypes = _NO_OPERAND_TYPES;
    List<Char> operands = _NO_OPERANDS;
    int operandType = _getOperandType(byte1, 1);
    if (info.isPrint()) {
      str = _machine.decode2Zscii(instrAddress + 1, 0);
      zsciiLength = _machine.getNumZEncodedBytes(instrAddress + 1);
    } else {
      operand = _getOperandAt(instrAddress + 1, operandType);
      operandTypes = <int>[operandType];
      operands = <Char>[operand];
    }
    int numOperandBytes = _getOperandLength(operandType);
    int currentAddr = instrAddress + _LEN_OPCODE + numOperandBytes;
    return _createInstruction(opCount, instrAddress, Char(opcodeNum),
        currentAddr, numOperandBytes, zsciiLength, operandTypes, operands, str);
  }

  /// Decodes a long op count instruction.
  Instruction _decodeLong(int instrAddress, Char byte1) {
    Char opcodeNum = Char(byte1 & _LOWER_5_BITS);

    // extract long operands
    int operandType1 = (byte1 & _BIT_6) != 0
        ? Operand.TYPENUM_VARIABLE
        : Operand.TYPENUM_SMALL_CONSTANT;
    int operandType2 = (byte1 & _BIT_5) != 0
        ? Operand.TYPENUM_VARIABLE
        : Operand.TYPENUM_SMALL_CONSTANT;
    Char operand1 = _machine.readUnsigned8(instrAddress + 1);
    Char operand2 = _machine.readUnsigned8(instrAddress + 2);
    int numOperandBytes = _LEN_LONG_OPERANDS;
    int currentAddr = instrAddress + _LEN_OPCODE + _LEN_LONG_OPERANDS;
    //System.out.printf("InstructionForm.LONG 2OP, opnum: %d, byte1: %d, addr: $%04x\n",
    //        (int) opcodeNum, (int) byte1, instrAddress);
    return _createInstruction(
        OperandCount.C2OP,
        instrAddress,
        opcodeNum,
        currentAddr,
        numOperandBytes,
        0,
        <int>[operandType1, operandType2],
        <Char>[operand1, operand2],
        null);
  }

  /// Decodes an instruction in variable form.
  Instruction _decodeVariable(int instrAddress, Char byte1) {
    OperandCount opCount =
        (byte1 & _BIT_5) != 0 ? OperandCount.VAR : OperandCount.C2OP;
    Char opcodeNum = Char(byte1.toInt() & _LOWER_5_BITS);
    int opTypesOffset;
    List<int> operandTypes;
    // The only instruction taking up to 8 parameters is CALL_VS2
    if (_isVx2(opCount, opcodeNum)) {
      operandTypes = _joinArrays(
          _extractOperandTypes(_machine.readUnsigned8(instrAddress + 1)),
          _extractOperandTypes(_machine.readUnsigned8(instrAddress + 2)));
      opTypesOffset = 3;
    } else {
      operandTypes =
          _extractOperandTypes(_machine.readUnsigned8(instrAddress + 1));
      opTypesOffset = 2;
    }
    return _decodeVarInstruction(instrAddress, opCount, opcodeNum, operandTypes,
        opTypesOffset - 1, opTypesOffset, false);
  }

  /// Determines whether the instruction is a CALL_VS2 or CALL_VN2.
  bool _isVx2(OperandCount opCount, Char opcodeNum) {
    return opCount == OperandCount.VAR &&
        (opcodeNum.toInt() == Instruction.VAR_CALL_VN2 ||
            opcodeNum.toInt() == Instruction.VAR_CALL_VS2);
  }

  /// Join two int arrays which are not null.
  List<int> _joinArrays(List<int> arr1, List<int> arr2) {
    List<int> result = List<int>(arr1.length + arr2.length);
    arraycopy(arr1, 0, result, 0, arr1.length);
    arraycopy(arr2, 0, result, arr1.length, arr2.length);
    return result;
  }

  /// Decodes an instruction in extended form. Is really just a variation of
  /// variable form and delegates to decodeVarInstruction.
  Instruction _decodeExtended(int instrAddress) {
    return _decodeVarInstruction(
        instrAddress,
        OperandCount.EXT,
        _machine.readUnsigned8(instrAddress + 1),
        _extractOperandTypes(_machine.readUnsigned8(instrAddress + 2)),
        1,
        3,
        true);
  }

  /// Decode VAR form instruction.
  Instruction _decodeVarInstruction(
      int instrAddress,
      OperandCount opCount,
      Char opcodeNum,
      List<int> operandTypes,
      int numOperandTypeBytes,
      int opTypesOffset,
      bool isExtended) {
    List<Char> operands =
        _extractOperands(instrAddress + opTypesOffset, operandTypes);
    int numOperandBytes = _getNumOperandBytes(operandTypes);
    // it is important to note that extended instructions have an extra byte
    // since the first byte is always $be
    int numExtraOpcodeBytes = isExtended ? 1 : 0;
    int currentAddr = instrAddress + opTypesOffset + numOperandBytes;
    return _createInstruction(
        opCount,
        instrAddress,
        opcodeNum,
        currentAddr,
        numExtraOpcodeBytes + numOperandBytes + numOperandTypeBytes,
        0,
        operandTypes,
        operands,
        null);
  }

  /// The generic part of instruction decoding, extracting store variable
  /// and branch offset is always the same for all instruction forms.
  Instruction _createInstruction(
      OperandCount opCount,
      int instrAddress,
      Char opcodeNum,
      int addrAfterOperands,
      int numOperandBytes,
      int zsciiLength,
      List<int> operandTypes,
      List<Char> operands,
      String str) {
    int currentAddr = addrAfterOperands;
    int storeVarLen = 0;
    Char storeVar = Char(0);
    List<Operand> instrOperands = _createOperands(operandTypes, operands);
    InstructionInfo info =
        _INFO_DB.getInfo(opCount, opcodeNum.toInt(), _machine.getVersion());
    if (info == null) {
      print(
        "ILLEGAL operation, instrAddr: ${toS04x(instrAddress)} OC: ${opCount}, " +
            "opcode: #${toS02x(opcodeNum.toInt())}, Version: ${_machine.getVersion()}\n",
      );
      throw UnsupportedOperationException("Exit !!");
    }
    if (info.isStore()) {
      storeVar = _machine.readUnsigned8(currentAddr);
      currentAddr++;
      storeVarLen = _LEN_STORE_VARIABLE;
    }
    BranchInfo branchInfo = _DUMMY_BRANCH_INFO;
    if (info.isBranch()) {
      branchInfo = _getBranchInfo(currentAddr);
    }
    int opcodeLength = _LEN_OPCODE +
        numOperandBytes +
        storeVarLen +
        branchInfo.numOffsetBytes +
        zsciiLength;
    //System.out.printf("OPCODELEN: %d, len opcode: %d, # operand bytes: %d, " +
    //                  "len storevar: %d, broffsetbytes: %d, zsciilen: %d\n",
    //                  opcodeLength, LEN_OPCODE, numOperandBytes, storeVarLen,
    //                  branchInfo.numOffsetBytes, zsciiLength);
    switch (opCount) {
      case OperandCount.C0OP:
        return C0OpInstruction(_machine, opcodeNum.toInt(), instrOperands, str,
            storeVar, branchInfo, opcodeLength);
      case OperandCount.C1OP:
        return C1OpInstruction(_machine, opcodeNum.toInt(), instrOperands,
            storeVar, branchInfo, opcodeLength);
      case OperandCount.C2OP:
        return C2OpInstruction(_machine, opcodeNum.toInt(), instrOperands,
            storeVar, branchInfo, opcodeLength);
      case OperandCount.VAR:
        return VarInstruction(_machine, opcodeNum.toInt(), instrOperands,
            storeVar, branchInfo, opcodeLength);
      case OperandCount.EXT:
        return ExtInstruction(_machine, opcodeNum.toInt(), instrOperands,
            storeVar, branchInfo, opcodeLength);
      default:
        break;
    }
    return null;
  }

  /// Create operands objects.
  List<Operand> _createOperands(List<int> operandTypes, List<Char> operands) {
    List<Operand> result = List<Operand>(operandTypes.length);
    for (int i = 0; i < operandTypes.length; i++) {
      result[i] = Operand(operandTypes[i], operands[i]);
    }
    return result;
  }

  // ************************************************************************
  // ***** Helper functions
  // ********************************

  /// Extracts operand types.
  List<int> _extractOperandTypes(Char opTypeByte) {
    List<int> opTypes = List<int>(_NUM_OPERAND_TYPES_PER_BYTE);
    int numTypes;
    for (numTypes = 0; numTypes < _NUM_OPERAND_TYPES_PER_BYTE; numTypes++) {
      int opType = _getOperandType(opTypeByte, numTypes);
      if (opType == Operand.TYPENUM_OMITTED) break;
      opTypes[numTypes] = opType;
    }
    List<int> result = List<int>(numTypes);
    for (int i = 0; i < numTypes; i++) {
      result[i] = opTypes[i];
    }
    return result;
  }

  /// Extract operands.
  List<Char> _extractOperands(int operandAddr, List<int> operandTypes) {
    List<Char> result = List<Char>(operandTypes.length);
    int currentAddr = operandAddr;
    for (int i = 0; i < operandTypes.length; i++) {
      if (operandTypes[i] == Operand.TYPENUM_LARGE_CONSTANT) {
        result[i] = _machine.readUnsigned16(currentAddr);
        currentAddr += 2;
      } else {
        result[i] = _machine.readUnsigned8(currentAddr);
        currentAddr++;
      }
    }
    return result;
  }

  /// Returns total number of operand bytes.
  int _getNumOperandBytes(List<int> operandTypes) {
    int result = 0;
    for (int i = 0; i < operandTypes.length; i++) {
      result += operandTypes[i] == Operand.TYPENUM_LARGE_CONSTANT ? 2 : 1;
    }
    return result;
  }

  /// Extracts the operand type at the specified position of the op type byte.
  int _getOperandType(Char opTypeByte, int pos) {
    return (zeroFillRightShift(opTypeByte.toInt(), (6 - pos * 2)) & 0x03);
  }

  /// Extract the branch information at the specified address
  BranchInfo _getBranchInfo(int branchInfoAddr) {
    Char branchByte1 = _machine.readUnsigned8(branchInfoAddr);
    bool branchOnTrue = (branchByte1 & _BIT_7) != 0;
    int numOffsetBytes = 0;
    int branchOffset = 0;
    if (_isSimpleOffset(branchByte1)) {
      numOffsetBytes = 1;
      branchOffset = branchByte1 & _LOWER_6_BITS;
    } else {
      numOffsetBytes = 2;
      Char branchByte2 = _machine.readUnsigned8(branchInfoAddr + 1);
      //System.out.printf("14 Bit offset, bracnh byte1: %02x byte2: %02x\n",
      //                  (int) branchByte1, (int) branchByte2);
      branchOffset = _toSigned14(
          Char(((branchByte1.toInt() << 8) | branchByte2.toInt()) & 0x3fff));
    }
    return BranchInfo(branchOnTrue, numOffsetBytes,
        branchInfoAddr + numOffsetBytes, branchOffset);
  }

  /// Determines whether the branch is a simple or compound (2 byte) offset.
  bool _isSimpleOffset(Char branchByte1) {
    return (branchByte1 & _BIT_6) != 0;
  }

  /// Helper function to extract a 14 bit signed branch offset.
  int _toSigned14(Char value) {
    return (value.toInt() > _WORD_14_SIGNED_MAX
        ? -(_WORD_14_UNSIGNED_MAX - (value.toInt() - 1))
        : value.toInt());
  }

  /// Returns the operand at the specified address.
  Char _getOperandAt(int operandAddress, int operandType) {
    return operandType == Operand.TYPENUM_LARGE_CONSTANT
        ? _machine.readUnsigned16(operandAddress)
        : _machine.readUnsigned8(operandAddress);
  }

  /// Determines the operand length of a specified type in bytes.
  int _getOperandLength(int operandType) {
    switch (operandType) {
      case Operand.TYPENUM_SMALL_CONSTANT:
        return 1;
      case Operand.TYPENUM_LARGE_CONSTANT:
        return 2;
      case Operand.TYPENUM_VARIABLE:
        return 1;
      default:
        return 0;
    }
  }

  /// Determine the instruction form from the first instruction byte.
  InstructionForm _getForm(Char byte1) {
    if (byte1.toInt() == _EXTENDED_MASK) return InstructionForm.EXTENDED;
    if ((byte1 & _VAR_MASK) == _VAR_MASK) return InstructionForm.VARIABLE;
    if ((byte1 & _SHORT_MASK) == _SHORT_MASK) return InstructionForm.SHORT;
    return InstructionForm.LONG;
  }
}

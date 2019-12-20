import '../../zvm.dart';

/// Information structure about the instruction.
class InstructionInfo {
  String _name;
  bool _isStore = false;
  bool _isBranch = false;
  bool _isPrint = false;
  bool _isOutput = false;

  InstructionInfo(
      String name, bool isBranch, bool isStore, bool isPrint, bool isOutput) {
    _name = name;
    _isBranch = isBranch;
    _isStore = isStore;
    _isPrint = isPrint;
    _isOutput = isOutput;
  }

  /// Determine whether this InstructionInfo represents a store.
  bool isStore() {
    return _isStore;
  }

  /// Determine whether this InstructionInfo represents a branch.
  bool isBranch() {
    return _isBranch;
  }

  /// Determine whether this InstructionInfo represents a print instruction.
  bool isPrint() {
    return _isPrint;
  }

  /// Determine whether this InstructionInfo represents an output instruction.
  bool isOutput() {
    return _isOutput;
  }

  /// Returns the opcode name.
  String getName() {
    return _name;
  }
}

/// This is the new representation for the information about instructions in
/// the Z-machine. As opposed to the old xStaticInfo classes, this is a database
/// containing all the information. It can be regarded as static configuration
/// which is compiled into the application.
class InstructionInfoDb {
  // Commonly used version ranges
  static final List<int> ALL_VERSIONS = [1, 2, 3, 4, 5, 6, 7, 8];
  static final List<int> EXCEPT_V6 = [1, 2, 3, 4, 5, 7, 8];
  static final List<int> V1_TO_V3 = [1, 2, 3];
  static final List<int> V1_TO_V4 = [1, 2, 3, 4];
  static final List<int> V5_TO_V8 = [5, 6, 7, 8];
  static final List<int> V3_TO_V8 = [3, 4, 5, 6, 7, 8];
  static final List<int> V4_TO_V8 = [4, 5, 6, 7, 8];
  static final List<int> V3 = [3];
  static final List<int> V4 = [4];
  static final List<int> V6 = [6];

  /// The hashmap to represent the database
  Map<String, InstructionInfo> _infoMap = Map<String, InstructionInfo>();

  /// Creates standard InstructionInfo object.
  InstructionInfo _info(String name) {
    return InstructionInfo(name, false, false, false, false);
  }

  /// Creates branch-and-store InstructionInfo object.
  InstructionInfo _branch_and_store(String name) {
    return InstructionInfo(name, true, true, false, false);
  }

  /// Creates store InstructionInfo object.
  InstructionInfo _store(String name) {
    return InstructionInfo(name, false, true, false, false);
  }

  /// Creates branch InstructionInfo object.
  InstructionInfo _branch(String name) {
    return InstructionInfo(name, true, false, false, false);
  }

  /// Creates print InstructionInfo object.
  InstructionInfo _print(String name) {
    return InstructionInfo(name, false, false, true, true);
  }

  /// Creates output InstructionInfo object.
  InstructionInfo _output(String name) {
    return InstructionInfo(name, false, false, false, true);
  }

  /// Private constructor.
  InstructionInfoDb._() {
    // 0OP
    _add_0OP(_info("RTRUE"), Instruction.C0OP_RTRUE);
    _add_0OP(_info("RFALSE"), Instruction.C0OP_RFALSE);
    _add_0OP(_print("PRINT"), Instruction.C0OP_PRINT);
    _add_0OP(_print("PRINT_RET"), Instruction.C0OP_PRINT_RET);
    _add_0OP(_info("NOP"), Instruction.C0OP_NOP);
    _add_0OP(_branch("SAVE"), Instruction.C0OP_SAVE, V1_TO_V3);
    _add_0OP(_branch("RESTORE"), Instruction.C0OP_RESTORE, V1_TO_V3);
    _add_0OP(_store("SAVE"), Instruction.C0OP_SAVE, V4);
    _add_0OP(_store("RESTORE"), Instruction.C0OP_RESTORE, V4);
    _add_0OP(_info("RESTART"), Instruction.C0OP_RESTART);
    _add_0OP(_info("RET_POPPED"), Instruction.C0OP_RET_POPPED);
    _add_0OP(_info("POP"), Instruction.C0OP_POP, V1_TO_V4);
    _add_0OP(_store("CATCH"), Instruction.C0OP_CATCH, V5_TO_V8);
    _add_0OP(_info("QUIT"), Instruction.C0OP_QUIT);
    _add_0OP(_output("NEW_LINE"), Instruction.C0OP_NEW_LINE);
    _add_0OP(_info("SHOW_STATUS"), Instruction.C0OP_SHOW_STATUS, V3);
    _add_0OP(_branch("VERIFY"), Instruction.C0OP_VERIFY, V3_TO_V8);
    _add_0OP(_info("PIRACY"), Instruction.C0OP_PIRACY, V5_TO_V8);

    // 1OP
    _add_C1OP(_branch("JZ"), Instruction.C1OP_JZ);
    _add_C1OP(_branch_and_store("GET_SIBLING"), Instruction.C1OP_GET_SIBLING);
    _add_C1OP(_branch_and_store("GET_CHILD"), Instruction.C1OP_GET_CHILD);
    _add_C1OP(_store("GET_PARENT"), Instruction.C1OP_GET_PARENT);
    _add_C1OP(_store("GET_PROP_LEN"), Instruction.C1OP_GET_PROP_LEN);
    _add_C1OP(_info("INC"), Instruction.C1OP_INC);
    _add_C1OP(_info("DEC"), Instruction.C1OP_DEC);
    _add_C1OP(_output("PRINT_ADDR"), Instruction.C1OP_PRINT_ADDR);
    _add_C1OP(_store("CALL_1S"), Instruction.C1OP_CALL_1S, V4_TO_V8);
    _add_C1OP(_info("REMOVE_OBJ"), Instruction.C1OP_REMOVE_OBJ);
    _add_C1OP(_output("PRINT_OBJ"), Instruction.C1OP_PRINT_OBJ);
    _add_C1OP(_info("RET"), Instruction.C1OP_RET);
    _add_C1OP(_info("JUMP"), Instruction.C1OP_JUMP);
    _add_C1OP(_output("PRINT_PADDR"), Instruction.C1OP_PRINT_PADDR);
    _add_C1OP(_store("LOAD"), Instruction.C1OP_LOAD);
    _add_C1OP(_store("NOT"), Instruction.C1OP_NOT, V1_TO_V4);
    _add_C1OP(_info("CALL_1N"), Instruction.C1OP_CALL_1N, V5_TO_V8);

    // 2OP
    _add_C2OP(_branch("JE"), Instruction.C2OP_JE);
    _add_C2OP(_branch("JL"), Instruction.C2OP_JL);
    _add_C2OP(_branch("JG"), Instruction.C2OP_JG);
    _add_C2OP(_branch("DEC_CHK"), Instruction.C2OP_DEC_CHK);
    _add_C2OP(_branch("INC_CHK"), Instruction.C2OP_INC_CHK);
    _add_C2OP(_branch("JIN"), Instruction.C2OP_JIN);
    _add_C2OP(_branch("TEST"), Instruction.C2OP_TEST);
    _add_C2OP(_store("OR"), Instruction.C2OP_OR);
    _add_C2OP(_store("AND"), Instruction.C2OP_AND);
    _add_C2OP(_branch("TEST_ATTR"), Instruction.C2OP_TEST_ATTR);
    _add_C2OP(_info("SET_ATTR"), Instruction.C2OP_SET_ATTR);
    _add_C2OP(_info("CLEAR_ATTR"), Instruction.C2OP_CLEAR_ATTR);
    _add_C2OP(_info("STORE"), Instruction.C2OP_STORE);
    _add_C2OP(_info("INSERT_OBJ"), Instruction.C2OP_INSERT_OBJ);
    _add_C2OP(_store("LOADW"), Instruction.C2OP_LOADW);
    _add_C2OP(_store("LOADB"), Instruction.C2OP_LOADB);
    _add_C2OP(_store("GET_PROP"), Instruction.C2OP_GET_PROP);
    _add_C2OP(_store("GET_PROP_ADDR"), Instruction.C2OP_GET_PROP_ADDR);
    _add_C2OP(_store("GET_NEXT_PROP"), Instruction.C2OP_GET_NEXT_PROP);
    _add_C2OP(_store("ADD"), Instruction.C2OP_ADD);
    _add_C2OP(_store("SUB"), Instruction.C2OP_SUB);
    _add_C2OP(_store("MUL"), Instruction.C2OP_MUL);
    _add_C2OP(_store("DIV"), Instruction.C2OP_DIV);
    _add_C2OP(_store("MOD"), Instruction.C2OP_MOD);
    _add_C2OP(_store("CALL_2S"), Instruction.C2OP_CALL_2S, V4_TO_V8);
    _add_C2OP(_info("CALL_2N"), Instruction.C2OP_CALL_2N, V5_TO_V8);
    _add_C2OP(_info("SET_COLOUR"), Instruction.C2OP_SET_COLOUR, V5_TO_V8);
    _add_C2OP(_info("THROW"), Instruction.C2OP_THROW, V5_TO_V8);

    // VAR
    _add_VAR(_store("CALL"), Instruction.VAR_CALL, V1_TO_V3);
    _add_VAR(_store("CALL_VS"), Instruction.VAR_CALL_VS, V4_TO_V8);
    _add_VAR(_info("STOREW"), Instruction.VAR_STOREW);
    _add_VAR(_info("STOREB"), Instruction.VAR_STOREB);
    _add_VAR(_info("PUT_PROP"), Instruction.VAR_PUT_PROP);
    _add_VAR(_info("SREAD"), Instruction.VAR_SREAD, V1_TO_V4);
    _add_VAR(_store("AREAD"), Instruction.VAR_AREAD, V5_TO_V8);
    _add_VAR(_output("PRINT_CHAR"), Instruction.VAR_PRINT_CHAR);
    _add_VAR(_output("PRINT_NUM"), Instruction.VAR_PRINT_NUM);
    _add_VAR(_store("RANDOM"), Instruction.VAR_RANDOM);
    _add_VAR(_info("PUSH"), Instruction.VAR_PUSH);
    _add_VAR(_info("PULL"), Instruction.VAR_PULL, EXCEPT_V6);
    _add_VAR(_store("PULL"), Instruction.VAR_PULL, V6);
    _add_VAR(_output("SPLIT_WINDOW"), Instruction.VAR_SPLIT_WINDOW, V3_TO_V8);
    _add_VAR(_info("SET_WINDOW"), Instruction.VAR_SET_WINDOW, V3_TO_V8);
    _add_VAR(_store("CALL_VS2"), Instruction.VAR_CALL_VS2, V4_TO_V8);
    _add_VAR(_output("ERASE_WINDOW"), Instruction.VAR_ERASE_WINDOW, V4_TO_V8);
    _add_VAR(_output("ERASE_LINE"), Instruction.VAR_ERASE_LINE, V4_TO_V8);
    _add_VAR(_info("SET_CURSOR"), Instruction.VAR_SET_CURSOR, V4_TO_V8);
    _add_VAR(_info("GET_CURSOR"), Instruction.VAR_GET_CURSOR, V4_TO_V8);
    _add_VAR(_info("SET_TEXT_STYLE"), Instruction.VAR_SET_TEXT_STYLE, V4_TO_V8);
    _add_VAR(_info("BUFFER_MODE"), Instruction.VAR_BUFFER_MODE, V4_TO_V8);
    _add_VAR(_info("OUTPUT_STREAM"), Instruction.VAR_OUTPUT_STREAM, V3_TO_V8);
    _add_VAR(_info("INPUT_STREAM"), Instruction.VAR_INPUT_STREAM, V3_TO_V8);
    _add_VAR(_info("SOUND_EFFECT"), Instruction.VAR_SOUND_EFFECT, V3_TO_V8);
    _add_VAR(_store("READ_CHAR"), Instruction.VAR_READ_CHAR, V4_TO_V8);
    _add_VAR(
        _branch_and_store("SCAN_TABLE"), Instruction.VAR_SCAN_TABLE, V4_TO_V8);
    _add_VAR(_store("NOT"), Instruction.VAR_NOT, V5_TO_V8);
    _add_VAR(_info("CALL_VN"), Instruction.VAR_CALL_VN, V5_TO_V8);
    _add_VAR(_info("CALL_VN2"), Instruction.VAR_CALL_VN2, V5_TO_V8);
    _add_VAR(_info("TOKENISE"), Instruction.VAR_TOKENISE, V5_TO_V8);
    _add_VAR(_info("ENCODE_TEXT"), Instruction.VAR_ENCODE_TEXT, V5_TO_V8);
    _add_VAR(_info("COPY_TABLE"), Instruction.VAR_COPY_TABLE, V5_TO_V8);
    _add_VAR(_output("PRINT_TABLE"), Instruction.VAR_PRINT_TABLE, V5_TO_V8);
    _add_VAR(
        _branch("CHECK_ARG_COUNT"), Instruction.VAR_CHECK_ARG_COUNT, V5_TO_V8);

    // EXT
    _add_EXT(_store("SAVE"), Instruction.EXT_SAVE, V5_TO_V8);
    _add_EXT(_store("RESTORE"), Instruction.EXT_RESTORE, V5_TO_V8);
    _add_EXT(_store("LOG_SHIFT"), Instruction.EXT_LOG_SHIFT, V5_TO_V8);
    _add_EXT(_store("ART_SHIFT"), Instruction.EXT_ART_SHIFT, V5_TO_V8);
    _add_EXT(_store("SET_FONT"), Instruction.EXT_SET_FONT, V5_TO_V8);
    _add_EXT(_output("DRAW_PICTURE"), Instruction.EXT_DRAW_PICTURE, V6);
    _add_EXT(_branch("PICTURE_DATA"), Instruction.EXT_PICTURE_DATA, V6);
    _add_EXT(_output("ERASE_PICTURE"), Instruction.EXT_ERASE_PICTURE, V6);
    _add_EXT(_info("SET_MARGINS"), Instruction.EXT_SET_MARGINS, V6);
    _add_EXT(_store("SAVE_UNDO"), Instruction.EXT_SAVE_UNDO, V5_TO_V8);
    _add_EXT(_store("RESTORE_UNDO"), Instruction.EXT_RESTORE_UNDO, V5_TO_V8);
    _add_EXT(_output("PRINT_UNICODE"), Instruction.EXT_PRINT_UNICODE, V5_TO_V8);
    _add_EXT(_info("CHECK_UNICODE"), Instruction.EXT_CHECK_UNICODE, V5_TO_V8);
    _add_EXT(_output("MOVE_WINDOW"), Instruction.EXT_MOVE_WINDOW, V6);
    _add_EXT(_info("WINDOW_SIZE"), Instruction.EXT_WINDOW_SIZE, V6);
    _add_EXT(_info("WINDOW_STYLE"), Instruction.EXT_WINDOW_STYLE, V6);
    _add_EXT(_store("GET_WIND_PROP"), Instruction.EXT_GET_WIND_PROP, V6);
    _add_EXT(_output("SCROLL_WINDOW"), Instruction.EXT_SCROLL_WINDOW, V6);
    _add_EXT(_info("POP_STACK"), Instruction.EXT_POP_STACK, V6);
    _add_EXT(_info("READ_MOUSE"), Instruction.EXT_READ_MOUSE, V6);
    _add_EXT(_info("MOUSE_WINDOW"), Instruction.EXT_MOUSE_WINDOW, V6);
    _add_EXT(_branch("PUSH_STACK"), Instruction.EXT_PUSH_STACK, V6);
    _add_EXT(_info("PUT_WIND_PROP"), Instruction.EXT_PUT_WIND_PROP, V6);
    _add_EXT(_output("PRINT_FORM"), Instruction.EXT_PRINT_FORM, V6);
    _add_EXT(_branch("MAKE_MENU"), Instruction.EXT_MAKE_MENU, V6);
    _add_EXT(_info("PICTURE_TABLE"), Instruction.EXT_PICTURE_TABLE, V6);
  }

  /// Adds the specified info struct for all Z-machine versions.
  void _add_0OP(InstructionInfo info, int opcodeNum, [List<int> versions]) {
    _addInfo(info, OperandCount.C0OP, opcodeNum, versions ?? ALL_VERSIONS);
  }

  void _add_C1OP(InstructionInfo info, int opcodeNum, [List<int> versions]) {
    _addInfo(info, OperandCount.C1OP, opcodeNum, versions ?? ALL_VERSIONS);
  }

  void _add_C2OP(InstructionInfo info, int opcodeNum, [List<int> versions]) {
    _addInfo(info, OperandCount.C2OP, opcodeNum, versions ?? ALL_VERSIONS);
  }

  void _add_VAR(InstructionInfo info, int opcodeNum, [List<int> versions]) {
    _addInfo(info, OperandCount.VAR, opcodeNum, versions ?? ALL_VERSIONS);
  }

  void _add_EXT(InstructionInfo info, int opcodeNum, [List<int> versions]) {
    _addInfo(info, OperandCount.EXT, opcodeNum, versions ?? ALL_VERSIONS);
  }

  /// Adds the specified InstructionInfo for the specified Z-machine versions.
  void _addInfo(InstructionInfo info, OperandCount opCount, int opcodeNum,
      List<int> versions) {
    for (int version in versions) {
      _infoMap[createKey(opCount, opcodeNum, version)] = info;
    }
  }

  static InstructionInfoDb _instance = InstructionInfoDb._();

  /// Returns the Singleton instance of the database.
  static InstructionInfoDb getInstance() {
    return _instance;
  }

  /// Creates the hash key for the specified instruction information.
  String createKey(OperandCount opCount, int opcodeNum, int version) {
    return opCount.toString() + ":${opcodeNum}:${version}";
  }

  /// Returns the information struct for the specified instruction.
  InstructionInfo getInfo(OperandCount opCount, int opcodeNum, int version) {
    // print("GENERATING KEY: " + createKey(opCount, opcodeNum, version));
    return _infoMap[createKey(opCount, opcodeNum, version)];
  }

  /// Determines if the specified operation is valid.
  bool isValid(OperandCount opCount, int opcodeNum, int version) {
    return _infoMap.containsKey(createKey(opCount, opcodeNum, version));
  }

  /// Prints the keys in the info map.
  void printKeys() {
    print("INFO MAP KEYS: ");
    for (String key in _infoMap.keys) {
      if (key.startsWith("C1OP:0")) print(key);
    }
  }
}

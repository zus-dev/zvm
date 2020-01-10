import '../../zvm.dart';

/// Implementation of instructions with operand count VAR.
class VarInstruction extends AbstractInstruction {
  static final Logger _LOG = Logger.getLogger("org.zmpp");

  VarInstruction(Machine machine, int opcodeNum, List<Operand> operands,
      Char storeVar, BranchInfo branchInfo, int opcodeLength)
      : super(machine, opcodeNum, operands, storeVar, branchInfo, opcodeLength);

  @override
  OperandCount getOperandCount() {
    return OperandCount.VAR;
  }

  @override
  void execute() {
    switch (getOpcodeNum()) {
      case Instruction.VAR_CALL:
        _call();
        break;
      case Instruction.VAR_CALL_VS2:
        _call();
        break;
      case Instruction.VAR_STOREW:
        _storew();
        break;
      case Instruction.VAR_STOREB:
        _storeb();
        break;
      case Instruction.VAR_PUT_PROP:
        _put_prop();
        break;
      case Instruction.VAR_SREAD:
        _sread();
        break;
      case Instruction.VAR_PRINT_CHAR:
        _print_char();
        break;
      case Instruction.VAR_PRINT_NUM:
        _print_num();
        break;
      case Instruction.VAR_RANDOM:
        _random();
        break;
      case Instruction.VAR_PUSH:
        _push();
        break;
      case Instruction.VAR_PULL:
        _pull();
        break;
      case Instruction.VAR_SPLIT_WINDOW:
        _split_window();
        break;
      case Instruction.VAR_SET_TEXT_STYLE:
        _set_text_style();
        break;
      case Instruction.VAR_BUFFER_MODE:
        _buffer_mode();
        break;
      case Instruction.VAR_SET_WINDOW:
        _set_window();
        break;
      case Instruction.VAR_OUTPUT_STREAM:
        _output_stream();
        break;
      case Instruction.VAR_INPUT_STREAM:
        _input_stream();
        break;
      case Instruction.VAR_SOUND_EFFECT:
        _sound_effect();
        break;
      case Instruction.VAR_ERASE_WINDOW:
        _erase_window();
        break;
      case Instruction.VAR_ERASE_LINE:
        _erase_line();
        break;
      case Instruction.VAR_SET_CURSOR:
        _set_cursor();
        break;
      case Instruction.VAR_GET_CURSOR:
        _get_cursor();
        break;
      case Instruction.VAR_READ_CHAR:
        _read_char();
        break;
      case Instruction.VAR_SCAN_TABLE:
        _scan_table();
        break;
      case Instruction.VAR_NOT:
        _not();
        break;
      case Instruction.VAR_CALL_VN:
      case Instruction.VAR_CALL_VN2:
        _call();
        break;
      case Instruction.VAR_TOKENISE:
        _tokenise();
        break;
      case Instruction.VAR_ENCODE_TEXT:
        _encode_text();
        break;
      case Instruction.VAR_COPY_TABLE:
        _copy_table();
        break;
      case Instruction.VAR_PRINT_TABLE:
        _print_table();
        break;
      case Instruction.VAR_CHECK_ARG_COUNT:
        _check_arg_count();
        break;
      default:
        throwInvalidOpcode();
    }
  }

  /// CALL instruction.
  void _call() {
    call(getNumOperands() - 1);
  }

  /// STOREW instruction.
  void _storew() {
    final int array = getUnsignedValue(0).toInt();
    final int wordIndex = getSignedValue(1);
    final int memAddress = (array + 2 * wordIndex) & 0xffff;
    final Char value = getUnsignedValue(2);
    getMachine().writeUnsigned16(memAddress, value);
    nextInstruction();
  }

  /// STOREB instruction.
  void _storeb() {
    final int array = getUnsignedValue(0).toInt();
    final int byteIndex = getSignedValue(1);
    final int memAddress = (array + byteIndex) & 0xffff;
    final int value = getUnsignedValue(2).toInt();
    getMachine().writeUnsigned8(memAddress, Char(value & 0xff));
    nextInstruction();
  }

  /// PUT_PROP instruction.
  void _put_prop() {
    final int obj = getUnsignedValue(0).toInt();
    final int property = getUnsignedValue(1).toInt();
    final Char value = getUnsignedValue(2);

    if (obj > 0) {
      getMachine().setProperty(obj, property, value);
      nextInstruction();
    } else {
      // Issue warning for non-existent object
      getMachine().warn("@put_prop illegal access to object ${obj}");
      nextInstruction();
    }
  }

  /// PRINT_CHAR instruction.
  void _print_char() {
    final Char zChar = getUnsignedValue(0);
    getMachine().printZsciiChar(zChar);
    nextInstruction();
  }

  /// PRINT_NUM instruction.
  void _print_num() {
    final int number = getSignedValue(0).toInt();
    getMachine().printNumber(number);
    nextInstruction();
  }

  /// PUSH instruction.
  void _push() {
    final Char value = getUnsignedValue(0);
    getMachine().setVariable(Char(0), value);
    nextInstruction();
  }

  /// PULL instruction.
  void _pull() {
    if (getStoryVersion() == 6) {
      _pull_v6();
    } else {
      _pull_std();
    }
    nextInstruction();
  }

  /// PULL instruction for version 6 stories.
  void _pull_v6() {
    Char stack = Char(0);
    if (getNumOperands() == 1) {
      stack = getUnsignedValue(0);
    }
    storeUnsignedResult(getMachine().popStack(stack));
  }

  /// PULL instruction for stories except V6.
  void _pull_std() {
    final Char varnum = getUnsignedValue(0);
    final Char value = getMachine().getVariable(Char(0));

    // standard 1.1
    if (varnum.toInt() == 0) {
      getMachine().setStackTop(value);
    } else {
      getMachine().setVariable(varnum, value);
    }
  }

  /// OUTPUT_STREAM instruction.
  void _output_stream() {
    // Stream number should be a signed byte
    final int streamnumber = getSignedValue(0);

    if (streamnumber < 0 && streamnumber >= -3) {
      getMachine().selectOutputStream(-streamnumber, false);
    } else if (streamnumber > 0 && streamnumber <= 3) {
      if (streamnumber == Output.OUTPUTSTREAM_MEMORY) {
        final int tableAddress = getUnsignedValue(1).toInt();
        int tablewidth = 0;
        if (getNumOperands() == 3) {
          tablewidth = getUnsignedValue(2).toInt();
          _LOG.info(
              "@output_stream 3 ${toHexStr(tableAddress)} ${tablewidth}\n");
        }
        getMachine().selectOutputStream3(tableAddress, tablewidth);
      } else {
        getMachine().selectOutputStream(streamnumber, true);
      }
    }
    nextInstruction();
  }

  /// INPUT_STREAM instruction.
  void _input_stream() {
    getMachine().selectInputStream(getUnsignedValue(0).toInt());
    nextInstruction();
  }

  /// RANDOM instruction.
  void _random() {
    final int range = getSignedValue(0);
    storeUnsignedResult(getMachine().random(range));
    nextInstruction();
  }

  /// SREAD instruction.
  void _sread() {
    if (getMachine().getRunState() == MachineRunState.RUNNING) {
      _sreadStage1();
    } else {
      _sreadStage2();
    }
  }

  /// First stage of SREAD.
  void _sreadStage1() {
    Char textbuffer = getUnsignedValue(0);
    getMachine().setRunState(MachineRunState.createReadLine(
        _getReadInterruptTime(),
        _getReadInterruptRoutine(),
        _getNumLeftOverChars(textbuffer),
        textbuffer));
  }

  /// Returns the read interrupt time.
  int _getReadInterruptTime() {
    return getNumOperands() >= 3 ? getUnsignedValue(2) : 0;
  }

  /// Returns the read interrupt routine address.
  Char _getReadInterruptRoutine() {
    return getNumOperands() >= 4 ? getUnsignedValue(3) : Char(0);
  }

  /// Returns the number of Characters left in the text buffer when timed
  /// input interrupt occurs.
  int _getNumLeftOverChars(Char textbuffer) {
    return getStoryVersion() >= 5
        ? getMachine().readUnsigned8(textbuffer.toInt() + 1).toInt()
        : 0;
  }

  /// Second stage of SREAD.
  void _sreadStage2() {
    getMachine().setRunState(MachineRunState.RUNNING);

    final int version = getStoryVersion();
    final Char textbuffer = getUnsignedValue(0);
    Char parsebuffer = Char(0);
    if (getNumOperands() >= 2) {
      parsebuffer = getUnsignedValue(1);
    }
    // Here the Z-machine needs to be paused and the user interface
    // handles the whole input
    final Char terminal = getMachine().readLine(textbuffer.toInt());

    if (version < 5 || (version >= 5 && parsebuffer.toInt() > 0)) {
      // Do not tokenise if parsebuffer is 0 (See specification of read)
      getMachine().tokenize(textbuffer.toInt(), parsebuffer.toInt(), 0, false);
    }

    if (storesResult()) {
      // The specification suggests that we store the terminating Character
      // here, this can be NULL or NEWLINE at the moment
      storeUnsignedResult(terminal);
    }
    nextInstruction();
  }

  /// SOUND_EFFECT instruction.
  void _sound_effect() {
    // Choose some default values
    int soundnum = SoundSystem.BLEEP_HIGH;
    int effect = SoundSystem.EFFECT_START;
    int volume = SoundSystem.VOLUME_DEFAULT;
    int repeats = 0;
    int routine = 0;

    // Truly variable
    // If no operands are set, this function will still try to send something
    if (getNumOperands() >= 1) {
      soundnum = getUnsignedValue(0).toInt();
    }

    if (getNumOperands() >= 2) {
      effect = getUnsignedValue(1).toInt();
    }

    if (getNumOperands() >= 3) {
      final int volumeRepeats = getUnsignedValue(2).toInt();
      volume = volumeRepeats & 0xff;
      repeats = zeroFillRightShift(volumeRepeats, 8) & 0xff;
      if (repeats <= 0) {
        repeats = 1;
      }
    }

    if (getNumOperands() == 4) {
      routine = getUnsignedValue(3).toInt();
    }
    _LOG.info(
        "@sound_effect n: ${soundnum}, fx: ${effect}, vol: ${volume}, rep: ${repeats}, " +
            "routine: ${toS04x(routine)}\n");
    // In version 3 repeats is always 1
    if (getStoryVersion() == 3) {
      repeats = 1;
    }

    final SoundSystem soundSystem = getMachine().getSoundSystem();
    soundSystem.play(soundnum, effect, volume, repeats, routine);
    nextInstruction();
  }

  /// SPLIT_WINDOW instruction.
  void _split_window() {
    final ScreenModel screenModel = getMachine().getScreen();
    if (screenModel != null) {
      screenModel.splitWindow(getUnsignedValue(0).toInt());
    }
    nextInstruction();
  }

  /// SET_WINDOW instruction.
  void _set_window() {
    final ScreenModel screenModel = getMachine().getScreen();
    if (screenModel != null) {
      screenModel.setWindow(getUnsignedValue(0).toInt());
    }
    nextInstruction();
  }

  /// SET_TEXT_STYLE instruction.
  void _set_text_style() {
    final ScreenModel screenModel = getMachine().getScreen();
    if (screenModel != null) {
      screenModel.setTextStyle(getUnsignedValue(0).toInt());
    }
    nextInstruction();
  }

  /// BUFFER_MODE instruction.
  void _buffer_mode() {
    final ScreenModel screenModel = getMachine().getScreen();
    if (screenModel != null) {
      // If set to 1, text output on the lower window in stream 1
      // is buffered up so that it can be word-wrapped properly.
      // If set to 0, it isn't.
      screenModel.setBufferMode(getUnsignedValue(0).toInt() > 0);
    }
    nextInstruction();
  }

  /// ERASE_WINDOW instruction.
  void _erase_window() {
    final ScreenModel screenModel = getMachine().getScreen();
    if (screenModel != null) {
      screenModel.eraseWindow(getSignedValue(0));
    }
    nextInstruction();
  }

  /// ERASE_LINE instruction.
  void _erase_line() {
    final ScreenModel screenModel = getMachine().getScreen();
    if (screenModel != null) {
      screenModel.eraseLine(getUnsignedValue(0).toInt());
    }
    nextInstruction();
  }

  /// SET_CURSOR instruction.
  void _set_cursor() {
    final ScreenModel screenModel = getMachine().getScreen();
    if (screenModel != null) {
      final int line = getSignedValue(0);
      int column = 0;
      int window = ScreenModel.CURRENT_WINDOW;

      if (getNumOperands() >= 2) {
        column = getUnsignedValue(1).toInt();
      }
      if (getNumOperands() >= 3) {
        window = getSignedValue(2);
      }
      if (line > 0) {
        screenModel.setTextCursor(line, column, window);
      }
    }
    nextInstruction();
  }

  /// GET_CURSOR instruction.
  void _get_cursor() {
    final ScreenModel screenModel = getMachine().getScreen();
    if (screenModel != null) {
      final TextCursor cursor = screenModel.getTextCursor();
      final int arrayAddr = getUnsignedValue(0).toInt();
      getMachine().writeUnsigned16(arrayAddr, Char(cursor.getLine()));
      getMachine().writeUnsigned16(arrayAddr + 2, Char(cursor.getColumn()));
    }
    nextInstruction();
  }

  /// SCAN_TABLE instruction.
  void _scan_table() {
    int x = getUnsignedValue(0).toInt();
    final Char table = getUnsignedValue(1);
    final int length = getUnsignedValue(2).toInt();
    int form = 0x82; // default value
    if (getNumOperands() == 4) {
      form = getUnsignedValue(3).toInt();
    }
    final int fieldlen = form & 0x7f;
    final bool isWordTable = (form & 0x80) > 0;
    int pointer = table.toInt();
    bool found = false;

    for (int i = 0; i < length; i++) {
      int current = 0;
      if (isWordTable) {
        current = getMachine().readUnsigned16(pointer).toInt();
        x &= 0xffff;
      } else {
        current = getMachine().readUnsigned8(pointer).toInt();
        x &= 0xff;
      }
      if (current == x) {
        storeUnsignedResult(Char(pointer));
        found = true;
        break;
      }
      pointer += fieldlen;
    }
    // not found
    if (!found) {
      storeUnsignedResult(Char(0));
    }
    branchOnTest(found);
  }

  /// READ_CHAR instruction.
  void _read_char() {
    if (getMachine().getRunState() == MachineRunState.RUNNING) {
      _readCharStage1();
    } else {
      _readCharStage2();
    }
  }

  /// First stage of READ_CHAR.
  void _readCharStage1() {
    getMachine().setRunState(MachineRunState.createReadChar(
        _getReadCharInterruptTime(), _getReadCharInterruptRoutine()));
  }

  /// Returns the interrupt time for READ_CHAR timed input.
  int _getReadCharInterruptTime() {
    return getNumOperands() >= 2 ? getUnsignedValue(1).toInt() : 0;
  }

  /// Returns the address of the interrupt routine for READ_CHAR timed input.
  Char _getReadCharInterruptRoutine() {
    return getNumOperands() >= 3 ? getUnsignedValue(2) : Char(0);
  }

  /// Second stage of READ_CHAR.
  void _readCharStage2() {
    getMachine().setRunState(MachineRunState.RUNNING);
    storeUnsignedResult(getMachine().readChar());
    nextInstruction();
  }

  /// NOT instruction. Actually a copy from Short1Instruction, probably we
  /// can remove this duplication.
  void _not() {
    final int notvalue = ~getUnsignedValue(0).toInt();
    storeUnsignedResult(Char(notvalue & 0xffff));
    nextInstruction();
  }

  /// TOKENISE instruction.
  void _tokenise() {
    final int textbuffer = getUnsignedValue(0).toInt();
    final int parsebuffer = getUnsignedValue(1).toInt();
    int dictionary = 0;
    int flag = 0;
    if (getNumOperands() >= 3) {
      dictionary = getUnsignedValue(2).toInt();
    }
    if (getNumOperands() >= 4) {
      flag = getUnsignedValue(3).toInt();
    }
    getMachine().tokenize(textbuffer, parsebuffer, dictionary, (flag != 0));
    nextInstruction();
  }

  /// CHECK_ARG_COUNT instruction.
  void _check_arg_count() {
    final int argumentNumber = getUnsignedValue(0).toInt();
    final int currentNumArgs =
        getMachine().getCurrentRoutineContext().getNumArguments();
    branchOnTest(argumentNumber <= currentNumArgs);
  }

  /// COPY_TABLE instruction.
  void _copy_table() {
    final int first = getUnsignedValue(0).toInt();
    final int second = getUnsignedValue(1).toInt();
    int size = getSignedValue(2).abs();
    if (second == 0) {
      // Clear size bytes of first
      for (int i = 0; i < size; i++) {
        getMachine().writeUnsigned8(first + i, Char(0));
      }
    } else {
      getMachine().copyArea(first, second, size);
    }
    nextInstruction();
  }

  /// Do the print_table instruction. This method takes a text and formats
  /// it in a specified format. It requires access to the cursor position
  /// in order to be implemented correctly, otherwise horizontal home
  /// position would always be set to the left position of the window.
  /// Interestingly, the text is not encoded, so the Characters should be
  /// accessed one by one in ZSCII format.
  void _print_table() {
    final int zsciiText = getUnsignedValue(0).toInt();
    final int width = getUnsignedValue(1).toInt();
    int height = 1;
    int skip = 0;
    if (getNumOperands() >= 3) {
      height = getUnsignedValue(2).toInt();
    }
    if (getNumOperands() == 4) {
      skip = getUnsignedValue(3).toInt();
    }

    Char zChar = Char(0);
    final TextCursor cursor = getMachine().getScreen().getTextCursor();
    final int column = cursor.getColumn();
    int row = cursor.getLine();

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        final int offset = (width * i) + j;
        zChar = getMachine().readUnsigned8(zsciiText + offset);
        getMachine().printZsciiChar(zChar);
      }
      row += skip + 1;
      getMachine()
          .getScreen()
          .setTextCursor(row, column, ScreenModel.CURRENT_WINDOW);
    }
    nextInstruction();
  }

  /// ENCODE_TEXT instruction.
  void _encode_text() {
    final int zsciiText = getUnsignedValue(0).toInt();
    final int length = getUnsignedValue(1).toInt();
    final int from = getUnsignedValue(2).toInt();
    final int codedText = getUnsignedValue(3).toInt();
    getMachine().encode(zsciiText + from, length, codedText);
    nextInstruction();
  }
}

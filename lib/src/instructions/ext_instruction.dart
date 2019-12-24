import '../../zvm.dart';

/// Implementation of instructions with EXT operand count.
class ExtInstruction extends AbstractInstruction {
  ExtInstruction(Machine machine, int opcodeNum, List<Operand> operands,
      Char storeVar, BranchInfo branchInfo, int opcodeLength)
      : super(machine, opcodeNum, operands, storeVar, branchInfo, opcodeLength);

  @override
  OperandCount getOperandCount() {
    return OperandCount.EXT;
  }

  @override
  void execute() {
    switch (getOpcodeNum()) {
      case Instruction.EXT_SAVE:
        _save();
        break;
      case Instruction.EXT_RESTORE:
        _restore();
        break;
      case Instruction.EXT_LOG_SHIFT:
        _log_shift();
        break;
      case Instruction.EXT_ART_SHIFT:
        _art_shift();
        break;
      case Instruction.EXT_SET_FONT:
        _set_font();
        break;
      case Instruction.EXT_SAVE_UNDO:
        _save_undo();
        break;
      case Instruction.EXT_RESTORE_UNDO:
        _restore_undo();
        break;
      case Instruction.EXT_PRINT_UNICODE:
        _print_unicode();
        break;
      case Instruction.EXT_CHECK_UNICODE:
        _check_unicode();
        break;
      case Instruction.EXT_MOUSE_WINDOW:
        _mouse_window();
        break;
      case Instruction.EXT_PICTURE_DATA:
        _picture_data();
        break;
      case Instruction.EXT_DRAW_PICTURE:
        _draw_picture();
        break;
      case Instruction.EXT_ERASE_PICTURE:
        _erase_picture();
        break;
      case Instruction.EXT_MOVE_WINDOW:
        _move_window();
        break;
      case Instruction.EXT_WINDOW_SIZE:
        _window_size();
        break;
      case Instruction.EXT_WINDOW_STYLE:
        _window_style();
        break;
      case Instruction.EXT_SET_MARGINS:
        _set_margins();
        break;
      case Instruction.EXT_GET_WIND_PROP:
        _get_wind_prop();
        break;
      case Instruction.EXT_PICTURE_TABLE:
        _picture_table();
        break;
      case Instruction.EXT_PUT_WIND_PROP:
        _put_wind_prop();
        break;
      case Instruction.EXT_PUSH_STACK:
        _push_stack();
        break;
      case Instruction.EXT_POP_STACK:
        _pop_stack();
        break;
      case Instruction.EXT_READ_MOUSE:
        _read_mouse();
        break;
      case Instruction.EXT_SCROLL_WINDOW:
        _scroll_window();
        break;
      default:
        throwInvalidOpcode();
        break;
    }
  }

  /// SAVE_UNDO instruction.
  void _save_undo() {
    // Target PC offset is two because of the extra opcode byte and
    // operand type byte compared to the 0OP instruction
    final int pc = getMachine().getPC() + 3;
    final bool success = getMachine().save_undo(pc);
    storeUnsignedResult(success ? Instruction.TRUE : Instruction.FALSE);
    nextInstruction();
  }

  /// RESTORE_UNDO instruction.
  void _restore_undo() {
    final PortableGameState gamestate = getMachine().restore_undo();
    if (gamestate == null) {
      storeUnsignedResult(Instruction.FALSE);
      nextInstruction();
    } else {
      final Char storevar = gamestate.getStoreVariable(getMachine());
      getMachine().setVariable(storevar, Instruction.RESTORE_TRUE);
    }
  }

  /// ART_SHIFT instruction.
  void _art_shift() {
    int number = getSignedValue(0);
    final int places = getSignedValue(1);
    number = (places >= 0) ? number << places : number >> (-places);
    storeUnsignedResult(signedToUnsigned16(number));
    nextInstruction();
  }

  /// LOG_SHIFT instruction.
  void _log_shift() {
    int number = getUnsignedValue(0).toInt();
    final int places = getSignedValue(1);
    // TODO: verify zeroFillRightShift behavior
    number =
        (places >= 0) ? number << places : zeroFillRightShift(number, -places);
    storeUnsignedResult(Char(number));
    nextInstruction();
  }

  /// SET_FONT instruction.
  void _set_font() {
    final Char previousFont =
        getMachine().getScreen().setFont(getUnsignedValue(0));
    storeUnsignedResult(previousFont);
    nextInstruction();
  }

  /// SAVE instruction.
  void _save() {
    // Saving to tables is not supported yet, this is the standard save feature
    // Offset is 3 because there are two opcode bytes + 1 optype byte before
    // the actual store var byte
    saveToStorage(getMachine().getPC() + 3);
  }

  /// RESTORE instruction.
  void _restore() {
    // Reading from tables is not supported yet, this is the standard
    // restore feature
    restoreFromStorage();
  }

  /// PRINT_UNICODE instruction.
  void _print_unicode() {
    final Char zChar = getUnsignedValue(0);
    getMachine().printZsciiChar(zChar);
    nextInstruction();
  }

  /// CHECK_UNICODE instruction.
  void _check_unicode() {
    // always return true, set bit 0 for can print and bit 1 for
    // can read
    storeUnsignedResult(Char(3));
    nextInstruction();
  }

  /// MOUSE_WINDOW instruction.
  void _mouse_window() {
    getMachine().getScreen6().setMouseWindow(getSignedValue(0));
    nextInstruction();
  }

  /// PICTURE_DATA instruction.
  void _picture_data() {
    final int picnum = getUnsignedValue(0).toInt();
    final int array = getUnsignedValue(1).toInt();
    bool result = false;

    if (picnum == 0) {
      _writePictureFileInfo(array);
      // branch if any pictures are available: this information is only
      // available in the 1.1 spec
      result = getMachine().getPictureManager().getNumPictures() > 0;
    } else {
      final Resolution picdim =
          getMachine().getPictureManager().getPictureSize(picnum);
      if (picdim != null) {
        getMachine().writeUnsigned16(array, toUnsigned16(picdim.getHeight()));
        getMachine()
            .writeUnsigned16(array + 2, toUnsigned16(picdim.getWidth()));
        result = true;
      }
    }
    branchOnTest(result);
  }

  /// Writes the information of the picture file into the specified array.
  void _writePictureFileInfo(final int array) {
    getMachine().writeUnsigned16(
        array, toUnsigned16(getMachine().getPictureManager().getNumPictures()));
    getMachine().writeUnsigned16(
        array + 2, toUnsigned16(getMachine().getPictureManager().getRelease()));
  }

  /// DRAW_PICTURE instruction.
  void _draw_picture() {
    final int picnum = getUnsignedValue(0).toInt();
    int x = 0, y = 0;

    if (getNumOperands() > 1) {
      y = getUnsignedValue(1).toInt();
    }

    if (getNumOperands() > 2) {
      x = getUnsignedValue(2).toInt();
    }
    getMachine()
        .getScreen6()
        .getSelectedWindow()
        .drawPicture(getMachine().getPictureManager().getPicture(picnum), y, x);
    nextInstruction();
  }

  /// ERASE_PICTURE instruction.
  void _erase_picture() {
    final int picnum = getUnsignedValue(0).toInt();
    int x = 1, y = 1;

    if (getNumOperands() > 1) {
      y = getUnsignedValue(1).toInt();
    }

    if (getNumOperands() > 2) {
      x = getUnsignedValue(2).toInt();
    }
    getMachine().getScreen6().getSelectedWindow().erasePicture(
        getMachine().getPictureManager().getPicture(picnum), y, x);
    nextInstruction();
  }

  /// MOVE_WINDOW instruction.
  void _move_window() {
    getMachine()
        .getScreen6()
        .getWindow(getUnsignedValue(0).toInt())
        .move(getUnsignedValue(1).toInt(), getUnsignedValue(2).toInt());
    nextInstruction();
  }

  /// WINDOW_SIZE instruction.
  void _window_size() {
    final int window = getSignedValue(0);
    final int height = getUnsignedValue(1).toInt();
    final int width = getUnsignedValue(2).toInt();
    getMachine().getScreen6().getWindow(window).setSize(height, width);
    nextInstruction();
  }

  /// WINDOW_STYLE instruction.
  void _window_style() {
    int operation = 0;
    if (getNumOperands() > 2) {
      operation = getUnsignedValue(2).toInt();
    }
    getWindow(getSignedValue(0))
        .setStyle(getUnsignedValue(1).toInt(), operation);
    nextInstruction();
  }

  /// SET_MARGINS instruction.
  void _set_margins() {
    int window = ScreenModel.CURRENT_WINDOW;
    if (getNumOperands() == 3) {
      window = getSignedValue(2);
    }
    getWindow(window)
        .setMargins(getUnsignedValue(0).toInt(), getUnsignedValue(1).toInt());
    nextInstruction();
  }

  /// GET_WIND_PROP instruction.
  void _get_wind_prop() {
    int window = getSignedValue(0);
    int propnum = getUnsignedValue(1).toInt();
    Char result = Char(getWindow(window).getProperty(propnum));
    storeUnsignedResult(result);
    nextInstruction();
  }

  /// PUT_WIND_PROP instruction.
  void _put_wind_prop() {
    int window = getSignedValue(0);
    Char propnum = getUnsignedValue(1);
    int value = getSignedValue(2);
    getWindow(window).putProperty(propnum.toInt(), value);
    nextInstruction();
  }

  /// PICTURE_TABLE instruction.
  void _picture_table() {
    // @picture_table is a no-op, because all pictures are held in memory
    // anyways
    nextInstruction();
  }

  /// POP_STACK instruction.
  void _pop_stack() {
    int numItems = getUnsignedValue(0).toInt();
    Char stack = Char(0);
    if (getNumOperands() == 2) {
      stack = getUnsignedValue(1);
    }
    for (int i = 0; i < numItems; i++) {
      getMachine().popStack(stack);
    }
    nextInstruction();
  }

  /// PUSH_STACK instruction.
  void _push_stack() {
    Char value = getUnsignedValue(0);
    Char stack = Char(0);
    if (getNumOperands() == 2) {
      stack = getUnsignedValue(1);
    }
    branchOnTest(getMachine().pushStack(stack, value));
  }

  /// SCROLL_WINDOW instruction.
  void _scroll_window() {
    getWindow(getSignedValue(0)).scroll(getSignedValue(1));
    nextInstruction();
  }

  /// READ_MOUSE instruction.
  void _read_mouse() {
    int array = getUnsignedValue(0).toInt();
    getMachine().getScreen6().readMouse(array);
    nextInstruction();
  }
}

import '../zvm.dart';

/// This is the execution control instance. Execution is handled by temporarily
/// suspending the VM on an input instruction, resuming after the input
/// buffer was filled and picking up from there.
/// This is the main interface to the user interface.
class ExecutionControl implements Serializable {
  static final Logger _LOG = Logger.getLogger("org.zmpp.control");
  Machine _machine;
  InstructionDecoder _instructionDecoder = InstructionDecoder();
  LineBufferInputStream _inputStream = LineBufferInputStream();
  int _step = 1;

  /// The flag to indicate interrupt output.
  bool _interruptDidOutput = false;

  static final bool DEBUG = false;
  static final bool DEBUG_INTERRUPT = false;

  /// Returns the current step number.
  int getStep() {
    return _step;
  }

  ExecutionControl(MachineInitStruct initStruct) {
    initStruct.keyboardInputStream = _inputStream;
    MachineFactory factory = MachineFactory(initStruct);
    _machine = factory.buildMachine();
    _machine.start();
    _instructionDecoder.initialize(_machine);
    int version = _machine.getVersion();
    // ZMPP should support everything by default
    if (version <= 3) {
      _enableHeaderFlag(Attribute.DEFAULT_FONT_IS_VARIABLE);
      _enableHeaderFlag(Attribute.SUPPORTS_STATUSLINE);
      _enableHeaderFlag(Attribute.SUPPORTS_SCREEN_SPLITTING);
    }
    if (version >= 4) {
      _enableHeaderFlag(Attribute.SUPPORTS_BOLD);
      _enableHeaderFlag(Attribute.SUPPORTS_FIXED_FONT);
      _enableHeaderFlag(Attribute.SUPPORTS_ITALIC);
      _enableHeaderFlag(Attribute.SUPPORTS_TIMED_INPUT);
    }
    if (version >= 5) {
      _enableHeaderFlag(Attribute.SUPPORTS_COLOURS);
    }
    int defaultForeground = getDefaultForeground();
    int defaultBackground = getDefaultBackground();
    _LOG.info("GAME DEFAULT FOREGROUND: ${defaultForeground}");
    _LOG.info("GAME DEFAULT BACKGROUND: ${defaultBackground}");
    _machine.getScreen().setBackground(defaultBackground, -1);
    _machine.getScreen().setForeground(defaultForeground, -1);
  }

  /// Enables the specified header flag.
  void _enableHeaderFlag(Attribute attr) {
    getFileHeader().setEnabled(attr, true);
  }

  /// Returns the machine object.
  Machine getMachine() {
    return _machine;
  }

  /// Returns the file header.
  StoryFileHeader getFileHeader() {
    return _machine.getFileHeader();
  }

  /// Returns the story version.
  int getVersion() {
    return _machine.getVersion();
  }

  /// Sets default colors.
  void setDefaultColors(int defaultBackground, int defaultForeground) {
    _setDefaultBackground(defaultBackground);
    setDefaultForeground(defaultForeground);

    // Also set the default colors in the screen model !!
    _machine.getScreen().setBackground(defaultBackground, -1);
    _machine.getScreen().setForeground(defaultForeground, -1);
  }

  /// Returns the default background color.
  int getDefaultBackground() {
    return _machine.readUnsigned8(StoryFileHeader.DEFAULT_BACKGROUND).toInt();
  }

  /// Returns the default foreground color.
  int getDefaultForeground() {
    return _machine.readUnsigned8(StoryFileHeader.DEFAULT_FOREGROUND).toInt();
  }

  /// Sets the default background color.
  void _setDefaultBackground(final int color) {
    _machine.writeUnsigned8(StoryFileHeader.DEFAULT_BACKGROUND, Char(color));
  }

  /// Sets the default foreground color.
  void setDefaultForeground(final int color) {
    _machine.writeUnsigned8(StoryFileHeader.DEFAULT_FOREGROUND, Char(color));
  }

  /// Updates the screen size.
  void resizeScreen(int numRows, int numCharsPerRow) {
    if (getVersion() >= 4) {
      _machine.writeUnsigned8(StoryFileHeader.SCREEN_HEIGHT, Char(numRows));
      _machine.writeUnsigned8(
          StoryFileHeader.SCREEN_WIDTH, Char(numCharsPerRow));
    }
    if (getVersion() >= 5) {
      getFileHeader().setFontHeight(1);
      getFileHeader().setFontWidth(1);
      _machine.writeUnsigned16(
          StoryFileHeader.SCREEN_HEIGHT_UNITS, Char(numRows));
      _machine.writeUnsigned16(
          StoryFileHeader.SCREEN_WIDTH_UNITS, Char(numCharsPerRow));
    }
  }

  /// The execution loop. It runs until either an input state is reached
  /// or the machine is set to stop state.
  MachineRunState run() {
    while (_machine.getRunState() != MachineRunState.STOPPED) {
      int pc = _machine.getPC();
      Instruction instr = _instructionDecoder.decodeInstruction(pc);
      // if the print is executed after execute(), the result is different !!
      if (DEBUG && _machine.getRunState() == MachineRunState.RUNNING) {
        print("${_step.toString().padLeft(4, '0')}: " +
            "\$${toHexStr(pc, width: 5)} ${instr.toString()}");
      }
      instr.execute();

      // handle input situations here
      if (_machine.getRunState().isWaitingForInput()) {
        break;
      } else {
        _step++;
      }
    }
    return _machine.getRunState();
  }

  /// Resumes from an input state to the run state using the specified Unicode
  /// input string.
  MachineRunState resumeWithInput(String input) {
    _inputStream.addInputLine(_convertToZsciiInputLine(input));
    return run();
  }

  /// Downcase the input string and convert to ZSCII.
  String _convertToZsciiInputLine(String input) {
    // TODO: locale 'en_US' apply to lower case based on locale?
    return _machine.convertToZscii(input.toLowerCase()) + "\r";
  }

  /// Returns the IZsciiEncoding object
  IZsciiEncoding getZsciiEncoding() {
    return _machine;
  }

  /// This method should be called from a timed input method, to fill
  /// the text buffer with current input. By using this, it is ensured,
  /// the game could theoretically process preliminary input.
  void setTextToInputBuffer(String text) {
    MachineRunState runstate = _machine.getRunState();
    if (runstate != null && runstate.isReadLine()) {
      _inputStream.addInputLine(_convertToZsciiInputLine(text));
      int textbuffer = _machine.getRunState().getTextBuffer().toInt();
      _machine.readLine(textbuffer);
    }
  }

  // ************************************************************************
  // ****** Interrupt functions
  // ****** These are for timed input.
  // *************************************

  /// Indicates if the last interrupt routine performed any output.
  bool interruptDidOutput() {
    return _interruptDidOutput;
  }

  /// Calls the specified interrupt routine.
  Char callInterrupt(final Char routineAddress) {
    _interruptDidOutput = false;
    final int originalRoutineStackSize = _machine.getRoutineContexts().length;
    final RoutineContext routineContext = _machine.call(routineAddress,
        _machine.getPC(), List<Char>(0), RoutineContext.DISCARD_RESULT);

    for (;;) {
      final Instruction instr =
          _instructionDecoder.decodeInstruction(_machine.getPC());
      if (DEBUG_INTERRUPT) {
        print("${_step.toString().padLeft(3, '0')}: " +
            "${toS04x(_machine.getPC())} ${instr.toString()}");
      }
      instr.execute();
      // check if something was printed
      if (instr.isOutput()) {
        _interruptDidOutput = true;
      }
      if (_machine.getRoutineContexts().length == originalRoutineStackSize) {
        break;
      }
    }
    return routineContext.getReturnValue();
  }
}

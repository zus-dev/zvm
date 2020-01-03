import '../../zvm.dart';

/// This class represents a stack frame in the portable game state model.
class StackFrame implements Serializable  {
  /// The return program counter.
  int pc = 0;

  /// The return variable.
  Char returnVariable = Char(0);

  /// The local variables.
  List<Char> locals;

  /// The evaluation stack.
  List<Char> evalStack;

  /// The arguments.
  List<Char> args;

  /// Returns the program counter.
  int getProgramCounter() {
    return pc;
  }

  /// Returns the return variable.
  Char getReturnVariable() {
    return returnVariable;
  }

  /// Returns the eval stack.
  List<Char> getEvalStack() {
    return evalStack;
  }

  /// Returns the local variables.
  List<Char> getLocals() {
    return locals;
  }

  /// Returns the routine arguments.
  List<Char> getArgs() {
    return args;
  }

  /// Sets the program counter.
  void setProgramCounter(final int aPc) {
    this.pc = aPc;
  }

  /// Sets the return variable number.
  void setReturnVariable(final Char varnum) {
    this.returnVariable = varnum;
  }

  /// Sets the eval stack.
  void setEvalStack(final List<Char> stack) {
    this.evalStack = stack;
  }

  /// Sets the local variables.
  void setLocals(final List<Char> locals) {
    this.locals = locals;
  }

  /// Sets the routine arguments.
  void setArgs(final List<Char> args) {
    this.args = args;
  }
}

/// This class represents the state of the Z machine in an external format,
/// so it can be exchanged using the Quetzal IFF format.
class PortableGameState implements Serializable {
  /// The return variable value for discard result.
  static final Char DISCARD_RESULT = Char(0xffff);

  /// TODO: PRIVATE:
  /// The release number.
  int release = 0;

  /// The story file checksum.
  int checksum = 0;

  /// The serial number.
  ByteArray serialBytes;

  /// The program counter.
  int pc = 0;

  /// The uncompressed dynamic memory.
  ByteArray dynamicMem;

  /// The delta.
  ByteArray delta;

  /// The list of stack frames in this game state, from oldest to latest.
  List<StackFrame> stackFrames;

  PortableGameState() {
    serialBytes = ByteArray.length(6);
    stackFrames = List<StackFrame>();
  }

  // **********************************************************************
  // ***** Accessing the state
  // *******************************************

  /// Returns the game release number.
  int getRelease() {
    return release;
  }

  /// Returns the game checksum.
  int getChecksum() {
    return checksum;
  }

  /// Returns the game serial number.
  String getSerialNumber() {
    return serialBytes.getString();
  }

  /// Returns the program counter.
  int getProgramCounter() {
    return pc;
  }

  /// Returns the list of stack frames.
  List<StackFrame> getStackFrames() {
    return stackFrames;
  }

  /// Returns the delta bytes. This is the changes in dynamic memory, where
  /// 0 represents no change.
  ByteArray getDeltaBytes() {
    return delta;
  }

  /// Returns the current dump of dynamic memory captured from a Machine object.
  ByteArray getDynamicMemoryDump() {
    return dynamicMem;
  }

  /// Sets the release number.
  void setRelease(final int release) {
    this.release = release;
  }

  /// Sets the checksum.
  void setChecksum(final int checksum) {
    this.checksum = checksum;
  }

  /// Sets the serial number.
  void setSerialNumber(final String serial) {
    this.serialBytes = ByteArray.fromString(serial);
  }

  /// Sets the program counter.
  void setProgramCounter(final int aPc) {
    this.pc = aPc;
  }

  /// Sets the dynamic memory.
  void setDynamicMem(final ByteArray memdata) {
    this.dynamicMem = memdata;
  }

  // **********************************************************************
  // ***** Reading the state from a file
  // *******************************************
  /// Initialize the state from an IFF form.
  /// Returns false if there was a consistency problem during the read
  bool readSaveGame(final FormChunk formChunk) {
    stackFrames.clear();
    if (formChunk != null && "IFZS" == formChunk.getSubId()) {
      _readIfhdChunk(formChunk);
      _readStacksChunk(formChunk);
      _readMemoryChunk(formChunk);
      return true;
    }
    return false;
  }

  /// Evaluate the contents of the IFhd chunk.
  void _readIfhdChunk(final FormChunk formChunk) {
    final Chunk ifhdChunk = formChunk.getSubChunk("IFhd");
    final Memory chunkMem = ifhdChunk.getMemory();
    int offset = Chunk.CHUNK_HEADER_LENGTH;
    // read release number
    release = chunkMem.readUnsigned16(offset).toInt();
    offset += 2;
    // read serial number
    chunkMem.copyBytesToArray(serialBytes, 0, offset, 6);
    offset += 6;
    // read check sum
    checksum = chunkMem.readUnsigned16(offset).toInt();
    offset += 2;
    // read pc
    pc = _decodePcBytes(chunkMem.readUnsigned8(offset),
        chunkMem.readUnsigned8(offset + 1), chunkMem.readUnsigned8(offset + 2));
  }

  /// Evaluate the contents of the Stks chunk.
  void _readStacksChunk(final FormChunk formChunk) {
    final Chunk stksChunk = formChunk.getSubChunk("Stks");
    final Memory chunkMem = stksChunk.getMemory();
    int offset = Chunk.CHUNK_HEADER_LENGTH;
    final int chunksize = stksChunk.getSize() + Chunk.CHUNK_HEADER_LENGTH;

    while (offset < chunksize) {
      final stackFrame = StackFrame();
      offset = readStackFrame(stackFrame, chunkMem, offset);
      stackFrames.add(stackFrame);
    }
  }

  /// Reads a stack frame from the specified chunk at the specified
  /// offset.
  /// Returns the offset after reading the stack frame.
  /// [stackFrame] the stack frame to set the data into
  /// [chunkMem] the Stks chunk to read from
  /// [offset] the offset to read the stack
  int readStackFrame(StackFrame stackFrame, Memory chunkMem, int offset) {
    int tmpoff = offset;
    stackFrame.pc = _decodePcBytes(chunkMem.readUnsigned8(tmpoff),
        chunkMem.readUnsigned8(tmpoff + 1), chunkMem.readUnsigned8(tmpoff + 2));
    tmpoff += 3;

    final int pvFlags = chunkMem.readUnsigned8(tmpoff++).toInt() & 0xff;
    final int numLocals = pvFlags & 0x0f;
    final bool discardResult = (pvFlags & 0x10) > 0;
    stackFrame.locals = FilledList.ofChar(numLocals);

    // Read the return variable, ignore the result if DISCARD_RESULT
    final Char returnVar = chunkMem.readUnsigned8(tmpoff++);
    stackFrame.returnVariable = discardResult ? DISCARD_RESULT : returnVar;
    final int argSpec = chunkMem.readUnsigned8(tmpoff++).toInt() & 0xff;
    stackFrame.args = _getArgs(argSpec);
    final int evalStackSize = chunkMem.readUnsigned16(tmpoff).toInt();
    stackFrame.evalStack = FilledList.ofChar(evalStackSize);
    tmpoff += 2;

    // Read local variables
    for (int i = 0; i < numLocals; i++) {
      stackFrame.locals[i] = chunkMem.readUnsigned16(tmpoff);
      tmpoff += 2;
    }

    // Read evaluation stack values
    for (int i = 0; i < evalStackSize; i++) {
      stackFrame.evalStack[i] = chunkMem.readUnsigned16(tmpoff);
      tmpoff += 2;
    }
    return tmpoff;
  }

  /// Evaluate the contents of the Cmem and the UMem chunks.
  void _readMemoryChunk(final FormChunk formChunk) {
    final Chunk cmemChunk = formChunk.getSubChunk("CMem");
    final Chunk umemChunk = formChunk.getSubChunk("UMem");
    if (cmemChunk != null) {
      _readCMemChunk(cmemChunk);
    }
    if (umemChunk != null) {
      _readUMemChunk(umemChunk);
    }
  }

  /// Decompresses and reads the dynamic memory state.
  void _readCMemChunk(final Chunk cmemChunk) {
    final Memory chunkMem = cmemChunk.getMemory();
    int offset = Chunk.CHUNK_HEADER_LENGTH;
    final int chunksize = cmemChunk.getSize() + Chunk.CHUNK_HEADER_LENGTH;
    // NOTE: List<int> because ByteArray is fixed size!
    final byteBuffer = List<int>();
    Char b = Char(0);

    while (offset < chunksize) {
      b = chunkMem.readUnsigned8(offset++);
      if (b.toInt() == 0) {
        final runlength = chunkMem.readUnsigned8(offset++).toInt();
        for (int r = 0; r <= runlength; r++) {
          // (runlength + 1) iterations
          byteBuffer.add(0);
        }
      } else {
        byteBuffer.add(b & 0xff);
      }
    }

    // Copy the results to the delta array
    delta = ByteArray.length(byteBuffer.length);
    for (int i = 0; i < delta.length; i++) {
      delta[i] = byteBuffer[i];
    }
  }

  /// Reads the uncompressed dynamic memory state.
  void _readUMemChunk(final Chunk umemChunk) {
    final Memory chunkMem = umemChunk.getMemory();
    final int datasize = umemChunk.getSize();
    dynamicMem = ByteArray.length(datasize);
    chunkMem.copyBytesToArray(
        dynamicMem, 0, Chunk.CHUNK_HEADER_LENGTH, datasize);
  }

  // **********************************************************************
  // ***** Reading the state from a Machine
  // *******************************************

  /// Makes a snapshot of the current machine state. The savePc argument
  /// is taken as the restore program counter.
  /// [savePc] the program counter restore value
  void captureMachineState(final Machine machine, final int savePc) {
    final StoryFileHeader fileheader = machine.getFileHeader();
    release = machine.getRelease();
    checksum = machine.readUnsigned16(StoryFileHeader.CHECKSUM).toInt();
    serialBytes = ByteArray.fromString(fileheader.getSerialNumber());
    pc = savePc;

    // capture dynamic memory which ends at address(staticsMem) - 1
    // uncompressed
    final int staticMemStart =
        machine.readUnsigned16(StoryFileHeader.STATIC_MEM).toInt();
    dynamicMem = ByteArray.length(staticMemStart);
    // Save the state of dynamic memory
    machine.copyBytesToArray(dynamicMem, 0, 0, staticMemStart);
    _captureStackFrames(machine);
  }

  /// Read the list of RoutineContexts in Machine, convert them to StackFrames,
  /// prepending a dummy stack frame.
  void _captureStackFrames(final Machine machine) {
    final List<RoutineContext> contexts = machine.getRoutineContexts();
    // Put in initial dummy stack frame
    final StackFrame dummyFrame = StackFrame();
    dummyFrame.args = List<Char>(0);
    dummyFrame.locals = List<Char>(0);
    int numElements = _calculateNumStackElements(machine, contexts, 0, 0);
    dummyFrame.evalStack = FilledList.ofChar(numElements);
    for (int i = 0; i < numElements; i++) {
      dummyFrame.evalStack[i] = machine.getStackElement(i);
    }
    stackFrames.add(dummyFrame);

    // Write out stack frames
    for (int c = 0; c < contexts.length; c++) {
      final RoutineContext context = contexts[c];

      final StackFrame stackFrame = StackFrame();
      stackFrame.pc = context.getReturnAddress();
      stackFrame.returnVariable = context.getReturnVariable();

      // Copy local variables
      stackFrame.locals = FilledList.ofChar(context.getNumLocalVariables());
      for (int i = 0; i < stackFrame.locals.length; i++) {
        stackFrame.locals[i] = context.getLocalVariable(Char(i));
      }

      // Create argument array
      stackFrame.args = FilledList.ofChar(context.getNumArguments());
      for (int i = 0; i < stackFrame.args.length; i++) {
        stackFrame.args[i] = Char(i);
      }

      // Transfer evaluation stack
      final int localStackStart = context.getInvocationStackPointer().toInt();
      numElements =
          _calculateNumStackElements(machine, contexts, c + 1, localStackStart);
      stackFrame.evalStack = FilledList.ofChar(numElements);
      for (int i = 0; i < numElements; i++) {
        stackFrame.evalStack[i] = machine.getStackElement(localStackStart + i);
      }
      stackFrames.add(stackFrame);
    }
  }

  /// Determines the number of stack elements between localStackStart and
  /// the invocation stack pointer of the specified routine context.
  /// If contextIndex is greater than the size of the List contexts, the
  /// functions assumes this is the top routine context and therefore
  /// calculates the difference between the current stack pointer and
  /// localStackStart.
  int _calculateNumStackElements(
      final Machine machine,
      final List<RoutineContext> contexts,
      final int contextIndex,
      final int localStackStart) {
    if (contextIndex < contexts.length) {
      final RoutineContext context = contexts[contextIndex];
      return context.getInvocationStackPointer().toInt() - localStackStart;
    } else {
      return machine.getSP().toInt() - localStackStart;
    }
  }

  // ***********************************************************************
  // ******* Export to an IFF FORM chunk
  // *****************************************

  /// Exports the current object state to a FormChunk.
  WritableFormChunk exportToFormChunk() {
    final ByteArray id = ByteArray.fromString("IFZS");
    final WritableFormChunk formChunk = WritableFormChunk(id);
    formChunk.addChunk(_createIfhdChunk());
    formChunk.addChunk(_createUMemChunk());
    formChunk.addChunk(_createStksChunk());

    return formChunk;
  }

  /// Creates the IFhd chunk.
  Chunk _createIfhdChunk() {
    final ByteArray id = ByteArray.fromString("IFhd");
    final ByteArray data = ByteArray.length(13);
    final Chunk chunk = DefaultChunk.forWrite(id, data);
    final Memory chunkmem = chunk.getMemory();

    // Write release number
    chunkmem.writeUnsigned16(8, toUnsigned16(release));

    // Copy serial bytes
    chunkmem.copyBytesFromArray(serialBytes, 0, 10, serialBytes.length);
    chunkmem.writeUnsigned16(16, toUnsigned16(checksum));
    chunkmem.writeUnsigned8(18, Char(zeroFillRightShift(pc, 16) & 0xff));
    chunkmem.writeUnsigned8(19, Char(zeroFillRightShift(pc, 8) & 0xff));
    chunkmem.writeUnsigned8(20, Char(pc & 0xff));

    return chunk;
  }

  /// Creates the UMem chunk.
  Chunk _createUMemChunk() {
    final ByteArray id = ByteArray.fromString("UMem");
    return DefaultChunk.forWrite(id, dynamicMem);
  }

  /// Creates the Stks chunk.
  Chunk _createStksChunk() {
    final ByteArray id = ByteArray.fromString("Stks");
    final List<int> byteBuffer = List<int>();

    for (StackFrame stackFrame in stackFrames) {
      writeStackFrameToByteBuffer(byteBuffer, stackFrame);
    }
    final ByteArray data = ByteArray.length(byteBuffer.length);
    for (int i = 0; i < data.length; i++) {
      data[i] = byteBuffer[i];
    }
    return DefaultChunk.forWrite(id, data);
  }

  /// Writes the specified stackframe to the given byte buffer.
  /// [byteBuffer] a byte buffer (list of bytes)
  void writeStackFrameToByteBuffer(
      final List<int> byteBuffer, final StackFrame stackFrame) {
    final int returnPC = stackFrame.pc;
    byteBuffer.add(byte(zeroFillRightShift(returnPC, 16) & 0xff));
    byteBuffer.add(byte(zeroFillRightShift(returnPC, 8) & 0xff));
    byteBuffer.add(byte(returnPC & 0xff));

    // locals flag, is simply the number of local variables
    final bool discardResult = stackFrame.returnVariable == DISCARD_RESULT;
    int pvFlag = byte(stackFrame.locals.length & 0x0f);
    if (discardResult) {
      pvFlag |= 0x10;
    }
    byteBuffer.add(pvFlag);

    // returnvar
    byteBuffer.add(byte(discardResult ? 0 : stackFrame.returnVariable.toInt()));

    // argspec
    byteBuffer.add(_createArgSpecByte(stackFrame.args));

    // eval stack size
    final int stacksize = stackFrame.evalStack.length;
    _addUnsigned16ToByteBuffer(byteBuffer, Char(stacksize));

    // local variables
    for (Char local in stackFrame.locals) {
      _addUnsigned16ToByteBuffer(byteBuffer, local);
    }

    // stack values
    for (Char stackValue in stackFrame.evalStack) {
      _addUnsigned16ToByteBuffer(byteBuffer, stackValue);
    }
  }

  /// Appends unsigned 16 bit value to the byte buffer.
  /// [buffer] byte buffer
  /// [value] unsigned 16 bit value
  void _addUnsigned16ToByteBuffer(final List<int> buffer, final Char value) {
    buffer.add(byte(zeroFillRightShift((value.toInt() & 0xff00), 8)));
    buffer.add(byte(value.toInt() & 0xff));
  }

  /// Makes an arg spec byte from the arguments.
  static int _createArgSpecByte(final List<Char> args) {
    int result = 0;
    for (var arg in args) {
      result |= (1 << arg.toInt());
    }
    // result is Byte
    return result & 0xff;
  }

  // ***********************************************************************
  // ******* Transfer to Machine object
  // *****************************************

  /// Transfers the current object state to the specified Machine object.
  /// The machine needs to be in a reset state in order to function correctly.
  void transferStateToMachine(final Machine machine) {
    // Copy dynamic memory
    machine.copyBytesFromArray(dynamicMem, 0, 0, dynamicMem.length);

    // Stack frames
    final contexts = List<RoutineContext>();

    // Dummy frame, only the stack is interesting
    if (stackFrames.isNotEmpty) {
      final StackFrame dummyFrame = stackFrames[0];

      // Stack
      for (int s = 0; s < dummyFrame.getEvalStack().length; s++) {
        machine.setVariable(Char(0), dummyFrame.getEvalStack()[s]);
      }
    }

    // Now iterate through all real stack frames
    for (int i = 1; i < stackFrames.length; i++) {
      final StackFrame stackFrame = stackFrames[i];
      // ignore the start address
      final context = RoutineContext(stackFrame.locals.length);

      context.setReturnVariable(stackFrame.returnVariable);
      context.setReturnAddress(stackFrame.pc);
      context.setNumArguments(stackFrame.args.length);

      // local variables
      for (int l = 0; l < stackFrame.locals.length; l++) {
        context.setLocalVariable(Char(l), stackFrame.locals[l]);
      }

      // Stack
      for (int s = 0; s < stackFrame.evalStack.length; s++) {
        machine.setVariable(Char(0), stackFrame.evalStack[s]);
      }
      contexts.add(context);
    }
    machine.setRoutineContexts(contexts);

    // Prepare the machine continue
    int resumePc = getProgramCounter();
    if (machine.getVersion() <= 3) {
      // In version 3 this is a branch target that needs to be read
      // Execution is continued at the first instruction after the branch offset
      resumePc += _getBranchOffsetLength(machine, resumePc);
    } else if (machine.getVersion() >= 4) {
      // in version 4 and later, this is always 1
      resumePc++;
    }
    machine.setPC(resumePc);
  }

  /// For versions >= 4. Returns the store variable
  Char getStoreVariable(final Machine machine) {
    final int storeVarAddress = getProgramCounter();
    return machine.readUnsigned8(storeVarAddress);
  }

  /// Determine if the branch offset is one or two bytes long.
  /// Returns 1 or 2, depending on the value of the branch offset.
  /// [memory] the Memory object of the current story
  /// [offsetAddress] the branch offset address
  static int _getBranchOffsetLength(
      final Memory memory, final int offsetAddress) {
    final Char offsetByte1 = memory.readUnsigned8(offsetAddress);

    // Bit 6 set -> only one byte needs to be read
    return ((offsetByte1 & 0x40) > 0) ? 1 : 2;
  }

  // ***********************************************************************
  // ******* Helpers
  // *****************************************

  /// There is no apparent reason at the moment to implement getArgs().
  List<Char> _getArgs(final int argspec) {
    int andBit;
    final result = List<Char>();

    for (int i = 0; i < 7; i++) {
      andBit = 1 << i;
      if ((andBit & argspec) > 0) {
        result.add(Char(i));
      }
    }
    final charArray = FilledList.ofChar(result.length);
    for (int i = 0; i < result.length; i++) {
      charArray[i] = result[i];
    }
    return charArray;
  }

  /// Joins three bytes to a program counter value.
  int _decodePcBytes(final Char b0, final Char b1, final Char b2) {
    return (((b0.toInt() & 0xff) << 16) |
        ((b1.toInt() & 0xff) << 8) |
        (b2.toInt() & 0xff));
  }
}

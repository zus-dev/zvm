import 'dart:math';

import '../../zvm.dart';

/// Cpu interface implementation.
class CpuImpl implements Cpu {
  static final Logger _LOG = Logger.getLogger("org.zmpp");

  /// The stack size is now 64 K.
  static final int _STACKSIZE = 32768;

  /// The machine object.
  Machine _machine;

  /// This machine's current program counter.
  int _programCounter = 0;

  /// This machine's global stack.
  FastShortStack _stack;

  /// The routine info.
  List<RoutineContext> _routineContextStack;

  /// The start of global variables.
  int _globalsAddress = 0;

  CpuImpl(final Machine machine) {
    _machine = machine;
  }

  @override
  void reset() {
    _stack = FastShortStack(_STACKSIZE);
    _routineContextStack = List<RoutineContext>();
    _globalsAddress = _machine.readUnsigned16(StoryFileHeader.GLOBALS).toInt();

    if (_machine.getVersion() == 6) {
      // Call main function in version 6
      call(_getProgramStart(), 0, List<Char>(0), Char(0));
    } else {
      _programCounter = _getProgramStart().toInt();
    }
  }

  /// Returns the story's start address.
  Char _getProgramStart() {
    return _machine.readUnsigned16(StoryFileHeader.PROGRAM_START);
  }

  @override
  int getPC() {
    return _programCounter;
  }

  @override
  void setPC(final int address) {
    _programCounter = address;
  }

  /// Increments the program counter.
  void incrementPC(final int offset) {
    _programCounter += offset;
  }

  @override
  int unpackStringAddress(Char packedAddress) {
    int version = _machine.getVersion();
    return version == 6 || version == 7
        ? packedAddress.toInt() * 4 + 8 * _getStaticStringOffset()
        : _unpackAddress(packedAddress.toInt());
  }

  /// Unpacks a routine address, exposed for testing.
  int unpackRoutineAddress(Char packedAddress) {
    int version = _machine.getVersion();
    return version == 6 || version == 7
        ? packedAddress.toInt() * 4 + 8 * _getRoutineOffset()
        : _unpackAddress(packedAddress.toInt());
  }

  /// Only for V6 and V7 games: the routine offset.
  int _getRoutineOffset() {
    return _machine.readUnsigned16(StoryFileHeader.ROUTINE_OFFSET).toInt();
  }

  /// Only in V6 and V7: the static string offset.
  int _getStaticStringOffset() {
    return _machine
        .readUnsigned16(StoryFileHeader.STATIC_STRING_OFFSET)
        .toInt();
  }

  /// Version specific unpacking.
  int _unpackAddress(final int packedAddress) {
    switch (_machine.getVersion()) {
      case 1:
      case 2:
      case 3:
        return packedAddress * 2;
      case 4:
      case 5:
        return packedAddress * 4;
      case 8:
      default:
        return packedAddress * 8;
    }
  }

  @override
  void doBranch(int branchOffset, int instructionLength) {
    if (branchOffset >= 2 || branchOffset < 0) {
      setPC(_computeBranchTarget(branchOffset, instructionLength));
    } else {
      // FALSE is defined as 0, TRUE as 1, so simply return the offset
      // since we do not have negative offsets
      returnWith(Char(branchOffset));
    }
  }

  /// Computes the branch target.
  int _computeBranchTarget(final int offset, final int instructionLength) {
    return getPC() + instructionLength + offset - 2;
  }

  @override
  Char getSP() {
    return Char(_stack.getStackPointer());
  }

  /// Sets the global stack pointer to the specified value. This might pop off
  /// several values from the stack.
  void _setSP(final Char stackpointer) {
    // remove the last diff elements
    final int diff = _stack.getStackPointer() - stackpointer.toInt();
    for (int i = 0; i < diff; i++) {
      _stack.pop();
    }
  }

  @override
  Char getStackTop() {
    if (_stack.size() > 0) {
      return _stack.top();
    }
    throw ArrayIndexOutOfBoundsException("Stack underflow error");
  }

  @override
  void setStackTop(final Char value) {
    _stack.replaceTopElement(value);
  }

  @override
  Char getStackElement(final int index) {
    return _stack.getValueAt(index);
  }

  @override
  Char popStack(Char userstackAddress) {
    return userstackAddress.toInt() == 0
        ? getVariable(Char(0))
        : _popUserStack(userstackAddress.toInt());
  }

  /// Pops the user stack.
  Char _popUserStack(int userstackAddress) {
    int numFreeSlots = _machine.readUnsigned16(userstackAddress).toInt();
    numFreeSlots++;
    _machine.writeUnsigned16(userstackAddress, toUnsigned16(numFreeSlots));
    return _machine.readUnsigned16(userstackAddress + (numFreeSlots * 2));
  }

  @override
  bool pushStack(Char userstackAddress, Char value) {
    if (userstackAddress.toInt() == 0) {
      setVariable(Char(0), value);
      return true;
    } else {
      return _pushUserStack(userstackAddress.toInt(), value);
    }
  }

  /// Push user stack.
  bool _pushUserStack(int userstackAddress, Char value) {
    int numFreeSlots = _machine.readUnsigned16(userstackAddress).toInt();
    if (numFreeSlots > 0) {
      _machine.writeUnsigned16(userstackAddress + (numFreeSlots * 2), value);
      _machine.writeUnsigned16(
          userstackAddress, toUnsigned16(numFreeSlots - 1));
      return true;
    }
    return false;
  }

  @override
  Char getVariable(final Char variableNumber) {
    final VariableType varType = getVariableType(variableNumber.toInt());
    if (varType == VariableType.STACK) {
      if (_stack.size() == _getInvocationStackPointer().toInt()) {
        //throw new IllegalStateException("stack underflow error");
        _LOG.severe("stack underflow error");
        return Char(0);
      } else {
        return _stack.pop();
      }
    } else if (varType == VariableType.LOCAL) {
      final Char localVarNumber = _getLocalVariableNumber(variableNumber);
      _checkLocalVariableAccess(localVarNumber);
      return getCurrentRoutineContext().getLocalVariable(localVarNumber);
    } else {
      // GLOBAL
      return _machine.readUnsigned16(
          _globalsAddress + (_getGlobalVariableNumber(variableNumber) * 2));
    }
  }

  /// Returns the current invocation stack pointer.
  Char _getInvocationStackPointer() {
    return getCurrentRoutineContext() == null
        ? Char(0)
        : getCurrentRoutineContext().getInvocationStackPointer();
  }

  @override
  void setVariable(final Char variableNumber, final Char value) {
    final VariableType varType = getVariableType(variableNumber.toInt());
    if (varType == VariableType.STACK) {
      _stack.push(value);
    } else if (varType == VariableType.LOCAL) {
      final Char localVarNumber = _getLocalVariableNumber(variableNumber);
      _checkLocalVariableAccess(localVarNumber);
      getCurrentRoutineContext().setLocalVariable(localVarNumber, value);
    } else {
      _machine.writeUnsigned16(
          _globalsAddress + (_getGlobalVariableNumber(variableNumber) * 2),
          value);
    }
  }

  /// Returns the variable type for the given variable number.
  static VariableType getVariableType(final int variableNumber) {
    if (variableNumber == 0) {
      return VariableType.STACK;
    } else if (variableNumber < 0x10) {
      return VariableType.LOCAL;
    } else {
      return VariableType.GLOBAL;
    }
  }

  void pushRoutineContext(final RoutineContext routineContext) {
    routineContext.setInvocationStackPointer(getSP());
    _routineContextStack.add(routineContext);
  }

  @override
  void returnWith(final Char returnValue) {
    if (_routineContextStack.isNotEmpty) {
      final RoutineContext popped =
          _routineContextStack[_routineContextStack.length - 1];
      _routineContextStack.removeAt(_routineContextStack.length - 1);
      popped.setReturnValue(returnValue);

      // Restore stack pointer and pc
      _setSP(popped.getInvocationStackPointer());
      setPC(popped.getReturnAddress());
      final Char returnVariable = popped.getReturnVariable();
      if (returnVariable != RoutineContext.DISCARD_RESULT) {
        setVariable(returnVariable, returnValue);
      }
    } else {
      throw IllegalStateException("no routine context active");
    }
  }

  @override
  RoutineContext getCurrentRoutineContext() {
    if (_routineContextStack.isEmpty) {
      return null;
    }
    return _routineContextStack[_routineContextStack.length - 1];
  }

  @override
  List<RoutineContext> getRoutineContexts() {
    return List.unmodifiable(_routineContextStack);
  }

  @override
  void setRoutineContexts(final List<RoutineContext> contexts) {
    _routineContextStack.clear();
    for (RoutineContext context in contexts) {
      _routineContextStack.add(context);
    }
  }

  /// This function is basically exposed to the debug application.
  Char getRoutineStackPointer() {
    return Char(_routineContextStack.length);
  }

  @override
  RoutineContext call(final Char packedRoutineAddress, final int returnAddress,
      final List<Char> args, final Char returnVariable) {
    final int routineAddress = unpackRoutineAddress(packedRoutineAddress);
    final int numArgs = args == null ? 0 : args.length;
    final RoutineContext routineContext = _decodeRoutine(routineAddress);

    // Sets the number of arguments
    routineContext.setNumArguments(numArgs);

    // Save return parameters
    routineContext.setReturnAddress(returnAddress);

    // Only if this instruction stores a result
    if (returnVariable == RoutineContext.DISCARD_RESULT) {
      routineContext.setReturnVariable(RoutineContext.DISCARD_RESULT);
    } else {
      routineContext.setReturnVariable(returnVariable);
    }

    // Set call parameters into the local variables
    // if there are more parameters than local variables,
    // those are thrown away
    final int numToCopy = min(routineContext.getNumLocalVariables(), numArgs);

    for (int i = 0; i < numToCopy; i++) {
      routineContext.setLocalVariable(Char(i), args[i]);
    }

    // save invocation stack pointer
    routineContext.setInvocationStackPointer(getSP());

    // Pushes the routine context onto the routine stack
    pushRoutineContext(routineContext);

    // Jump to the address
    setPC(_machine.getVersion() >= 5
        ? routineAddress + 1
        : routineAddress + 1 + 2 * routineContext.getNumLocalVariables());
    return routineContext;
  }

  /// Decodes the routine at the specified address.
  RoutineContext _decodeRoutine(final int routineAddress) {
    final int numLocals = _machine.readUnsigned8(routineAddress).toInt();
    final List<Char> locals = List<Char>(numLocals);

    if (_machine.getVersion() <= 4) {
      // Only story files <= 4 actually store default values here,
      // after V5 they are assumed as being 0 (standard document 1.0, S.5.2.1)
      for (int i = 0; i < numLocals; i++) {
        locals[i] = _machine.readUnsigned16(routineAddress + 1 + 2 * i);
      }
    }
    final RoutineContext info = RoutineContext(numLocals);
    for (int i = 0; i < numLocals; i++) {
      info.setLocalVariable(Char(i), locals[i]);
    }
    return info;
  }

  /// Returns the local variable number for a specified variable number.
  Char _getLocalVariableNumber(final Char variableNumber) {
    return Char(variableNumber.toInt() - 1);
  }

  /// Returns the global variable for the specified variable number.
  /// A variable number (0x10-0xff)
  int _getGlobalVariableNumber(final Char variableNumber) {
    return (variableNumber.toInt() - 0x10);
  }

  /// This function throws an exception if a non-existing local variable
  /// is accessed on the current routine context or no current routine context
  /// is set.
  void _checkLocalVariableAccess(final Char localVariableNumber) {
    if (_routineContextStack.isEmpty) {
      throw IllegalStateException("no routine context set");
    }

    if (localVariableNumber.toInt() >=
        getCurrentRoutineContext().getNumLocalVariables()) {
      throw IllegalStateException(
          "access to non-existent local variable: ${localVariableNumber.toInt()}");
    }
  }
}

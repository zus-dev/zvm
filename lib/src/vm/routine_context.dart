import '../../zvm.dart';

/// This class holds information about a subroutine.
class RoutineContext {
  /// Set as return variable value if the call is a call_nx.
  static final Char DISCARD_RESULT = Char(0xffff);

  /// The local variables
  List<Char> _locals;

  /// The return address.
  int _returnAddress = 0;

  /// The return variable number to store the return value to.
  Char _returnVarNum = Char(0);

  /// The stack pointer at invocation time.
  Char _invocationStackPointer = Char(0);

  /// The number of arguments.
  int _numArgs = 0;

  /// The return value.
  Char _returnValue = Char(0);

  RoutineContext(int numLocalVariables) {
    _locals = FilledList.ofChar(numLocalVariables);
  }

  /// Sets the number of arguments
  void setNumArguments(final int aNumArgs) {
    this._numArgs = aNumArgs;
  }

  /// Returns the number of arguments.
  int getNumArguments() {
    return _numArgs;
  }

  /// Returns the number of local variables.
  int getNumLocalVariables() {
    return (_locals == null) ? 0 : _locals.length;
  }

  /// Sets a value to the specified local variable number, starting with 0.
  void setLocalVariable(final Char localNum, final Char value) {
    _locals[localNum.toInt()] = value;
  }

  /// Retrieves the value of the specified local variable number, starting at 0.
  Char getLocalVariable(final Char localNum) {
    return _locals[localNum.toInt()];
  }

  /// Returns the routine's return address.
  int getReturnAddress() {
    return _returnAddress;
  }

  /// Sets the return address.
  void setReturnAddress(final int address) {
    this._returnAddress = address;
  }

  /// Returns the routine's return variable number or DISCARD_RESULT.
  Char getReturnVariable() {
    return _returnVarNum;
  }

  /// Sets the routine's return variable number or DISCARD_RESULT.
  void setReturnVariable(final Char varnum) {
    _returnVarNum = varnum;
  }

  /// Returns the stack pointer at invocation time.
  Char getInvocationStackPointer() {
    return _invocationStackPointer;
  }

  /// Sets the stack pointer at invocation time.
  void setInvocationStackPointer(final Char stackpointer) {
    _invocationStackPointer = stackpointer;
  }

  /// Returns the return value.
  Char getReturnValue() {
    return _returnValue;
  }

  /// Sets the return value.
  void setReturnValue(final Char value) {
    _returnValue = value;
  }
}

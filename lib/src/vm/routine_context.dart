import '../../zvm.dart';

/// This class holds information about a subroutine.
class RoutineContext {
  /// Set as return variable value if the call is a call_nx.
  static final Char DISCARD_RESULT = Char(0xffff);

  /// The local variables
  List<Char> locals;

  /// The return address.
  int returnAddress;

  /// The return variable number to store the return value to.
  Char returnVarNum;

  /// The stack pointer at invocation time.
  Char invocationStackPointer;

  /// The number of arguments.
  int numArgs;

  /// The return value.
  Char returnValue;

  RoutineContext(int numLocalVariables) {
    locals = List.generate(numLocalVariables, (_) => Char(0));
  }

  /// Sets the number of arguments
  void setNumArguments(final int aNumArgs) {
    this.numArgs = aNumArgs;
  }

  /// Returns the number of arguments.
  int getNumArguments() {
    return numArgs;
  }

  /// Returns the number of local variables.
  int getNumLocalVariables() {
    return (locals == null) ? 0 : locals.length;
  }

  /// Sets a value to the specified local variable number, starting with 0.
  void setLocalVariable(final Char localNum, final Char value) {
    locals[localNum.toInt()] = value;
  }

  /// Retrieves the value of the specified local variable number, starting at 0.
  Char getLocalVariable(final Char localNum) {
    return locals[localNum.toInt()];
  }

  /// Returns the routine's return address.
  int getReturnAddress() {
    return returnAddress;
  }

  /// Sets the return address.
  void setReturnAddress(final int address) {
    this.returnAddress = address;
  }

  /// Returns the routine's return variable number or DISCARD_RESULT.
  Char getReturnVariable() {
    return returnVarNum;
  }

  /// Sets the routine's return variable number or DISCARD_RESULT.
  void setReturnVariable(final Char varnum) {
    returnVarNum = varnum;
  }

  /// Returns the stack pointer at invocation time.
  Char getInvocationStackPointer() {
    return invocationStackPointer;
  }

  /// Sets the stack pointer at invocation time.
  void setInvocationStackPointer(final Char stackpointer) {
    invocationStackPointer = stackpointer;
  }

  /// Returns the return value.
  Char getReturnValue() {
    return returnValue;
  }

  /// Sets the return value.
  void setReturnValue(final Char value) {
    returnValue = value;
  }
}

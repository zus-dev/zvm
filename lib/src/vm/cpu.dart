import '../../zvm.dart';

/// The possible variable types.
// NOTE: Alternative name can be CpuVariableType
enum VariableType { STACK, LOCAL, GLOBAL }

/// Cpu interface.
abstract class Cpu {
  /// Resets this object to initial state.
  void reset();

  /// Translates a packed string address into a byte address.
  int unpackStringAddress(Char packedAddress);

  /// Computes a branch target from an offset.
  void doBranch(int offset, int instructionLength);

  /// Returns the current program counter.
  int getPC();

  /// Sets the program counter to a new address.
  void setPC(int address);

  /// Increments the program counter by the specified offset.
  void incrementPC(int offset);

  /// Returns the global stack pointer. Equals the stack size.
  Char getSP();

  /// Returns the value at the top of the stack without removing it.
  Char getStackTop();

  /// Sets the value of the element at the top of the stack without
  /// incrementing the stack pointer.
  void setStackTop(Char value);

  /// Returns the evaluation stack element at the specified index.
  Char getStackElement(int index);

  /// Pushes the specified value on the user stack.
  bool pushStack(Char userstackAddress, Char value);

  /// Pops the specified value from the user stack.
  Char popStack(Char userstackAddress);

  /// Returns the value of the specified variable. 0 is the stack pointer,
  /// 0x01-0x0f are local variables, and 0x10-0xff are global variables.
  /// If the stack pointer is read from, its top value will be popped off.
  /// Throws IllegalStateException if a local variable is accessed without
  /// a subroutine context or if a non-existent local variable is accessed.
  Char getVariable(Char variableNumber);

  /// Sets the value of the specified variable. If the stack pointer is written
  /// to, the stack will contain one more value.
  /// Throws IllegalStateException if a local variable is accessed without
  /// a subroutine context or if a non-existent local variable is accessed.
  void setVariable(Char variableNumber, Char value);

  /// Pops the current routine context from the stack. It will also
  /// restore the state before the invocation of the routine, i.e. it
  /// will restore the program counter and the stack pointers and set
  /// the specified return value to the return variable.
  /// Throws IllegalStateException if no RoutineContext exists
  void returnWith(Char returnValue);

  /// Returns the state of the current routine context stack as a non-
  /// modifiable List. This is exposed to PortableGameState to take a
  /// machine state snapshot.
  /// @return the list of routine contexts
  List<RoutineContext> getRoutineContexts();

  /// Copies the list of routine contexts into this machine's routine context
  /// stack. This is a consequence of a restore operation.
  /// @param contexts a list of routine contexts
  void setRoutineContexts(List<RoutineContext> contexts);

  /// Returns the current routine context without affecting the state
  /// of the machine.
  RoutineContext getCurrentRoutineContext();

  /// Performs a routine call.
  RoutineContext call(Char routineAddress, int returnAddress, List<Char> args,
      Char returnVariable);
}

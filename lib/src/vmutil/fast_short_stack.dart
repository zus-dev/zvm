import '../../zvm.dart';

/// This class implements a faster version of the Z-machin main stack.
/// This combines abstract access with the bypassing of unnecessary
/// object creation.
class FastShortStack {
  List<Char> _values;
  int _stackpointer = 0;

  FastShortStack(final int size) {
    _values = List<Char>(size);
    _stackpointer = 0;
  }

  /// Returns the current stack pointer.
  int getStackPointer() {
    return _stackpointer;
  }

  /// Pushes a value on the stack and increases the stack pointer.
  void push(final Char value) {
    _values[_stackpointer++] = value;
  }

  /// Returns the top value of the stack without modifying the stack pointer.
  Char top() {
    return _values[_stackpointer - 1];
  }

  /// Replaces the top element with the specified value.
  void replaceTopElement(final Char value) {
    _values[_stackpointer - 1] = value;
  }

  /// Returns the size of the stack. Is equal to stack pointer, but has a
  /// different semantic meaning.
  int size() {
    return _stackpointer;
  }

  /// Returns the top value of the stack and decreases the stack pointer.
  Char pop() {
    return _values[--_stackpointer];
  }

  /// Returns the value at index of the stack, here stack is treated as an array.
  Char getValueAt(int index) {
    return _values[index];
  }
}

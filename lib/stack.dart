import 'dart:collection';

class Stack {
  final ListQueue<int> _list;

  Stack()
  : _list = ListQueue();

  Stack.from(Stack other) 
  : _list = ListQueue.from(other._list);

  /// push element in top of the stack.
  void push(int e) {
    _list.addLast(e);
  }
  
  /// get the top of the stack and delete it.
  int pop() {
    int res = _list.last;
    _list.removeLast();
    return res;
  }

  /// get the top of the stack without deleting it.
  int top() {
    return _list.last;
  }

  Stack clone() {
    return Stack.from(this);
  }
}
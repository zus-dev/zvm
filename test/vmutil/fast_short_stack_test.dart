import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  FastShortStack stack;

  setUp(() {
    stack = FastShortStack(123);
  });

  test('Initial', () {
    assertEquals(0, stack.getStackPointer());
    assertEquals(0, stack.size());
  });

  test('Size', () {
    stack.push(Char(1));
    assertEquals(1, stack.size());
    stack.push(Char(3));
    assertEquals(2, stack.size());
    stack.pop();
    assertEquals(1, stack.size());
  });

  test('PushTop', () {
    stack.push(Char(3));
    assertEquals(1, stack.getStackPointer());
    assertEquals(3, stack.top());
    assertEquals(1, stack.getStackPointer());
  });

  test('PushPop', () {
    stack.push(Char(3));
    assertEquals(3, stack.pop());
    assertEquals(0, stack.getStackPointer());
  });

  test('GetValueAt', () {
    stack.push(Char(3));
    stack.push(Char(5));
    stack.push(Char(7));
    assertEquals(3, stack.getValueAt(0));
    assertEquals(5, stack.getValueAt(1));
    assertEquals(7, stack.getValueAt(2));
    assertEquals(3, stack.getStackPointer());
  });

  test('ReplaceTopElement', () {
    stack.push(Char(3));
    stack.push(Char(5));
    stack.push(Char(7));
    stack.replaceTopElement(Char(11));
    assertEquals(11, stack.top());
    assertEquals(3, stack.size());
  });
}

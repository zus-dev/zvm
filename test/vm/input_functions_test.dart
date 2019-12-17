import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  MockMachine machine;
  InputFunctions inputFunctions;
  int textbuffer;

  setUp(() {
    machine = MockMachine();
    inputFunctions = InputFunctions(machine);
    textbuffer = 4711;
  });

  /// Simple case: NULL as terminator.
  test('HandleTerminateCharNull', () {
    Char result = inputFunctions.handleTerminateChar(Char(IZsciiEncoding.NULL));
    assertEquals(IZsciiEncoding.NULL, result);
  });

  /// Simple case: Newline as terminator.
  test('HandleTerminateCharNewline', () {
    Char result =
        inputFunctions.handleTerminateChar(Char(IZsciiEncoding.NEWLINE));
    assertEquals(IZsciiEncoding.NEWLINE, result);
    verify(machine.printZsciiChar(Char(IZsciiEncoding.NEWLINE))).called(1);
  });

  /// Some other function key.
  test('HandleTerminateSomeFunctionKey', () {
    Char result = inputFunctions.handleTerminateChar(Char(130));
    assertEquals(130, result);
  });

  // *********************************************************************
  // **** Testing the checkTermination() function
  // ***************************************************

  /// Terminated with null, so it was aborted, and input is empty.
  test('CheckTerminationV4Null', () {
    when(machine.getVersion()).thenReturn(4);

    int textpointer = 6;
    inputFunctions.checkTermination(
        Char(IZsciiEncoding.NULL), textbuffer, textpointer);

    verify(machine.getVersion()).called(1);
    verify(machine.writeUnsigned8(textbuffer, Char(0))).called(1);
  });

  test('Tokenize', () {
    final int parsebuffer = 123;
    final int dictionaryAddress = 456;
    final bool tokenize = true;

    when(machine.getVersion()).thenReturn(3);
    // reading input
    when(machine.readUnsigned8(textbuffer)).thenReturn(Char(4));
    when(machine.readUnsigned8(textbuffer + 1)).thenReturn(Char.of('w'));
    when(machine.readUnsigned8(textbuffer + 2)).thenReturn(Char.of('a'));
    when(machine.readUnsigned8(textbuffer + 3)).thenReturn(Char.of('i'));
    when(machine.readUnsigned8(textbuffer + 4)).thenReturn(Char.of('t'));
    when(machine.getDictionaryDelimiters()).thenReturn(", \t\n");
    // filling parse buffer
    when(machine.readUnsigned8(parsebuffer)).thenReturn(Char(10));
    // lookup
    when(machine.lookupToken(dictionaryAddress, "wait")).thenReturn(987);

    inputFunctions.tokenize(
        textbuffer, parsebuffer, dictionaryAddress, tokenize);

    verify(machine.getVersion()).called(1);
    // reading input
    verify(machine.readUnsigned8(textbuffer)).called(1);
    verify(machine.readUnsigned8(textbuffer + 1)).called(1);
    verify(machine.readUnsigned8(textbuffer + 2)).called(1);
    verify(machine.readUnsigned8(textbuffer + 3)).called(1);
    verify(machine.readUnsigned8(textbuffer + 4)).called(1);
    verify(machine.getDictionaryDelimiters()).called(1);
    // filling parse buffer
    verify(machine.readUnsigned8(parsebuffer)).called(1);
    verify(machine.writeUnsigned8(parsebuffer + 1, Char(1))).called(1);
    // lookup
    verify(machine.lookupToken(dictionaryAddress, "wait")).called(1);
    // write parse buffer
    verify(machine.writeUnsigned16(parsebuffer + 2, Char(987))).called(1);
    verify(machine.writeUnsigned8(parsebuffer + 4, Char(4))).called(1);
    verify(machine.writeUnsigned8(parsebuffer + 5, Char(1))).called(1);
  });

  /// Terminated with newline, so 0 is appended to the input.
  test('CheckTerminationV4Newline', () {
    final int textpointer = 6;

    when(machine.getVersion()).thenReturn(4);

    inputFunctions.checkTermination(
        Char(IZsciiEncoding.NEWLINE), textbuffer, textpointer);

    verify(machine.getVersion()).called(1);
    verify(machine.writeUnsigned8(textbuffer + textpointer, Char(0))).called(1);
  });

  /// Version 5 and the last character is null, print 0 to the beginning of the
  /// text buffer.
  test('CheckTerminationV5Null', () {
    final int textpointer = 6;

    when(machine.getVersion()).thenReturn(5);

    inputFunctions.checkTermination(
        Char(IZsciiEncoding.NULL), textbuffer, textpointer);

    verify(machine.getVersion()).called(1);
    verify(machine.writeUnsigned8(textbuffer + 1, Char(0))).called(1);
  });

  /// Version 5 and the last character is newline, print 5 to byte 1 of the
  /// text buffer.
  test('CheckTerminationV5Newline', () {
    final int textpointer = 6;
    when(machine.getVersion()).thenReturn(5);

    inputFunctions.checkTermination(
        Char(IZsciiEncoding.NEWLINE), textbuffer, textpointer);

    verify(machine.getVersion()).called(1);
    verify(machine.writeUnsigned8(textbuffer + 1, Char(textpointer - 2)))
        .called(1);
  });
}

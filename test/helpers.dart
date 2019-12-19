import "dart:io";

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

class MockMemory extends Mock implements Memory {}

class MockZCharDecoder extends Mock implements ZCharDecoder {}

class MockZCharEncoder extends Mock implements ZCharEncoder {}

class MockMachine extends Mock implements Machine {}

class MockStoryFileHeader extends Mock implements StoryFileHeader {}

class MockAbbreviationsTable extends Mock implements AbbreviationsTable {}

/// Asserts that two objects are equal. If expected and actual are null, they are considered equal.
void assertEquals(Object expected, Object actual) {
  if (actual is Short && expected is int) {
    expect(actual.toInt(), equals(expected));
  } else if (actual is int && expected is Char) {
    expect(actual, expected.toInt());
  } else if (actual is Char && expected is int) {
    expect(actual.toInt(), equals(expected));
  } else if (actual is Char && expected is String) {
    expect(actual.toString(), equals(expected));
  } else {
    expect(actual, equals(expected));
  }
}

void assertFalse(bool actual) {
  expect(actual, isFalse);
}

void assertTrue(bool actual) {
  expect(actual, isTrue);
}

/// Asserts that two objects do not refer to the same object.
void assertNotSame<T>(T unexpected, T actual) {
  expect(actual, isNot(same(unexpected)));
}

/// Asserts that two objects refer to the same object.
void assertSame(Object expected, Object actual) {
  expect(actual, same(expected));
}

void assertNotNull(Object actual) {
  expect(actual, isNotNull);
}

void assertNull(Object actual) {
  expect(actual, isNull);
}

void assertArraysEquals(Iterable actual, Iterable expected) {
  expect(actual, orderedEquals(expected));
}

ByteArray readTestFileAsByteArray(String fileName) {
  final s = Platform.pathSeparator;
  final testSaveFile = File('testfiles${s}${fileName}');
  return ByteArray(testSaveFile.readAsBytesSync());
}

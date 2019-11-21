import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

class MockMemory extends Mock implements Memory {}

/// Asserts that two objects are equal. If expected and actual are null, they are considered equal.
void assertEquals(Object expected, Object actual) {
  if (actual is Short && expected is int) {
    expect(actual.toInt(), equals(expected));
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

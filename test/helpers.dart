import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

class MockMemory extends Mock implements Memory {}

void assertEquals(Object expected, Object actual) {
  if (actual is Short && expected is int) {
    expect(actual.toInt(), equals(expected));
  } else if (actual is Char && expected is int) {
    expect(actual.toInt(), equals(expected));
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

void assertNotSame<T>(T unexpected, T actual) {
  expect(actual, isNot(unexpected));
}

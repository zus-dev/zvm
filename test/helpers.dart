import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

void assertEquals(Object expected, Object actual) {
  if (actual is Short && expected is int) {
    expect(actual.toInt(), equals(expected));
  }  else if (actual is Char && expected is int) {
    expect(actual.toInt(), equals(expected));
  } else {
    expect(actual, equals(expected));
  }
}

void assertNotSame<T>(T unexpected, T actual) {
  expect(actual, isNot(unexpected));
}
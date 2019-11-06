import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

void assertEquals<T>(T expected, T actual) {
  if (actual is Char) {
    expect(actual.code, equals(expected));
  } else {
    expect(actual, equals(expected));
  }
}

void assertNotSame<T>(T unexpected, T actual) {
  expect(actual, isNot(unexpected));
}
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

main() {

  test('delimiters', () {
    StringTokenizer st = StringTokenizer("This:is:a:test:String", ":");
    expect(st.countTokens() == 5 && (st.nextElement() == "This"), isTrue, reason: "Created incorrect tokenizer");
  });

  test('returnDelimiters', () {
    StringTokenizer st = StringTokenizer("This:is:a:test:String", ":", true);
    st.nextElement();
    expect(st.countTokens() == 8 && (st.nextElement() == ":"), isTrue, reason: "Created incorrect tokenizer");
  });

  test('countTokens', () {
    StringTokenizer st = StringTokenizer("This is a test String");

    expect(st.countTokens(), equals(5), reason: "Incorrect token count returned");
  });

  test('hasMoreElements', () {
    StringTokenizer st = StringTokenizer("This is a test String");
    st.nextElement();
    expect(st.hasMoreElements(), isTrue, reason: "hasMoreElements returned incorrect value");
    st.nextElement();
    st.nextElement();
    st.nextElement();
    st.nextElement();
    expect(!st.hasMoreElements(), isTrue, reason: "hasMoreElements returned incorrect value");
  });

  test('hasMoreTokens', () {
    StringTokenizer st = StringTokenizer("This is a test String");
    for (int counter = 0; counter < 5; counter++) {
      expect(st.hasMoreTokens(), isTrue, reason: "StringTokenizer incorrectly reports it has no more tokens");
      st.nextToken();
    }
    expect(!st.hasMoreTokens(), isTrue, reason: "StringTokenizer incorrectly reports it has more tokens");
  });

  test('nextElement', () {
    StringTokenizer st = StringTokenizer("This is a test String");
    expect(st.nextElement() as String, equals("This"), reason: "nextElement returned incorrect value");
    expect(st.nextElement() as String, equals("is"), reason: "nextElement returned incorrect value");
    expect(st.nextElement() as String, equals("a"), reason: "nextElement returned incorrect value");
    expect(st.nextElement() as String, equals("test"), reason: "nextElement returned incorrect value");
    expect(st.nextElement() as String, equals("String"), reason: "nextElement returned incorrect value");
    expect(() => st.nextElement(), throwsA(isA<NoSuchElementException>()), reason: "nextElement failed to throw a NoSuchElementException when it should have been out of elements");
  });

  test('nextToken', () {
    StringTokenizer st = StringTokenizer("This is a test String");
    expect(st.nextToken(), equals("This"), reason: "nextToken returned incorrect value");
    expect(st.nextToken(), equals("is"), reason: "nextToken returned incorrect value");
    expect(st.nextToken(), equals("a"), reason: "nextToken returned incorrect value");
    expect(st.nextToken(), equals("test"), reason: "nextToken returned incorrect value");
    expect(st.nextToken(), equals("String"), reason: "nextToken returned incorrect value");
    expect(() => st.nextToken(), throwsA(isA<NoSuchElementException>()), reason: "nextToken failed to throw a NoSuchElementException when it should have been out of elements");
  });

  test('nextToken_String', () {
    StringTokenizer st = StringTokenizer("This is a test String");
    expect(st.nextToken(" "), equals("This"), reason: "nextToken(String) returned incorrect value with normal token String");
    expect(st.nextToken("tr"), equals(" is a "), reason: "nextToken(String) returned incorrect value with custom token String");
    expect(st.nextToken(), equals("es"), reason: "calling nextToken() did not use the new default delimiter list");
  });

  /*test('hasMoreElements_NPE', () {
    StringTokenizer stringTokenizer = new StringTokenizer("", null, true);
    expect(() => stringTokenizer.hasMoreElements(), throwsNoSuchMethodError, reason: "should throw NoSuchMethodError");
    stringTokenizer = new StringTokenizer("", null);
    expect(() => stringTokenizer.hasMoreElements(), throwsNoSuchMethodError, reason: "should throw NoSuchMethodError");
  });
  test('hasMoreTokens_NPE', () {
    StringTokenizer stringTokenizer = new StringTokenizer("", null, true);
    expect(() => stringTokenizer.hasMoreTokens(), throwsNoSuchMethodError, reason: "should throw NoSuchMethodError");
    stringTokenizer = new StringTokenizer("", null);
    expect(() => stringTokenizer.hasMoreTokens(), throwsNoSuchMethodError, reason: "should throw NoSuchMethodError");
  });
  test('nextElement_NPE', () {
    StringTokenizer stringTokenizer = new StringTokenizer("", null, true);
    expect(() => stringTokenizer.nextElement(), throwsNoSuchMethodError, reason: "should throw NoSuchMethodError");
    stringTokenizer = new StringTokenizer("", null);
    expect(() => stringTokenizer.nextElement(), throwsNoSuchMethodError, reason: "should throw NoSuchMethodError");
  });
  test('nextToken_NPE', () {
    StringTokenizer stringTokenizer = new StringTokenizer("", null, true);
    expect(() => stringTokenizer.nextToken(), throwsNoSuchMethodError, reason: "should throw NoSuchMethodError");
    stringTokenizer = new StringTokenizer("", null);
    expect(() => stringTokenizer.nextToken(), throwsNoSuchMethodError, reason: "should throw NoSuchMethodError");
  });
  test('nextToken_String_NPE', () {
    StringTokenizer stringTokenizer = new StringTokenizer("");
    expect(() => stringTokenizer.nextToken(null), throwsNoSuchMethodError, reason: "should throw NoSuchMethodError");
  });*/
}
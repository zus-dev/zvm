import "dart:io";

import "package:test/test.dart";
import "package:zvm/z_screen.dart";

void main() {
  final s = Platform.pathSeparator;
  final zfile = File('test${s}res${s}minizork.z3');

  try {
    var bytes = zfile.readAsBytesSync();
  } on Exception catch (fe) {
    print('$fe');
    exit(1);
  }

  test("unicode_to_zascii", () {
    expect(ZScreen.unicode_to_zascii('L'), equals(76));
    expect(ZScreen.unicode_to_zascii('o'), equals(111));
    expect(ZScreen.unicode_to_zascii('k'), equals(107));
    expect(ZScreen.unicode_to_zascii('\n'), equals(13));
    expect(ZScreen.unicode_to_zascii('\b'), equals(127));
    expect(ZScreen.unicode_to_zascii('\t'), equals(9));
    expect(ZScreen.unicode_to_zascii('\u00e4'), equals(155));
    expect(ZScreen.unicode_to_zascii('\u00fc'), equals(157));
    expect(ZScreen.unicode_to_zascii('\u00bf'), equals(223));
    expect(ZScreen.unicode_to_zascii('\u001b'), equals(27));
  });

  test("zascii_to_unicode", () {
    expect(ZScreen.zascii_to_unicode(76), equals('L'));
    expect(ZScreen.zascii_to_unicode(111), equals('o'));
    expect(ZScreen.zascii_to_unicode(107), equals('k'));
    expect(ZScreen.zascii_to_unicode(13), equals('\n'));
    expect(ZScreen.zascii_to_unicode(127), equals('\b'));
    expect(ZScreen.zascii_to_unicode(9), equals('\t'));
    expect(ZScreen.zascii_to_unicode(155), equals('\u00e4'));
    expect(ZScreen.zascii_to_unicode(157), equals('\u00fc'));
    expect(ZScreen.zascii_to_unicode(223), equals('\u00bf'));
    expect(ZScreen.zascii_to_unicode(27), equals('\u001b'));
  });

  test("String.split() splits the string on the delimiter", () {
    var string = "foo,bar,baz";
    expect(string.split(","), equals(["foo", "bar", "baz"]));
  });

  test("String.trim() removes surrounding whitespace", () {
    var string = "  foo ";
    expect(string.trim(), equals("foo"));
  });
}
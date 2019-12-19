import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  test('DictionarySizesV4ToV8', () {
    DictionarySizes sizes = DictionarySizesV4ToV8();
    assertEquals(6, sizes.getNumEntryBytes());
    assertEquals(9, sizes.getMaxEntryChars());
  });

  test('DictionarySizesV1ToV3', () {
    DictionarySizes sizes = DictionarySizesV1ToV3();
    assertEquals(4, sizes.getNumEntryBytes());
    assertEquals(6, sizes.getMaxEntryChars());
  });
}

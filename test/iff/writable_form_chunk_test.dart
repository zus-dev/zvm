import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  WritableFormChunk formChunk;

  setUp(() {
    formChunk = WritableFormChunk(ByteArray.fromString("IFhd"));
  });

  test('IsValid', () {
    assertTrue(formChunk.isValid());
    assertNotNull(formChunk.getMemory());
    assertNotNull(formChunk.getSubChunks());
    assertNull(formChunk.getSubChunkByAddress(1234));
    assertEquals(0, formChunk.getAddress());
  });
}

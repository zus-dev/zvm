import "dart:io";

import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  Memory formChunkData;
  FormChunk formChunk;

  setUp(() {
    final s = Platform.pathSeparator;
    final testSaveFile = File('testfiles${s}leathersave.ifzs');
    final data = ByteArray(testSaveFile.readAsBytesSync());
    formChunkData = DefaultMemory(data);
    formChunk = DefaultFormChunk(formChunkData);
  });

  test('InvalidIff', () {
    final illegalData = ByteArray([
      0x01, 0x02, 0x03, 0x04, 0x05, //
      0x01, 0x02, 0x03, 0x04, 0x05,
      0x01, 0x02, 0x03, 0x04, 0x05,
      0x01, 0x02, 0x03, 0x04, 0x05,
    ]);
    // IOException should be thrown on an illegal IFF file
    expect(() => DefaultFormChunk(DefaultMemory(illegalData)),
        throwsA((e) => e is IOException && e.getMessage() != null));
  });

  test('Creation', () {
    assertTrue(formChunk.isValid());
    assertEquals("FORM", formChunk.getId());
    assertEquals(512, formChunk.getSize());
    assertEquals("IFZS", formChunk.getSubId());
  });

  test('Subchunks', () {
    final iter = formChunk.getSubChunks();
    final result = List<Chunk>();

    while (iter.moveNext()) {
      Chunk chunk = iter.current;
      assertTrue(chunk.isValid());
      result.add(chunk);
    }
    assertEquals("IFhd", result[0].getId());
    assertEquals(13, result[0].getSize());
    assertEquals(0x000c, result[0].getAddress());
    assertEquals("CMem", result[1].getId());
    assertEquals(351, result[1].getSize());
    assertEquals(0x0022, result[1].getAddress());
    assertEquals("Stks", result[2].getId());
    assertEquals(118, result[2].getSize());
    assertEquals(0x018a, result[2].getAddress());
    assertEquals(3, result.length);
  });

  test('GetSubChunk', () {
    assertNotNull(formChunk.getSubChunk("IFhd"));
    assertNotNull(formChunk.getSubChunk("CMem"));
    assertNotNull(formChunk.getSubChunk("Stks"));
    assertNull(formChunk.getSubChunk("Test"));
  });

  test('GetSubChunkByAddress', () {
    assertEquals("IFhd", formChunk.getSubChunkByAddress(0x000c).getId());
    assertEquals("CMem", formChunk.getSubChunkByAddress(0x0022).getId());
    assertEquals("Stks", formChunk.getSubChunkByAddress(0x018a).getId());
    assertNull(formChunk.getSubChunkByAddress(0x1234));
  });
}

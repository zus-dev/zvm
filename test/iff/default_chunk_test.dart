import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  test('CreateChunkForWriting', () {
    var id = ByteArray([codeOf('F'), codeOf('O'), codeOf('R'), codeOf('M')]);
    var chunkdata = ByteArray([0x01, 0x02, 0x03]);
    var chunk = DefaultChunk.forWrite(id, chunkdata);
    assertEquals(3, chunk.getSize());
    assertEquals("FORM", chunk.getId());
    assertEquals(0, chunk.getAddress());
    Memory mem = chunk.getMemory();
    assertEquals('F', mem.readUnsigned8(0));
    assertEquals('O', mem.readUnsigned8(1));
    assertEquals('R', mem.readUnsigned8(2));
    assertEquals('M', mem.readUnsigned8(3));
    assertEquals(3, readUnsigned32(mem, 4));
    assertEquals(0x01, mem.readUnsigned8(8));
    assertEquals(0x02, mem.readUnsigned8(9));
    assertEquals(0x03, mem.readUnsigned8(10));
  });

  test('CreateChunkForReading', () {
    var data = ByteArray([
      codeOf('F'),
      codeOf('O'),
      codeOf('R'),
      codeOf('M'),
      0x00,
      0x00,
      0x00,
      0x03,
      0x01,
      0x02,
      0x03
    ]);
    var mem = DefaultMemory(data);
    var chunk = DefaultChunk.forRead(mem, 1234);
    assertEquals(1234, chunk.getAddress());
    assertEquals("FORM", chunk.getId());
    assertSame(mem, chunk.getMemory());
    assertEquals(3, chunk.getSize());
  });
}

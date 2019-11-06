import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  Memory memory;

  setUp(() {
    var data = ByteArray([0x03, 0x00, 0x37, 0x09, 0xff, 0xff]);
    memory = DefaultMemory(data);
  });

  test('ToUnsigned16', () {
    assertEquals(1234, MemoryUtil.toUnsigned16(1234));
  });

  test('ReadUnsigned32', () {
    var data32 = ByteArray([0xd7, 0x4b, 0xd7, 0x53 ]);
    var memaccess = DefaultMemory(data32);
    assertEquals(0xd74bd753, MemoryUtil.readUnsigned32(memaccess, 0x00));
  });

  test('WriteUnsigned32', () {
    MemoryUtil.writeUnsigned32(memory, 0x00, 0xffffffff);
    assertEquals(0x00000000ffffffff, MemoryUtil.readUnsigned32(memory, 0x00));

    MemoryUtil.writeUnsigned32(memory, 0x00, 0xf0f00f0f);
    assertEquals(0x00000000f0f00f0f, MemoryUtil.readUnsigned32(memory, 0x00));
  });

  test('SignedToUnsigned16', () {
    assertEquals(0, MemoryUtil.signedToUnsigned16(Short(0)));
    assertEquals(Char(0xffff), MemoryUtil.signedToUnsigned16(Short(-1)));
    assertEquals(Char(0xfffe), MemoryUtil.signedToUnsigned16(Short(-2)));
    assertEquals(Char(32767), MemoryUtil.signedToUnsigned16(Short(32767)));
    assertEquals(Char(32768), MemoryUtil.signedToUnsigned16(Short(-32768)));
  });

  test('UnsignedToSigned16', () {
    assertEquals(0, MemoryUtil.unsignedToSigned16(Char(0)));
    assertEquals(1, MemoryUtil.unsignedToSigned16(Char(1)));
    assertEquals(-32768, MemoryUtil.unsignedToSigned16(Char(32768)));
    assertEquals(32767, MemoryUtil.unsignedToSigned16(Char(32767)));
    assertEquals(-1, MemoryUtil.unsignedToSigned16(Char(65535)));
  });

  test('UnsignedToSigned8', () {
    assertEquals(0, MemoryUtil.unsignedToSigned8(Char(0)));
    assertEquals(1, MemoryUtil.unsignedToSigned8(Char(1)));
    assertEquals(-128, MemoryUtil.unsignedToSigned8(Char(128)));
    assertEquals(127, MemoryUtil.unsignedToSigned8(Char(127)));
    assertEquals(-1, MemoryUtil.unsignedToSigned8(Char(0xff)));
    assertEquals(-1, MemoryUtil.unsignedToSigned8(Char(0x10ff)));
  });
}

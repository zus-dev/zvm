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
    assertEquals(1234, toUnsigned16(1234));
  });

  test('ReadUnsigned32', () {
    var data32 = ByteArray([0xd7, 0x4b, 0xd7, 0x53]);
    var memaccess = DefaultMemory(data32);
    assertEquals(0xd74bd753, readUnsigned32(memaccess, 0x00));
  });

  test('WriteUnsigned32', () {
    writeUnsigned32(memory, 0x00, 0xffffffff);
    assertEquals(0x00000000ffffffff, readUnsigned32(memory, 0x00));

    writeUnsigned32(memory, 0x00, 0xf0f00f0f);
    assertEquals(0x00000000f0f00f0f, readUnsigned32(memory, 0x00));
  });

  test('SignedToUnsigned16', () {
    assertEquals(0, signedToUnsigned16(0));
    assertEquals(Char(0xffff), signedToUnsigned16(-1));
    assertEquals(Char(0xfffe), signedToUnsigned16(-2));
    assertEquals(Char(32767), signedToUnsigned16(32767));
    assertEquals(Char(32768), signedToUnsigned16(-32768));
  });

  test('UnsignedToSigned16', () {
    assertEquals(0, unsignedToSigned16(Char(0)));
    assertEquals(1, unsignedToSigned16(Char(1)));
    assertEquals(-32768, unsignedToSigned16(Char(32768)));
    assertEquals(32767, unsignedToSigned16(Char(32767)));
    assertEquals(-1, unsignedToSigned16(Char(65535)));
  });

  test('UnsignedToSigned8', () {
    assertEquals(0, unsignedToSigned8(Char(0)));
    assertEquals(1, unsignedToSigned8(Char(1)));
    assertEquals(-128, unsignedToSigned8(Char(128)));
    assertEquals(127, unsignedToSigned8(Char(127)));
    assertEquals(-1, unsignedToSigned8(Char(0xff)));
    assertEquals(-1, unsignedToSigned8(Char(0x10ff)));
  });
}

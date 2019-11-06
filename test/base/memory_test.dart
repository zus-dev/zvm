import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  Memory memory;

  setUp(() {
    var data = ByteArray([0x03, 0x00, 0x37, 0x09, 0xff, 0xff]);
    memory = DefaultMemory(data);
  });

  test('ReadUnsignedByte', () {
    assertEquals(3, memory.readUnsigned8(0x00));
  });

  test('ReadUnsignedWord', () {
    assertEquals(0x3709, memory.readUnsigned16(0x02));
  });

  test('GetUnsignedShortGeneral', () {
    assertEquals(0xffff, memory.readUnsigned16(0x04));
    assertNotSame(-1, memory.readUnsigned16(0x04));
  });

  test('WriteUnsignedByte', () {
    memory.writeUnsigned8(0x02, Char(0xff));
    assertEquals(0xff, memory.readUnsigned8(0x02));

    memory.writeUnsigned8(0x03, Char(0x32));
    assertEquals(0x32, memory.readUnsigned8(0x03));
  });

  test('WriteUnsignedShort', () {
    memory.writeUnsigned16(0x02, Char(0xffff));
    assertEquals(0xffff, memory.readUnsigned16(0x02));
    memory.writeUnsigned16(0x04, Char(0x00ff));
    assertEquals(0x00ff, memory.readUnsigned16(0x04));
  });

  test('CopyBytesToArray', () {
    var dstData = ByteArray(Uint8List(4));
    int dstOffset = 1;
    int srcOffset = 2;
    int numBytes = 3;
    memory.copyBytesToArray(dstData, dstOffset, srcOffset, numBytes);
    assertEquals(0x37, dstData[1]);
    assertEquals(0x09, dstData[2]);
    assertEquals(byte(0xff), dstData[3]);
  });

  test('CopyBytesFromArray', () {
    var srcData = ByteArray([0x00, 0xef, 0x10, 0xfe]);
    int srcOffset = 1;
    int dstOffset = 0;
    int numBytes = 3;
    memory.copyBytesFromArray(srcData, srcOffset, dstOffset, numBytes);
    assertEquals(0xef, memory.readUnsigned8(0));
    assertEquals(0x10, memory.readUnsigned8(1));
    assertEquals(0xfe, memory.readUnsigned8(2));
  });

  test('CopyBytesFromMemory', () {
    var dstData = ByteArray([0x00, 0x00, 0x00, 0x00]);
    var srcData = ByteArray([0x00, 0xef, 0x10, 0xfe]);
    Memory srcMem = DefaultMemory(srcData);
    Memory dstMem = DefaultMemory(dstData);
    int srcOffset = 1;
    int dstOffset = 0;
    int numBytes = 3;
    dstMem.copyBytesFromMemory(srcMem, srcOffset, dstOffset, numBytes);
    assertEquals(0xef, dstMem.readUnsigned8(0));
    assertEquals(0x10, dstMem.readUnsigned8(1));
    assertEquals(0xfe, dstMem.readUnsigned8(2));
  });

  test('CopyArea', () {
    memory.copyArea(0, 2, 3);
    assertEquals(0x03, memory.readUnsigned8(0));
    assertEquals(0x00, memory.readUnsigned8(1));
    assertEquals(0x03, memory.readUnsigned8(2));
    assertEquals(0x00, memory.readUnsigned8(3));
    assertEquals(0x37, memory.readUnsigned8(4));
  });
}

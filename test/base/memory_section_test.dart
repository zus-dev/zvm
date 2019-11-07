import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  final int OFFSET = 36;
  MockMemory memory;
  MemorySection section;

  setUp(() {
    memory = MockMemory();
    section = MemorySection(memory, OFFSET, 256);
  });

  test('GetLength', () {
    assertEquals(256, section.getLength());
  });

  test('WriteUnsignedShort', () {
    section.writeUnsigned16(12, Char(512));
    verify(memory.writeUnsigned16(12 + 36, Char(512))).called(1);
  });

  test('WriteUnsignedByte', () {
    section.writeUnsigned8(12, Char(120));
    verify(memory.writeUnsigned8(12 + 36, Char(120))).called(1);
  });

  test('CopyBytesFromArray', () {
    final ByteArray srcData = ByteArray.length(5);
    final int srcOffset = 2;
    final int dstOffset = 3;
    final int numBytes = 23;
    section.copyBytesFromArray(srcData, srcOffset, dstOffset, numBytes);
    verify(memory.copyBytesFromArray(
            srcData, srcOffset, OFFSET + dstOffset, numBytes))
        .called(1);
  });

  test('CopyBytesFromMemory', () {
    final MockMemory srcMem = MockMemory();
    final int srcOffset = 2;
    final int dstOffset = 3;
    final int numBytes = 5;
    section.copyBytesFromMemory(srcMem, srcOffset, dstOffset, numBytes);
    verify(memory.copyBytesFromMemory(
            srcMem, srcOffset, OFFSET + dstOffset, numBytes))
        .called(1);
  });

  test('CopyArea', () {
    final int src = 1, dst = 2, numBytes = 10;
    section.copyArea(src, dst, numBytes);
    verify(memory.copyArea(OFFSET + src, OFFSET + dst, numBytes));
  });
}

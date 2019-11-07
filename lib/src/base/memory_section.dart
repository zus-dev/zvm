import '../helpers.dart';
import 'memory.dart';

class MemorySection implements Memory {
  Memory memory;
  int start = 0;
  int length = 0;

  /// Creates section of the [memory] object from the [start] with [length].
  MemorySection(this.memory, this.start, this.length);

  /// Returns the length of this memory section in bytes.
  int getLength() {
    return length;
  }

  void writeUnsigned16(final int address, final Char value) {
    memory.writeUnsigned16(address + start, value);
  }

  void writeUnsigned8(final int address, final Char value) {
    memory.writeUnsigned8(address + start, value);
  }

  Char readUnsigned16(final int address) {
    return memory.readUnsigned16(address + start);
  }

  Char readUnsigned8(final int address) {
    return memory.readUnsigned8(address + start);
  }

  void copyBytesToArray(
      ByteArray dstData, int dstOffset, int srcOffset, int numBytes) {
    memory.copyBytesToArray(dstData, dstOffset, srcOffset + start, numBytes);
  }

  void copyBytesFromArray(
      ByteArray srcData, int srcOffset, int dstOffset, int numBytes) {
    memory.copyBytesFromArray(srcData, srcOffset, dstOffset + start, numBytes);
  }

  void copyBytesFromMemory(
      Memory srcMem, int srcOffset, int dstOffset, int numBytes) {
    memory.copyBytesFromMemory(srcMem, srcOffset, dstOffset + start, numBytes);
  }

  void copyArea(int src, int dst, int numBytes) {
    memory.copyArea(src + start, dst + start, numBytes);
  }
}

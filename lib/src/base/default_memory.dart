import 'helpers.dart';
import 'memory.dart';

/// This class is the default implementation for MemoryAccess.
class DefaultMemory implements Memory {
  /// The data array containing the story file.
  final ByteArray data;

  /// Creates from the story file [data].
  DefaultMemory(this.data) {
    assert(this.data != null);
  }

  Char readUnsigned16(int address) {
    return Char(
        ((data[address] & 0xff) << 8 | (data[address + 1] & 0xff)) & 0xffff);
  }

  Char readUnsigned8(int address) {
    return Char(data[address] & 0xff);
  }

  void writeUnsigned16(final int address, final Char value) {
    data[address] = (byte)((value.toInt() & 0xff00) >> 8);
    data[address + 1] = (byte)(value.toInt() & 0xff);
  }

  void writeUnsigned8(final int address, final Char value) {
    data[address] = (byte)(value.toInt() & 0xff);
  }

  void copyBytesToArray(
      ByteArray dstData, int dstOffset, int srcOffset, int numBytes) {
    arraycopy(data, srcOffset, dstData, dstOffset, numBytes);
  }

  void copyBytesFromArray(
      ByteArray srcData, int srcOffset, int dstOffset, int numBytes) {
    arraycopy(srcData, srcOffset, data, dstOffset, numBytes);
  }

  void copyBytesFromMemory(
      Memory srcMem, int srcOffset, int dstOffset, int numBytes) {
    // This copy method might not be as efficient, because the source
    // memory object could be based on something else than a byte array
    for (int i = 0; i < numBytes; i++) {
      data[dstOffset + i] =
          (byte)(srcMem.readUnsigned8(srcOffset + i).toInt() & 0xff);
    }
  }

  void copyArea(int src, int dst, int numBytes) {
    arraycopy(data, src, data, dst, numBytes);
  }
}

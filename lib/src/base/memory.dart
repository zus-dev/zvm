import 'helpers.dart';

/// This class manages read and write access to the byte array which contains
/// the story file data. It is the only means to read and manipulate the
/// memory map.
abstract class Memory {
  /// Reads the unsigned 16 bit word at the specified [address].
  Char readUnsigned16(int address);

  /// Returns the unsigned 8 bit value at the specified [address].
  Char readUnsigned8(int address);

  /// Writes an unsigned 16 bit [value] to the specified [address].
  void writeUnsigned16(int address, Char value);

  /// Writes an unsigned byte [value] to the specified [address].
  void writeUnsigned8(int address, Char value);

  /// Copy the specified [numBytes] from the offset to a [dstData].
  void copyBytesToArray(
      ByteArray dstData, int dstOffset, int srcOffset, int numBytes);

  /// Copy the specified [numBytes] from the [srcData] to this Memory object.
  void copyBytesFromArray(
      ByteArray srcData, int srcOffset, int dstOffset, int numBytes);

  /// Copy the specified number of bytes from the specified source Memory object.
  void copyBytesFromMemory(
      Memory srcMem, int srcOffset, int dstOffset, int numBytes);

  /// Copy an area of bytes efficiently.
  void copyArea(int src, int dst, int numBytes);
}

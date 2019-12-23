import '../helpers.dart';
import 'memory.dart';

/// Convert an integer [value] to a char, which is an unsigned 16 bit value.
Char toUnsigned16(int value) {
  return Char(value & 0xffff);
}

/// Reads the unsigned 32 bit word at the specified [address] from the [memory].
int readUnsigned32(Memory memory, int address) {
  final int a24 = (memory.readUnsigned8(address) & 0xff) << 24;
  final int a16 = (memory.readUnsigned8(address + 1) & 0xff) << 16;
  final int a8 = (memory.readUnsigned8(address + 2) & 0xff) << 8;
  final int a0 = (memory.readUnsigned8(address + 3) & 0xff);
  return a24 | a16 | a8 | a0;
}

/// Writes an unsigned 32 bit [value] at the specified [address] to the [memory].
void writeUnsigned32(Memory memory, final int address, final int value) {
// TODO: convert signed to unsigned?
  assert(value >= 0);
  memory.writeUnsigned8(address, Char((value & 0xff000000) >> 24));
  memory.writeUnsigned8(address + 1, Char((value & 0x00ff0000) >> 16));
  memory.writeUnsigned8(address + 2, Char((value & 0x0000ff00) >> 8));
  memory.writeUnsigned8(address + 3, Char(value & 0x000000ff));
}

/// Converts the specified signed 16 bit [value] to an unsigned 16 bit value.
Char signedToUnsigned16(int value) {
  var iv = value.toInt();
  return Char(iv >= 0 ? iv : Char.MAX_VALUE + (iv + 1));
}

/// Converts the specified unsigned 16 bit [value] to a signed 16 bit value.
int unsignedToSigned16(Char value) {
  var iv = value.toInt();
  return iv > Short.MAX_VALUE ? -(Char.MAX_VALUE - (iv - 1)) : iv;
}

/// Converts the specified unsigned 8 bit value to a signed 8 bit value.
/// If the value specified is actually a 16 bit value, only the lower 8 bit
/// will be used.
int unsignedToSigned8(Char value) {
  int iv = value & 0xff;
  return iv > Byte.MAX_VALUE ? -(255 - (iv - 1)) : iv;
}

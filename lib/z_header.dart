import 'dart:typed_data';

abstract class ZHeader {
  Uint8List memory_image;
  static final int VERSION = 0x00;
  static final int FLAGS1 = 0x01;
  static final int RELEASE = 0x02;
  static final int HIGH_BASE = 0x04;
  static final int INITIAL_PC = 0x06;
  static final int DICTIONARY = 0x08;
  static final int OBJECT_TABLE = 0x0A;
  static final int GLOBAL_TABLE = 0x0C;
  static final int STATIC_BASE = 0x0E;
  static final int FLAGS2 = 0x10;
  static final int SERIAL_NUMBER = 0x12;
  static final int ABBREV_TABLE = 0x18;
  static final int FILE_LENGTH = 0x1A;
  static final int FILE_CHECKSUM = 0x1C;
  static final int STD_REVISION = 0x32;

  int version() {
    return memory_image[VERSION];
  }

  int initial_pc() {
    return ((memory_image[INITIAL_PC] << 8) & 0xFF00) |
        ((memory_image[INITIAL_PC + 1]) & 0x00FF);
  }

  int dictionary() {
    return ((memory_image[DICTIONARY] << 8) & 0xFF00) |
        ((memory_image[DICTIONARY + 1]) & 0x00FF);
  }

  int object_table() {
    return ((memory_image[OBJECT_TABLE] << 8) & 0xFF00) |
        ((memory_image[OBJECT_TABLE + 1]) & 0x00FF);
  }

  int global_table() {
    return ((memory_image[GLOBAL_TABLE] << 8) & 0xFF00) |
        ((memory_image[GLOBAL_TABLE + 1]) & 0x00FF);
  }

  int static_base() {
    return ((memory_image[STATIC_BASE] << 8) & 0xFF00) |
        ((memory_image[STATIC_BASE + 1]) & 0x00FF);
  }

  bool transcripting() {
    return ((memory_image[FLAGS2 + 1] & 1) == 1);
  }

  void set_transcripting(bool onoff) {
    if (onoff) {
      memory_image[FLAGS2 + 1] |= 1;
    } else {
      memory_image[FLAGS2 + 1] &= 0xFE;
    }
  }

  int abbrev_table() {
    return ((memory_image[ABBREV_TABLE] << 8) & 0xFF00) |
        ((memory_image[ABBREV_TABLE + 1]) & 0x00FF);
  }

  bool force_fixed() {
    return ((memory_image[FLAGS2 + 1] & 2) == 2);
  }

  void set_revision(int major, int minor) {
    memory_image[STD_REVISION] = major;
    memory_image[STD_REVISION + 1] = minor;
  }

  int release() {
    return (((memory_image[RELEASE] & 0xFF) << 8) |
        (memory_image[RELEASE + 1] & 0xFF));
  }

  int checksum() {
    return (((memory_image[FILE_CHECKSUM] & 0xFF) << 8) |
        (memory_image[FILE_CHECKSUM + 1] & 0xFF));
  }

  int file_length();
}

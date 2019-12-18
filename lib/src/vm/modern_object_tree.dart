import '../../zvm.dart';

/// This class implements the object tree for story file version >= 4.
class ModernObjectTree extends AbstractObjectTree {
  static final int _OFFSET_PARENT = 6;
  static final int _OFFSET_SIBLING = 8;
  static final int _OFFSET_CHILD = 10;
  static final int _OFFSET_PROPERTYTABLE = 12;

  /// Object entries in version >= 4 have a size of 14 bytes.
  static final int _OBJECTENTRY_SIZE = 14;

  /// Property defaults entries in versions >= 4 have a size of 63 words.
  static final int _PROPERTYDEFAULTS_SIZE = 63 * 2;

  ModernObjectTree(Memory memory, int address) : super(memory, address);

  @override
  int getObjectAddress(int objectNum) {
    return getObjectTreeStart() + (objectNum - 1) * getObjectEntrySize();
  }

  @override
  int getPropertyDefaultsSize() {
    return _PROPERTYDEFAULTS_SIZE;
  }

  @override
  int getObjectEntrySize() {
    return _OBJECTENTRY_SIZE;
  }

  @override
  int getParent(final int objectNum) {
    return getMemory()
        .readUnsigned16(getObjectAddress(objectNum) + _OFFSET_PARENT)
        .toInt();
  }

  @override
  void setParent(final int objectNum, final int parent) {
    getMemory().writeUnsigned16(
        getObjectAddress(objectNum) + _OFFSET_PARENT, toUnsigned16(parent));
  }

  @override
  int getSibling(final int objectNum) {
    return getMemory()
        .readUnsigned16(getObjectAddress(objectNum) + _OFFSET_SIBLING)
        .toInt();
  }

  @override
  void setSibling(final int objectNum, final int sibling) {
    getMemory().writeUnsigned16(
        getObjectAddress(objectNum) + _OFFSET_SIBLING, toUnsigned16(sibling));
  }

  @override
  int getChild(final int objectNum) {
    return getMemory()
        .readUnsigned16(getObjectAddress(objectNum) + _OFFSET_CHILD)
        .toInt();
  }

  @override
  void setChild(final int objectNum, final int child) {
    getMemory().writeUnsigned16(
        getObjectAddress(objectNum) + _OFFSET_CHILD, toUnsigned16(child));
  }

  @override
  int getPropertyLength(final int propertyAddress) {
    return _getPropertyLengthAtData(getMemory(), propertyAddress);
  }

  @override
  int getPropertyTableAddress(int objectNum) {
    return getMemory()
        .readUnsigned16(getObjectAddress(objectNum) + _OFFSET_PROPERTYTABLE)
        .toInt();
  }

  @override
  int getNumPropertySizeBytes(final int propertyAddress) {
    // if bit 7 is set, there are two size bytes, one otherwise
    final Char first = getMemory().readUnsigned8(propertyAddress);
    return ((first & 0x80) > 0) ? 2 : 1;
  }

  @override
  int getNumPropSizeBytesAtData(int propertyDataAddress) {
    return getNumPropertySizeBytes(propertyDataAddress - 1);
  }

  @override
  int getPropertyNum(final int propertyAddress) {
    // Version >= 4 - take the lower 5 bit of the first size byte
    return getMemory().readUnsigned8(propertyAddress) & 0x3f;
  }

  /// This function represents the universal formula to calculate the length
  /// of a property given the address of its data (as opposed to the address
  /// of the property itself).
  static int _getPropertyLengthAtData(
      final Memory memory, final int addressOfPropertyData) {
    if (addressOfPropertyData == 0) {
      return 0; // see standard 1.1
    }
    // The size byte is always the byte before the property data in any
    // version, so this is consistent
    final Char sizebyte = memory.readUnsigned8(addressOfPropertyData - 1);

    // Bit 7 set => this is the second size byte
    if ((sizebyte & 0x80) > 0) {
      int proplen = sizebyte & 0x3f;
      if (proplen == 0) {
        proplen = 64; // Std. doc. 1.0, S 12.4.2.1.1
      }
      return proplen;
    } else {
      // Bit 7 clear => there is only one size byte, so if bit 6 is set,
      // the size is 2, else it is 1
      return (sizebyte & 0x40) > 0 ? 2 : 1;
    }
  }
}

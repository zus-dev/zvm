import '../../zvm.dart';

/// This class implements the object tree for story file version <= 3.
class ClassicObjectTree extends AbstractObjectTree {
  static final int _OFFSET_PARENT = 4;
  static final int _OFFSET_SIBLING = 5;
  static final int _OFFSET_CHILD = 6;
  static final int _OFFSET_PROPERTYTABLE = 7;

  /// Object entries in version <= 3 have a size of 9 bytes.
  static final int _OBJECTENTRY_SIZE = 9;

  /// Property defaults entries in versions <= 3 have a size of 31 words.
  static final int _PROPERTYDEFAULTS_SIZE = 31 * 2;

  ClassicObjectTree(Memory memory, int address) : super(memory, address);

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
  int getPropertyLength(final int propertyAddress) {
    return _getPropertyLengthAtData(getMemory(), propertyAddress);
  }

  @override
  int getChild(final int objectNum) {
    return getMemory()
        .readUnsigned8(getObjectAddress(objectNum) + _OFFSET_CHILD)
        .toInt();
  }

  @override
  void setChild(final int objectNum, final int child) {
    getMemory().writeUnsigned8(
        getObjectAddress(objectNum) + _OFFSET_CHILD, Char(child & 0xff));
  }

  @override
  int getParent(final int objectNum) {
    return getMemory()
        .readUnsigned8(getObjectAddress(objectNum) + _OFFSET_PARENT)
        .toInt();
  }

  @override
  void setParent(final int objectNum, final int parent) {
    getMemory().writeUnsigned8(
        getObjectAddress(objectNum) + _OFFSET_PARENT, Char(parent & 0xff));
  }

  @override
  int getSibling(final int objectNum) {
    return getMemory()
        .readUnsigned8(getObjectAddress(objectNum) + _OFFSET_SIBLING)
        .toInt();
  }

  @override
  void setSibling(final int objectNum, final int sibling) {
    getMemory().writeUnsigned8(
        getObjectAddress(objectNum) + _OFFSET_SIBLING, Char(sibling & 0xff));
  }

  @override
  int getPropertyTableAddress(final int objectNum) {
    return getMemory()
        .readUnsigned16(getObjectAddress(objectNum) + _OFFSET_PROPERTYTABLE)
        .toInt();
  }

  @override
  int getNumPropertySizeBytes(final int propertyDataAddress) {
    return 1;
  }

  @override
  int getNumPropSizeBytesAtData(int propertyDataAddress) {
    return 1;
  }

  @override
  int getPropertyNum(final int propertyAddress) {
    final int sizeByte = getMemory().readUnsigned8(propertyAddress).toInt();
    return sizeByte - 32 * (getPropertyLength(propertyAddress + 1) - 1);
  }

  /// This function represents the universal formula to calculate the length
  /// of a property given the address of its data (as opposed to the address
  /// of the property itself).
  static int _getPropertyLengthAtData(
      final Memory memaccess, final int addressOfPropertyData) {
    if (addressOfPropertyData == 0) {
      return 0; // see standard 1.1
    }

    // The size byte is always the byte before the property data in any
    // version, so this is consistent
    final Char sizebyte = memaccess.readUnsigned8(addressOfPropertyData - 1);

    return sizebyte.toInt() ~/ 32 + 1;
  }
}

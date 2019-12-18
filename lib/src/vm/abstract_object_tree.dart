import '../../zvm.dart';

/// This class is the super class of object trees.
abstract class AbstractObjectTree implements ObjectTree {
  Memory _memory;
  int _address;

  /// Constructs with the [memory] access object
  /// and the object table's start [address]
  AbstractObjectTree(final Memory memory, final int address) {
    _memory = memory;
    _address = address;
  }

  /// Returns the memory object.
  Memory getMemory() {
    return _memory;
  }

  /// Returns this tree's start address.
  int getAddress() {
    return _address;
  }

  /// Returns the address of the specified object.
  int getObjectAddress(int objectNum);

  @override
  void removeObject(final int objectNum) {
    int oldParent = getParent(objectNum);
    setParent(objectNum, 0);

    if (oldParent != 0) {
      if (getChild(oldParent) == objectNum) {
        setChild(oldParent, getSibling(objectNum));
      } else {
        // Find the child that comes directly before the removed
        // node and set the direct sibling of the removed node as
        // its new sibling
        int currentChild = getChild(oldParent);
        int sibling = getSibling(currentChild);

        // We have to handle the case that in fact that object is a child
        // of its parent, but not directly (happens for some reasons).
        // We stop in this case and simply remove the object from its
        // parent, probably the object tree modification routines should
        // be re-verified
        while (sibling != 0 && sibling != objectNum) {
          currentChild = sibling;
          sibling = getSibling(currentChild);
        }
        // sibling might be 0, in that case, the object is not
        // in the hierarchy
        if (sibling == objectNum) {
          setSibling(currentChild, getSibling(objectNum));
        }
      }
    }
    setSibling(objectNum, 0);
  }

  @override
  void insertObject(final int parentNum, final int objectNum) {
    // we want to ensure, the child has no old parent relationships
    if (getParent(objectNum) > 0) {
      removeObject(objectNum);
    }
    final int oldChild = getChild(parentNum);
    setParent(objectNum, parentNum);
    setChild(parentNum, objectNum);
    setSibling(objectNum, oldChild);
  }

  /// The size of the property defaults section.
  int getPropertyDefaultsSize();

  /// Returns the start address of the object tree section.
  int getObjectTreeStart() {
    return getAddress() + getPropertyDefaultsSize();
  }

  /// Returns the story file version specific object entry size.
  int getObjectEntrySize();

  @override
  bool isAttributeSet(int objectNum, int attributeNum) {
    final Char value = _memory
        .readUnsigned8(_getAttributeByteAddress(objectNum, attributeNum));
    return (value & (0x80 >> (attributeNum & 7))) > 0;
  }

  @override
  void setAttribute(int objectNum, int attributeNum) {
    final int attributeByteAddress =
        _getAttributeByteAddress(objectNum, attributeNum);
    int value = _memory.readUnsigned8(attributeByteAddress).toInt();
    value |= (0x80 >> (attributeNum & 7));
    _memory.writeUnsigned8(attributeByteAddress, Char(value));
  }

  @override
  void clearAttribute(int objectNum, int attributeNum) {
    final int attributeByteAddress =
        _getAttributeByteAddress(objectNum, attributeNum);
    int value = _memory.readUnsigned8(attributeByteAddress).toInt();
    value &= (~(0x80 >> (attributeNum & 7)));
    _memory.writeUnsigned8(attributeByteAddress, Char(value));
  }

  /// Returns the address of the byte specified object attribute lies in.
  int _getAttributeByteAddress(int objectNum, int attributeNum) {
    return getObjectAddress(objectNum) + attributeNum ~/ 8;
  }

  @override
  int getPropertiesDescriptionAddress(final int objectNum) {
    return getPropertyTableAddress(objectNum) + 1;
  }

  @override
  int getPropertyAddress(final int objectNum, final int property) {
    int propAddr = _getPropertyEntriesStart(objectNum);
    while (true) {
      int propnum = getPropertyNum(propAddr);
      if (propnum == 0) return 0; // not found
      if (propnum == property) {
        return propAddr + getNumPropertySizeBytes(propAddr);
      }
      int numPropBytes = getNumPropertySizeBytes(propAddr);
      propAddr += numPropBytes + getPropertyLength(propAddr + numPropBytes);
    }
  }

  @override
  int getNextProperty(final int objectNum, final int property) {
    if (property == 0) {
      final int addr = _getPropertyEntriesStart(objectNum);
      return getPropertyNum(addr);
    }
    int propDataAddr = getPropertyAddress(objectNum, property);
    if (propDataAddr == 0) {
      _reportPropertyNotAvailable(objectNum, property);
      return 0;
    } else {
      return getPropertyNum(propDataAddr + getPropertyLength(propDataAddr));
    }
  }

  /// Reports the non-availability of a property.
  void _reportPropertyNotAvailable(int objectNum, int property) {
    throw IllegalArgumentException(
        "Property ${property} " + "of object ${objectNum} is not available.");
  }

  @override
  Char getProperty(int objectNum, int property) {
    int propertyDataAddress = getPropertyAddress(objectNum, property);
    if (propertyDataAddress == 0) {
      return _getPropertyDefault(property);
    }
    final int numBytes = getPropertyLength(propertyDataAddress);
    int value;
    if (numBytes == 1) {
      value = _memory.readUnsigned8(propertyDataAddress) & 0xff;
    } else {
      final int byte1 = _memory.readUnsigned8(propertyDataAddress).toInt();
      final int byte2 = _memory.readUnsigned8(propertyDataAddress + 1).toInt();
      value = (byte1 << 8 | (byte2 & 0xff));
    }
    return Char(value & 0xffff);
  }

  @override
  void setProperty(int objectNum, int property, Char value) {
    int propertyDataAddress = getPropertyAddress(objectNum, property);
    if (propertyDataAddress == 0) {
      _reportPropertyNotAvailable(objectNum, property);
    } else {
      int propsize = getPropertyLength(propertyDataAddress);
      if (propsize == 1) {
        _memory.writeUnsigned8(propertyDataAddress, Char(value & 0xff));
      } else {
        _memory.writeUnsigned16(
            propertyDataAddress, toUnsigned16(value.toInt()));
      }
    }
  }

  /// Returns the property number at the specified table index.
  int getPropertyNum(int propertyAddress);

  /// Returns the address of an object's property table.
  int getPropertyTableAddress(int objectNum);

  /// Returns the number of property size bytes at the specified address.
  int getNumPropertySizeBytes(int propertyAddress);

  /// Returns the number of property size bytes at the specified property
  /// data address.
  int getNumPropSizeBytesAtData(int propertyDataAddress);

  /// Returns the start address of the actual property entries.
  int _getPropertyEntriesStart(int objectNum) {
    return getPropertyTableAddress(objectNum) +
        _getDescriptionHeaderSize(objectNum);
  }

  /// Returns the size of the description header in bytes that is,
  /// the size byte plus the description string size. This stays the same
  /// for all story file versions.
  int _getDescriptionHeaderSize(int objectNum) {
    final int startAddr = getPropertyTableAddress(objectNum);
    return _memory.readUnsigned8(startAddr).toInt() * 2 + 1;
  }

  /// Returns the property default value at the specified position in the
  /// property defaults table.
  Char _getPropertyDefault(final int propertyNum) {
    final int index = propertyNum - 1;
    return _memory.readUnsigned16(_address + index * 2);
  }
}

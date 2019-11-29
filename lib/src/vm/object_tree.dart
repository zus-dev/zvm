import '../../zvm.dart';

/// This is the interface definition of the object tree.
abstract class ObjectTree {
  /// Removes an object from its parent.
  void removeObject(int objectNum);

  /// Inserts an object to a new parent.
  void insertObject(int parentNum, int objectNum);

  /// Determines the length of the property at the specified address.
  /// The address is an address returned by ZObject.getPropertyAddress,
  /// i.e. it is starting after the length byte.
  int getPropertyLength(int propertyAddress);

  /// Tests if the specified attribute is set.
  bool isAttributeSet(int objectNum, int attributeNum);

  /// Sets the specified attribute.
  void setAttribute(int objectNum, int attributeNum);

  /// Clears the specified attribute.
  void clearAttribute(int objectNum, int attributeNum);

  /// Returns the number of this object's parent object.
  int getParent(int objectNum);

  /// Assigns a new parent object.
  void setParent(int objectNum, int parent);

  /// Returns the object number of this object's sibling object.
  int getSibling(int objectNum);

  /// Assigns a new sibling to this object.
  void setSibling(int objectNum, int sibling);

  /// Returns the object number of this object's child object.
  int getChild(int objectNum);

  /// Assigns a new child to this object.
  void setChild(int objectNum, int child);

  /// Returns the properties description address.
  int getPropertiesDescriptionAddress(int objectNum);

  /// Returns the address of the specified property. Note that this will not
  /// include the length byte.
  int getPropertyAddress(int objectNum, int property);

  /// Returns the next property in the list. If property is 0, this
  /// will return the first property number, if property is the last
  /// element in the list, it will return 0.
  int getNextProperty(int objectNum, int property);

  /// Returns the the specified property.
  Char getProperty(int objectNum, int property);

  /// Sets the specified property byte to the given value.
  void setProperty(int objectNum, int property, Char value);
}

import '../../zvm.dart';

/// The available operand types.
enum OperandType { SMALL_CONSTANT, LARGE_CONSTANT, VARIABLE, OMITTED }

/// This is the definition of an instruction's operand. Each operand has
/// an operand type, and a value which is to be interpreted according to
/// the type.
class Operand {
  /// Type number for a large constant.
  static final int TYPENUM_LARGE_CONSTANT = 0x00;

  /// Type number for a small constant.
  static final int TYPENUM_SMALL_CONSTANT = 0x01;

  /// Type number for a variable.
  static final int TYPENUM_VARIABLE = 0x02;

  /// Type number for omitted.
  static final int TYPENUM_OMITTED = 0x03;

  OperandType _type;
  Char _value;

  Operand(int typenum, Char value) {
    _type = _getOperandType(typenum);
    _value = value;
  }

  /// Determines the operand type from a two-bit value.
  static OperandType _getOperandType(final int typenum) {
    switch (typenum) {
      case 0x00:
        return OperandType.LARGE_CONSTANT;
      case 0x01:
        return OperandType.SMALL_CONSTANT;
      case 0x02:
        return OperandType.VARIABLE;
      default:
        // In fact, such a value should never exist..
        return OperandType.OMITTED;
    }
  }

  /// Returns this operand's type.
  OperandType getType() {
    return _type;
  }

  /// The operand value.
  Char getValue() {
    return _value;
  }
}

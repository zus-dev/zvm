import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  test('CreateOperand', () {
    Operand operand1 = Operand(Operand.TYPENUM_SMALL_CONSTANT, Char(5));
    Operand operand2 = Operand(Operand.TYPENUM_LARGE_CONSTANT, Char(6));
    Operand operand3 = Operand(Operand.TYPENUM_VARIABLE, Char(11));
    Operand operand4 = Operand(Operand.TYPENUM_OMITTED, Char(13));

    assertEquals(5, operand1.getValue());
    assertEquals(6, operand2.getValue());
    assertEquals(11, operand3.getValue());
    assertEquals(13, operand4.getValue());

    assertEquals(operand1.getType(), OperandType.SMALL_CONSTANT);
    assertEquals(operand2.getType(), OperandType.LARGE_CONSTANT);
    assertEquals(operand3.getType(), OperandType.VARIABLE);
    assertEquals(operand4.getType(), OperandType.OMITTED);
  });
}

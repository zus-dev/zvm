import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  InstructionInfoDb infoDb = InstructionInfoDb.getInstance();

  test('Invalid', () {
    assertFalse(
        infoDb.isValid(OperandCount.C0OP, Instruction.C0OP_SHOW_STATUS, 4));
  });
}

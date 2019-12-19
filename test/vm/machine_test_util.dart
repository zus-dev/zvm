import 'package:zvm/zvm.dart';

import '../helpers.dart';

/// Test utility class for virtual machine package.
class MachineTestUtil {
  static MachineImpl createMachine(String fileName) {
    MachineImpl machine = MachineImpl();
    machine.initialize(readTestFileAsByteArray(fileName), null);
    return machine;
  }
}

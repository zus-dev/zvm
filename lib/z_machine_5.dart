import 'dart:typed_data';

import 'package:zvm/z_machine.dart';
import 'package:zvm/z_screen.dart';
import 'package:zvm/z_status.dart';

class ZMachine5 extends ZMachine {
  int argcount = 0;

  ZMachine5(ZScreen screen, ZStatus status_line, Uint8List memory_image)
      : super(screen, status_line, memory_image) {
    // TODO: Implement me
  }
}

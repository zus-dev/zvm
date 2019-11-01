import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io';

import 'package:zvm/z_window.dart';
import 'package:zvm/z_header.dart';
import 'package:zvm/z_screen.dart';
import 'package:zvm/z_object_tree.dart';
import 'package:zvm/z_dictionary.dart';
import 'package:zvm/z_state.dart';
import 'package:zvm/z_status.dart';
import 'package:zvm/stack.dart';
import 'package:zvm/random.dart';
import 'package:zvm/z_instruction.dart';

abstract class ZMachine {
  static const int STATE_INIT = 0;
  static const int STATE_RUNNING = 1;
  static const int STATE_WAIT_CMD = 2;
  static const int STATE_WAIT_CHAR = 3;

  ZWindow current_window;
  int pc = 0;
  List<ZWindow> window = [];
  ZHeader header;
  ZScreen screen;
  ZObjectTree objects;
  ZDictionary zd;
  ZState restart_state;
  ZStatus status_line;
  Uint8List memory_image;
  Stack zstack;
  Random zrandom;
  int globals = 0;
  Uint16List locals;
  int inputstream = 0;
  List<bool> outputs;
  int printmemory = 0;
  int alphabet = 0;
  int build_ascii = 0;
  int built_ascii = 0;
  int abbrev_mode = 0;
  int checksum = 0;
  ZInstruction zi;
  bool status_redirect = false;
  String status_location;
  final String A2 = "0123456789.,!?_#\'\"/\\-:()";

  static final int OP_LARGE = 0;
  static final int OP_SMALL = 1;
  static final int OP_VARIABLE = 2;
  static final int OP_OMITTED = 3;

  int runState = STATE_INIT;

  List<String> inputBuffer; // char[]
  int inputIndex = 0;

  bool saveCalled = false;
  bool restoreCalled = false;

  // Where the save/restore opcode saveto /restore from.
  File quickSaveSlot;

  ZMachine(ZScreen screen, ZStatus status_line, Uint8List memory_image) {
    this.screen = screen;
    this.status_line = status_line;
    this.memory_image = memory_image;
    locals = Uint16List(0);
    zstack = Stack();
    restart_state = ZState(this);
    restart_state.save_current();
    zrandom = Random(); /* starts in "random" mode */
    inputstream = 0;
    outputs = List<bool>.filled(5, false);
    outputs[1] = true;
    alphabet = 0;
  }
}

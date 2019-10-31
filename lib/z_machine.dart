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
  int pc;
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
  int globals;
  List<int> locals;
  int inputstream;
  List<bool> outputs;
  int printmemory;
  int alphabet;
  int build_ascii;
  int built_ascii;
  int abbrev_mode;
  int checksum;
  ZInstruction zi;
  bool status_redirect;
  String status_location;
  final String A2 = "0123456789.,!?_#\'\"/\\-:()";

  static final int OP_LARGE = 0;
  static final int OP_SMALL = 1;
  static final int OP_VARIABLE = 2;
  static final int OP_OMITTED = 3;

  int runState = STATE_INIT;

  List<String> inputBuffer; // char[]
  int inputIndex;

  bool saveCalled;
  bool restoreCalled;

  // Where the save/restore opcode saveto /restore from.
  File quickSaveSlot;

  ZMachine(ZScreen screen, ZStatus status_line, Uint8List memory_image) {
    this.screen = screen;
    this.status_line = status_line;
    this.memory_image = memory_image;
    locals = List<int>();
    zstack = Stack();
    restart_state = ZState(this);
    restart_state.save_current();
  }
}

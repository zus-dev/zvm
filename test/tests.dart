import "dart:io";
import 'dart:typed_data';

import "package:test/test.dart";
import 'package:zvm/z_machine.dart';
import "package:zvm/z_screen.dart";
import 'package:zvm/z_header_3.dart';
import 'package:zvm/z_header_5.dart';

import 'package:zvm/z_status.dart';
import 'package:zvm/stack.dart';

void main() {
  final s = Platform.pathSeparator;
  Uint8List minizork_z3 = null;
  Uint8List etude_z5 = null;
  Uint8List tester_z8 = null;

  try {
    minizork_z3 = File('test${s}res${s}minizork.z3').readAsBytesSync();
    etude_z5 = File('test${s}res${s}etude.z5').readAsBytesSync();
    tester_z8 = File('test${s}res${s}Tester.z8').readAsBytesSync();
  } on Exception catch (fe) {
    print('$fe');
    exit(1);
  }

  test("ZHeader3-minizork", () {
    var header = ZHeader3(minizork_z3);
    // Members of the base class.
    expect(header.version(), equals(3));
    expect(header.initial_pc(), equals(14297));
    expect(header.dictionary(), equals(10330));
    expect(header.object_table(), equals(966));
    expect(header.global_table(), equals(692));
    expect(header.static_base(), equals(8583));
    expect(header.transcripting(), equals(false));
    expect(header.abbrev_table(), equals(500));
    expect(header.force_fixed(), equals(false));
    expect(header.release(), equals(34));
    expect(header.checksum(), equals(55408));
    // Members of the ZHeader3
    expect(header.time_game(), equals(false));
    expect(header.file_length(), equals(52216));
  });

  test("ZHeader5-etude", () {
    var header = ZHeader5(etude_z5);
    // Members of the base class.
    expect(header.version(), equals(5));
    expect(header.initial_pc(), equals(1525));
    expect(header.dictionary(), equals(1516));
    expect(header.object_table(), equals(258));
    expect(header.global_table(), equals(736));
    expect(header.static_base(), equals(1514));
    expect(header.transcripting(), equals(false));
    expect(header.abbrev_table(), equals(66));
    expect(header.force_fixed(), equals(false));
    expect(header.release(), equals(2));
    expect(header.checksum(), equals(46621));
    // Members of the ZHeader3
    expect(header.file_length(), equals(16508));
    expect(header.graphics_font_wanted(), equals(false));
    expect(header.undo_wanted(), equals(true));
    expect(header.mouse_wanted(), equals(false));
    expect(header.colors_wanted(), equals(true));
    expect(header.sound_wanted(), equals(false));
    expect(header.default_background_color(), equals(0));
    expect(header.default_foreground_color(), equals(0));
  });

  test("ZHeader5-tester", () {
    var header = ZHeader5(tester_z8);
    // Members of the base class.
    expect(header.version(), equals(8));
    expect(header.initial_pc(), equals(23193));
    expect(header.dictionary(), equals(20058));
    expect(header.object_table(), equals(266));
    expect(header.global_table(), equals(6905));
    expect(header.static_base(), equals(18526));
    expect(header.transcripting(), equals(false));
    expect(header.abbrev_table(), equals(66));
    expect(header.force_fixed(), equals(false));
    expect(header.release(), equals(1));
    expect(header.checksum(), equals(33307));
    // Members of the ZHeader3
    expect(header.file_length(), equals(83644));
    expect(header.graphics_font_wanted(), equals(false));
    expect(header.undo_wanted(), equals(true));
    expect(header.mouse_wanted(), equals(false));
    expect(header.colors_wanted(), equals(true));
    expect(header.sound_wanted(), equals(false));
    expect(header.default_background_color(), equals(0));
    expect(header.default_foreground_color(), equals(0));
  });

  test("unicode_to_zascii", () {
    expect(ZScreen.unicode_to_zascii('L'), equals(76));
    expect(ZScreen.unicode_to_zascii('o'), equals(111));
    expect(ZScreen.unicode_to_zascii('k'), equals(107));
    expect(ZScreen.unicode_to_zascii('\n'), equals(13));
    expect(ZScreen.unicode_to_zascii('\b'), equals(127));
    expect(ZScreen.unicode_to_zascii('\t'), equals(9));
    expect(ZScreen.unicode_to_zascii('\u00e4'), equals(155));
    expect(ZScreen.unicode_to_zascii('\u00fc'), equals(157));
    expect(ZScreen.unicode_to_zascii('\u00bf'), equals(223));
    expect(ZScreen.unicode_to_zascii('\u001b'), equals(27));
  });

  test("zascii_to_unicode", () {
    expect(ZScreen.zascii_to_unicode(76), equals('L'));
    expect(ZScreen.zascii_to_unicode(111), equals('o'));
    expect(ZScreen.zascii_to_unicode(107), equals('k'));
    expect(ZScreen.zascii_to_unicode(13), equals('\n'));
    expect(ZScreen.zascii_to_unicode(127), equals('\b'));
    expect(ZScreen.zascii_to_unicode(9), equals('\t'));
    expect(ZScreen.zascii_to_unicode(155), equals('\u00e4'));
    expect(ZScreen.zascii_to_unicode(157), equals('\u00fc'));
    expect(ZScreen.zascii_to_unicode(223), equals('\u00bf'));
    expect(ZScreen.zascii_to_unicode(27), equals('\u001b'));
  });

  test("ZStatus", () {
    var status = ZStatus();
    status.timegame = false;
    status.location = "Up in the clouds";
    status.score = 1;
    status.turns = 2;
    status.hours = 3;
    status.minutes = 4;
    expect(status.toString(),
        equals("Up in the clouds                Score: 1 Turn: 2"));
    status.timegame = true;
    expect(status.toString(), equals("Up in the clouds                03:4"));
  });

  test("Stack", () {
    var stack = Stack();
    stack.push(1);
    stack.push(2);
    expect(stack.pop(), equals(2));
    stack.push(3);
    var copy = stack.clone();
    expect(stack.pop(), equals(3));
    expect(stack.pop(), equals(1));
    copy.push(4);
    expect(copy.pop(), equals(4));
    expect(copy.pop(), equals(3));
    expect(copy.pop(), equals(1));
  });

  test("ZMachine", () {
    var screen = ZScreen();
    var status = ZStatus();
    var zm = TestZMachine(screen, status, minizork_z3);
    expect(zm.pc, equals(0));
  });
}

class TestZMachine extends ZMachine {
  TestZMachine(ZScreen screen, ZStatus status_line, Uint8List memory_image)
      : super(screen, status_line, memory_image);
}

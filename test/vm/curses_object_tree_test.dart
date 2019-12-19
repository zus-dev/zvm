import 'package:test/test.dart';
import 'package:zvm/zvm.dart';
import 'curses_setup.dart';

import '../helpers.dart';

void main() {
  final cs = CursesSetup();
  Memory curses;
  Machine machine;

  final int ADDR_7_20 	= 7734;
	final int ADDR_7_1 	= 7741;
	ObjectTree objectTree;

  setUp(() {
    cs.setUp();
    curses = cs.curses;
    machine = cs.machine;

	  objectTree = ModernObjectTree(curses, machine.readUnsigned16(StoryFileHeader.OBJECT_TABLE).toInt());
  });


  test('GetPropertiesDescriptionAddress', () {
	  assertEquals(0x2d40, objectTree.getPropertiesDescriptionAddress(123));
  });

  test('GetPropertyAddress', () {
  	assertEquals(ADDR_7_20, objectTree.getPropertyAddress(7, 20));
  	assertEquals(ADDR_7_1, objectTree.getPropertyAddress(7, 1));
  });

  test('GetProperty', () {
	  assertEquals(0, objectTree.getProperty(3, 22));
	  assertEquals(0x0006, objectTree.getProperty(3, 8));
	  assertEquals(0xb685, objectTree.getProperty(2, 20));
  });

  test('SetGetProperty', () {
	  objectTree.setProperty(122, 34, Char(0xdefe));
	  assertEquals(0xdefe, objectTree.getProperty(122, 34));
  });

  test('GetNextProperty', () {
  	assertEquals(24, objectTree.getNextProperty(7, 0));
  	assertEquals(20, objectTree.getNextProperty(7, 24));
  	assertEquals(8, objectTree.getNextProperty(7, 20));
  	assertEquals(1, objectTree.getNextProperty(7, 8));
  	assertEquals(0, objectTree.getNextProperty(7, 1));
  });

  test('GetPropertyLength', () {
	  assertEquals(2, objectTree.getPropertyLength(ADDR_7_20));
	  assertEquals(6, objectTree.getPropertyLength(ADDR_7_1));
  });

  test('GetPropertyLengthAddress0', () {
	  assertEquals(0, objectTree.getPropertyLength(0));
  });
}

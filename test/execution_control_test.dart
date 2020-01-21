import "dart:io";

import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import 'helpers.dart';
import 'views/file_save_game_data_store.dart';
import 'views/memory_save_game_data_store.dart';
import 'views/screen_model_split_view.dart';
import 'views/text_grid_view.dart';

bool _enablePrintObjProps = false;

class TestImageFactory extends NativeImageFactory {
  @override
  NativeImage createImage(BytesInputStream inputStream) {
    // TODO: implement createImage
    return null;
  }
}

class TestIOSystem extends IOSystem {
  @override
  Reader getInputStreamReader() {
    // TODO: implement getInputStreamReader
    return null;
  }

  @override
  Writer getTranscriptWriter() {
    // TODO: implement getTranscriptWriter
    return null;
  }
}

class TestStatusLineListener extends StatusLineListener {
  String objectDescription;
  String status;

  @override
  void statusLineUpdated(String objectDescription, String status) {
    print("STATUS-LINE: $objectDescription :: $status");
    this.objectDescription = objectDescription;
    this.status = status;
  }
}

class TestScreenModelListener extends ScreenModelListener
    implements ScreenModelSplitView {
  TextGridView upper;
  StringBuffer lower = StringBuffer();
  BufferedScreenModel _screenModel;

  TestScreenModelListener(BufferedScreenModel bufferedScreenModel) {
    _screenModel = bufferedScreenModel;
    upper = TextGridView(this);
  }

  @override
  void screenModelUpdated(ScreenModel screenModel) {
    if (screenModel is BufferedScreenModel) {
      print("SCREEN-BEGIN");
      final upperLines = upper.toString().split('\n');
      for (int i = 0; i < upperLines.length; i++) {
        final line = upperLines[i];
        if (line.trim() != '') {
          print(line.trim());
        }
      }

      lower.clear();
      List<AnnotatedText> text = screenModel.getLowerBuffer();
      for (AnnotatedText segment in text) {
        lower.write(segment.getText());
      }
      // flush and set styles
      /// lower.setCurrentStyle(screenModel.getBottomAnnotation());
      /// TODO: Distinguish C1OpInstruction._print_obj and make annotations for
      /// a "room" and an "object"
      /// e.g. encrusted/src/rust/ui_web.rs fn flush

      // NOTE: for the buffered output we might want not to output immediately
      // for the example see curses.z5
      // INFO: org.zmpp.screen: SET_BUFFER_MODE:

      print('SCREEN-LOWER');
      for (final line in lower.toString().trim().split('\n')) {
        if (line.trim() != '') {
          print(line.trim());
        }
      }
      print('SCREEN-END');
      //upper.setCurrentStyle(screenModel.getBottomAnnotation());
    }
  }

  @override
  void screenSplit(int linesUpperWindow) {
    print('SCREEN-SPLIT: $linesUpperWindow');
    // TODO: clear only in v3
    // upper.clear(ScreenModel.COLOR_DEFAULT);
  }

  @override
  void topWindowCursorMoving(int line, int column) {
    // print('TOP-WIN-MOVE: $line $column');
    // TODO: implement topWindowCursorMoving
  }

  @override
  void topWindowUpdated(int cursorx, int cursory, AnnotatedCharacter c) {
    // print('TOP-WIN: $cursorx $cursory "${c.getCharacter().toString()}" [${c.getCharacter().toInt().toString()}]');
    upper.setCharacter(cursory, cursorx, c);
  }

  @override
  void windowErased(int window) {
    if (window == -1) {
      clearAll();
    } else if (window == ScreenModel.WINDOW_BOTTOM) {
      lower.clear();
    } else if (window == ScreenModel.WINDOW_TOP) {
      clearUpper();
    } else {
      throw UnsupportedOperationException("No support for erasing window: $window");
    }
  }

  @override
  BufferedScreenModel getScreenModel() {
    return _screenModel;
  }

  void clearAll() {
    lower.clear();
    clearUpper();
  }

  void clearUpper() {
    upper.clear(ScreenModel.COLOR_DEFAULT);
  }
}

void main() {
  MachineInitStruct initStruct;
  BufferedScreenModel screenModel;
  TestScreenModelListener screenModelListener;
  TestStatusLineListener statusLineListener;

  setUp(() {
    screenModel = BufferedScreenModel();
    screenModelListener = TestScreenModelListener(screenModel);
    statusLineListener = TestStatusLineListener();

    screenModel.addScreenModelListener(screenModelListener);
    screenModel.addStatusLineListener(statusLineListener);

    initStruct = MachineInitStruct();
    initStruct.nativeImageFactory = TestImageFactory();
    initStruct.ioSystem = TestIOSystem();
    initStruct.screenModel = screenModel;
    initStruct.statusLine = screenModel;
    // initStruct.saveGameDataStore = MemorySaveGameDataStore();

    final fsDataStore =  FileSaveGameDataStore();
    fsDataStore.saveFile = "./testfiles/test_save_file.data";
    initStruct.saveGameDataStore = fsDataStore;
  });

  tearDown(() {
    final saveFile = File("./testfiles/test_save_file.data");
    if (saveFile.existsSync()) {
      saveFile.deleteSync();
    }
  });

  test('Minizork Execution Control', () {
    initStruct.storyFile = FileBytesInputStream(getTestFilePath("minizork.z3"));
    final executionControl = ExecutionControl(initStruct);
    // initUI(initStruct);
    screenModel.init(
      executionControl.getMachine(),
      executionControl.getZsciiEncoding(),
    );

    // notifyGameInitialized();
    MachineRunState runState = executionControl.run();
    expect(runState.getTime().toInt(), equals(0));
    expect(runState.getRoutine().toInt(), equals(0));
    expect(screenModelListener.lower.toString(),
        startsWith("MINI-ZORK I: The Great Underground Empire"));
    expect(screenModelListener.lower.toString(), contains("West of House"));
    expect(statusLineListener.objectDescription, equals("West of House"));
    expect(statusLineListener.status, equals("0/0"));

    executionControl.resumeWithInput("save");
    executionControl.resumeWithInput("n");
    expect(statusLineListener.objectDescription, equals("North of House"));
    expect(statusLineListener.status, equals("0/1"));

    executionControl.resumeWithInput("restore");
    expect(statusLineListener.objectDescription, equals("West of House"));
    expect(statusLineListener.status, equals("0/0"));

    runState = executionControl.resumeWithInput("n");
    expect(runState.getTime().toInt(), equals(0));
    expect(runState.getRoutine().toInt(), equals(0));

    _enablePrintObjProps = true;
    printObjectTree(executionControl.getMachine());
    // mainView.setCurrentRunState(runState);
  });

  test('Curses Execution Control', () {
    initStruct.storyFile = FileBytesInputStream(getTestFilePath("curses.z5"));
    final executionControl = ExecutionControl(initStruct);
    // initUI
    // resizeScreen
    final numRows = 32;
    final numCharsPerRow = 80; // TODO: probably less?
    executionControl.resizeScreen(numRows, numCharsPerRow);
    screenModel.setNumCharsPerRow(numCharsPerRow);
    screenModelListener.upper.setGridSize(numRows, numCharsPerRow);

    screenModel.init(
      executionControl.getMachine(),
      executionControl.getZsciiEncoding(),
    );

    MachineRunState runState = executionControl.run();
    expect(runState.getTime().toInt(), equals(0));
    expect(runState.getRoutine().toInt(), equals(0));
    expect(screenModelListener.lower.toString(), contains("Welcome to CURSES"));

    executionControl.resumeWithInput(" ");
    expect(screenModelListener.lower.toString(), contains("Attic"));
    expect(screenModelListener.lower.toString(),
        contains("The attics, full of low beams and awkward angles"));
    expect(screenModelListener.upper.toString(), contains("Attic                                      Score: 0"));

    executionControl.resumeWithInput("save");

    executionControl.resumeWithInput("n");
    expect(screenModelListener.lower.toString(), contains("Old Winery"));
    expect(screenModelListener.lower.toString(),
        contains("This small cavity at the north end of the attic once"));
    expect(screenModelListener.upper.toString(), contains("Old Winery                                 Score: 0"));

    _enablePrintObjProps = false;
    // printObjectTree(executionControl.getMachine());
  });

  test('AdvR Execution Control', () {
    initStruct.storyFile = FileBytesInputStream(getTestFilePath("AdventureR.z5"));
    final executionControl = ExecutionControl(initStruct);
    // initUI
    // resizeScreen
    final numRows = 32;
    final numCharsPerRow = 80; // TODO: probably less?
    executionControl.resizeScreen(numRows, numCharsPerRow);
    screenModel.setNumCharsPerRow(numCharsPerRow);
    screenModelListener.upper.setGridSize(numRows, numCharsPerRow);

    screenModel.init(
      executionControl.getMachine(),
      executionControl.getZsciiEncoding(),
    );

    MachineRunState runState = executionControl.run();
    expect(runState.getTime().toInt(), equals(0));
    expect(runState.getRoutine().toInt(), equals(0));

    executionControl.resumeWithInput("save");
    executionControl.resumeWithInput("n");

    _enablePrintObjProps = false;
    printObjectTree(executionControl.getMachine());
  });
}

void printObjectTree(Machine machine) {
  Memory minizorkmap = machine;
  ObjectTree objectTree = machine;

  // let prop_defaults = memory.read_word(0x0A)
  final prop_defaults = minizorkmap.readUnsigned16(0x0A).toInt();
  // obj_table_addr: prop_defaults + (if version <= 3 { 31 } else { 63 }) * 2,
  final obj_table_addr = prop_defaults + 31 * 2;

  // final attr_width = attr_width: if version <= 3 { 4 } else { 6 };
  final attr_width = 4;
  // by convention, the property table for object #1 is located AFTER
  // the last object in the object table:
  int obj_table_end = objectTree.getPropertiesDescriptionAddress(1);
  // let obj_size = self.attr_width + if self.version <= 3 { 3 } else { 9 } + 2;
  int obj_size = attr_width + 3 + 2;

  // v1-3 have a max of 255 objects, v4+ can have up to 65535
  var get_total_object_count = (obj_table_end - obj_table_addr) ~/ obj_size;
  print("OBJ COUNT: ${get_total_object_count}");

  var objMap = Map<int, String>();

  int yourself_object = 0;

  for (int i = 1; i < get_total_object_count; i++) {
    int propaddress = objectTree.getPropertiesDescriptionAddress(i);
    int text_length = minizorkmap.readUnsigned8(propaddress).toInt();
    if (machine.getVersion() <= 3) {
      // getPropertyTableAddress(machine, i) + 1 ?
      text_length = minizorkmap
          .readUnsigned8(getPropertyTableAddress(machine, i))
          .toInt();
    }

    String objectName = "(No Name)";
    if (text_length > 0) {
      objectName = readUnicodeString(machine, propaddress, 0);
    }

    if (objectName == "cretin" ||
        objectName == "you" ||
        objectName == "yourself") {
      yourself_object = i;
    }

    // int parent = objectTree.getParent(i);
    // print("${i} => ${parent}: '${objectName}'");
    objMap[i] = "${i}: ${objectName}";
  }

  print("LOCATION:");
  int yourself_parent = yourself_object;
  while (yourself_parent != 0) {
    print("${objMap[yourself_parent]}");
    yourself_parent = objectTree.getParent(yourself_parent);
  }
  print("OBJECT TREE: ");

  printObjMap(objMap, 0, objectTree, "");
}

void printObjMap(
    Map<int, String> objMap, int parent, ObjectTree objectTree, String prefix) {
  for (var objectNum in objMap.keys) {
    if (objectTree.getParent(objectNum) == parent) {
      print(prefix + objMap[objectNum]);
      if (_enablePrintObjProps) {
        printObjProps(objectNum, prefix + "\t", objectTree);
      }
      printObjMap(objMap, objectNum, objectTree, prefix + "\t");
    }
  }
}

void printObjProps(int objectNum, String prefix, ObjectTree objectTree) {
  var property = 0;
  do {
    if (objectTree is Machine) {
      print(
          "${prefix} |- ${property} [${objectTree.getProperty(objectNum, property).toInt()}] ${objectTree.getPropertyAddress(objectNum, property)}");
    }
    property = objectTree.getNextProperty(objectNum, property);
  } while (property != 0);

  String attributes = "";
  for (int i = 0; i < 31; i++) {
    if (objectTree.isAttributeSet(objectNum, i)) {
      attributes += " ${i}";
    }
  }
  print("${prefix} |- attributes:${attributes}");
}

int getPropertyTableAddress(final Machine memory, final int objectNum) {
  final _OFFSET_PROPERTYTABLE = 7;
  final objectTreeStart = 1028;
  final objectEntrySize = 9;
  final objectAddress = objectTreeStart + (objectNum - 1) * objectEntrySize;
  return memory.readUnsigned16(objectAddress + _OFFSET_PROPERTYTABLE).toInt();
}

String readUnicodeString(Machine machine, int address, int length) {
  final String zsciiString = machine.decode2Zscii(address, 0);
  StringBuffer sb = StringBuffer();
  for (int i = 0, n = zsciiString.length; i < n; i++) {
    sb.write(machine.getUnicodeChar(Char.at(zsciiString, i)).toString());
  }
  return sb.toString();
}

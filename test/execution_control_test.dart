import "dart:io";

import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import 'helpers.dart';

class FileBytesInputStream extends BytesInputStream {
  String fileName;

  FileBytesInputStream(this.fileName);

  @override
  ByteArray readAsBytesSync() {
    final file = File(fileName);
    return ByteArray(file.readAsBytesSync());
  }

  @override
  void mark(int readLimit) {
    // TODO: implement mark
  }

  @override
  int read() {
    // TODO: implement read
    return null;
  }

  @override
  void reset() {
    // TODO: implement reset
  }
}

class TestImageFactory extends NativeImageFactory {
  @override
  NativeImage createImage(BytesInputStream inputStream) {
    // TODO: implement createImage
    return null;
  }
}

/// This class saves save games as a memory object.
class MemorySaveGameDataStore implements SaveGameDataStore {
  WritableFormChunk _savegame;

  @override
  bool saveFormChunk(WritableFormChunk formchunk) {
    _savegame = formchunk;
    return true;
  }

  @override
  FormChunk retrieveFormChunk() {
    return _savegame;
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
  @override
  void statusLineUpdated(String objectDescription, String status) {
    print("STATUS-LINE: $objectDescription :: $status");
    // TODO: implement statusLineUpdated
  }

}

class TestScreenModelListener extends ScreenModelListener {
  @override
  void screenModelUpdated(ScreenModel screenModel) {
    StringBuffer lower = StringBuffer();
    if (screenModel is BufferedScreenModel) {
      List<AnnotatedText> text = screenModel.getLowerBuffer();
      for (AnnotatedText segment in text) {
        lower.write(segment.getText());
      }
      // flush and set styles
      /// lower.setCurrentStyle(screenModel.getBottomAnnotation());
      /// TODO: Distinguish C1OpInstruction._print_obj and make annotations for
      /// a "room" and an "object"
      /// e.g. encrusted/src/rust/ui_web.rs fn flush
      print(lower.toString());
      //upper.setCurrentStyle(screenModel.getBottomAnnotation());
    }
  }

  @override
  void screenSplit(int linesUpperWindow) {
    // TODO: implement screenSplit
  }

  @override
  void topWindowCursorMoving(int line, int column) {
    // TODO: implement topWindowCursorMoving
  }

  @override
  void topWindowUpdated(int cursorx, int cursory, AnnotatedCharacter c) {
    print('TOP-WIN: $cursorx $cursory ${c.getCharacter().toString()}');
    // TODO: implement topWindowUpdated
  }

  @override
  void windowErased(int window) {
    // TODO: implement windowErased
  }
}

void main() {
  BufferedScreenModel screenModel = BufferedScreenModel();
  final screenModelListener = TestScreenModelListener();
  final statusLineListener = TestStatusLineListener();
  screenModel.addScreenModelListener(screenModelListener);
  screenModel.addStatusLineListener(statusLineListener);

  final initStruct = MachineInitStruct();
  initStruct.storyFile = FileBytesInputStream(getTestFilePath("minizork.z3"));
  initStruct.nativeImageFactory = TestImageFactory();
  initStruct.saveGameDataStore = MemorySaveGameDataStore();
  initStruct.ioSystem = TestIOSystem();
  initStruct.screenModel = screenModel;
  initStruct.statusLine = screenModel;

  test('Start', () {
    final executionControl = ExecutionControl(initStruct);
    // initUI(initStruct);
    {
      screenModel.init(
        executionControl.getMachine(),
        executionControl.getZsciiEncoding(),
      );
    }

    // notifyGameInitialized();
    MachineRunState runState = executionControl.run();
    print("PAUSING WITH STATE: " + runState.toString());

    executionControl.resumeWithInput("save");
    executionControl.resumeWithInput("restore");

    printObjectTree(executionControl.getMachine());

    executionControl.resumeWithInput("n");
    print("PAUSING WITH STATE: " + runState.toString());
    // mainView.setCurrentRunState(runState);

    // printObjectTree(executionControl.getMachine());

    expect(true, equals(true));
  });
}

void printObjectTree(Machine machine) {
  Memory minizorkmap = machine;
  ObjectTree objectTree = machine;

  var abbreviations = Abbreviations(minizorkmap,
      machine.readUnsigned16(StoryFileHeader.ABBREVIATIONS).toInt());
  ZsciiEncoding encoding = ZsciiEncoding(DefaultAccentTable());
  AlphabetTable alphabetTable = DefaultAlphabetTable();
  ZCharTranslator translator = DefaultZCharTranslator(alphabetTable);
  var converter = DefaultZCharDecoder(encoding, translator, abbreviations);

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
      objectName =
          converter.decode2Zscii(minizorkmap, propaddress, 0).toString();
    }

    if (objectName == "cretin" ||
        objectName == "you" ||
        objectName == "yourself") {
      yourself_object = i;
    }

    int parent = objectTree.getParent(i);
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
      printObjProps(objectNum, prefix + "\t", objectTree);
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

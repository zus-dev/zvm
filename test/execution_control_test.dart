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

class TestSaveGameDataStore extends SaveGameDataStore {
  @override
  FormChunk retrieveFormChunk() {
    // TODO: implement retrieveFormChunk
    return null;
  }

  @override
  bool saveFormChunk(WritableFormChunk formchunk) {
    // TODO: implement saveFormChunk
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

class TestScreenModelListener extends ScreenModelListener  {
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
  screenModel.addScreenModelListener(screenModelListener);

  final initStruct = MachineInitStruct();
  initStruct.storyFile = FileBytesInputStream(getTestFilePath("minizork.z3"));
  initStruct.nativeImageFactory = TestImageFactory();
  initStruct.saveGameDataStore = TestSaveGameDataStore();
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
    executionControl.resumeWithInput("n");
    print("PAUSING WITH STATE: " + runState.toString());
    // mainView.setCurrentRunState(runState);

    expect(true, equals(true));
  });
}

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

void main() {
  BufferedScreenModel screenModel = BufferedScreenModel();

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
    // notifyGameInitialized();
    MachineRunState runState = executionControl.run();
    print("PAUSING WITH STATE: " + runState.toString());
    // mainView.setCurrentRunState(runState);

    expect(true, equals(true));
  });
}

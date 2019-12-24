import '../../zvm.dart';

/// Initialization structure.
class MachineInitStruct {
  JavaInputStream storyFile, blorbFile;
  URL storyURL, blorbURL;
  InputStream keyboardInputStream;
  StatusLine statusLine;
  ScreenModel screenModel;
  IOSystem ioSystem;
  SaveGameDataStore saveGameDataStore;
  NativeImageFactory nativeImageFactory;
  SoundEffectFactory soundEffectFactory;
}

/// Constructing a Machine object is a very complex task, the building process
/// deals with creating the game objects, the UI and the I/O system.
/// Initialization was changed so it is not necessary to create a subclass
/// of MachineFactory. Instead, an init struct and a init callback object
/// should be provided.
class MachineFactory {
  MachineInitStruct _initStruct;
  FormChunk _blorbchunk;

  MachineFactory(MachineInitStruct initStruct) {
    _initStruct = initStruct;
  }

  /// This is the main creation function.
  Machine buildMachine() {
    final MachineImpl machine = MachineImpl();
    machine.initialize(_readStoryData(), readResources());
    if (isInvalidStory(machine.getVersion())) {
      throw InvalidStoryException();
    }
    _initIOSystem(machine);
    return machine;
  }

  /// Reads the story data.
  ByteArray _readStoryData() {
    if (_initStruct.storyFile != null || _initStruct.blorbFile != null) {
      return readStoryDataFromFile();
    }
    if (_initStruct.storyURL != null || _initStruct.blorbURL != null) {
      return readStoryDataFromUrl();
    }
    return null;
  }

  /// Reads the story file from the specified URL.
  ByteArray readStoryDataFromUrl() {
    throw UnimplementedError();
  }

  /// Reads story data from file.
  ByteArray readStoryDataFromFile() {
    if (_initStruct.storyFile != null) {
      return FileUtils.readFileBytes(_initStruct.storyFile);
    } else {
      // Read from Z BLORB
      FormChunk formchunk = _readBlorbFromFile();
      return formchunk != null ? BlorbFile(formchunk).getStoryData() : null;
    }
  }

  /// Reads the resource data.
  Resources readResources() {
    if (_initStruct.blorbFile != null) return _readResourcesFromFile();
    if (_initStruct.blorbURL != null) return _readResourcesFromUrl();
    return null;
  }

  ///  Reads Blorb data from file.
  FormChunk _readBlorbFromFile() {
    if (_blorbchunk == null) {
      ByteArray data = FileUtils.readFileBytes(_initStruct.blorbFile);
      if (data != null) {
        _blorbchunk = DefaultFormChunk(DefaultMemory(data));
        if ("IFRS" != _blorbchunk.getSubId()) {
          throw IOException("not a valid Blorb file");
        }
      }
    }
    return _blorbchunk;
  }

  /// Reads story resources from input blorb file.
  Resources _readResourcesFromFile() {
    FormChunk formchunk = _readBlorbFromFile();
    return (formchunk != null)
        ? BlorbResources(_initStruct.nativeImageFactory,
            _initStruct.soundEffectFactory, formchunk)
        : null;
  }

  /// Reads Blorb's form chunk from the specified input stream object.
  FormChunk _readBlorb(JavaInputStream blorbis) {
    if (_blorbchunk == null) {
      ByteArray data = FileUtils.readFileBytes(blorbis);
      if (data != null) {
        _blorbchunk = DefaultFormChunk(DefaultMemory(data));
      }
    }
    return _blorbchunk;
  }

  /// Reads story resources from URL.
  Resources _readResourcesFromUrl() {
    FormChunk formchunk = _readBlorb(_initStruct.blorbURL.openStream());
    return (formchunk != null)
        ? BlorbResources(_initStruct.nativeImageFactory,
            _initStruct.soundEffectFactory, formchunk)
        : null;
  }

  // ************************************************************************
  // ****** Private methods
  // ********************************
  /// Checks the story file version.
  bool isInvalidStory(final int version) {
    return version < 1 || version > 8;
  }

  ///  Initializes the I/O system.
  void _initIOSystem(final MachineImpl machine) {
    _initInputStreams(machine);
    initOutputStreams(machine);
    machine.setStatusLine(_initStruct.statusLine);
    machine.setScreen(_initStruct.screenModel);
    machine.setSaveGameDataStore(_initStruct.saveGameDataStore);
  }

  /// Initializes the input streams.
  void _initInputStreams(final MachineImpl machine) {
    machine.setInputStream(0, _initStruct.keyboardInputStream);
    machine.setInputStream(1, FileInputStream(_initStruct.ioSystem, machine));
  }

  /// Initializes the output streams.
  void initOutputStreams(final MachineImpl machine) {
    machine.setOutputStream(1, _initStruct.screenModel.getOutputStream());
    machine.selectOutputStream(1, true);
    machine.setOutputStream(
        2, TranscriptOutputStream(_initStruct.ioSystem, machine));
    machine.selectOutputStream(2, false);
    machine.setOutputStream(3, MemoryOutputStream(machine));
    machine.selectOutputStream(3, false);
  }
}

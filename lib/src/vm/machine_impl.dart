import '../../zvm.dart';

/// This class implements the state and some services of a Z-machine, version 3.
class MachineImpl implements Machine, DrawingArea {
  static final Logger _LOG = Logger.getLogger("org.zmpp");

  /// Number of undo steps.
  static final int _NUM_UNDO = 5;

  static final String _WHITESPACE = " \n\t\r";

  MachineRunState _runstate;
  RandomGenerator _random;
  StatusLine _statusLine;
  ScreenModel _screenModel;
  SaveGameDataStore _datastore;
  RingBuffer<PortableGameState> _undostates;
  InputFunctions _inputFunctions;
  SoundSystem _soundSystem;
  PictureManager _pictureManager;
  Cpu _cpu;
  OutputImpl _output;
  InputImpl _input;

  // Formerly GameData
  StoryFileHeader _fileheader;
  Memory _memory;
  Dictionary _dictionary;
  ObjectTree _objectTree;
  ZsciiEncoding _encoding;
  ZCharDecoder _decoder;
  ZCharEncoder _encoder;
  AlphabetTable _alphabetTable;
  Resources _resources;
  ByteArray _storyfileData;
  int _checksum = 0;

  MachineImpl() {
    _inputFunctions = InputFunctions(this);
  }

  @override
  void initialize(final ByteArray data, Resources aResources) {
    _storyfileData = data;
    _resources = aResources;
    _random = UnpredictableRandomGenerator();
    _undostates = RingBuffer<PortableGameState>(_NUM_UNDO);

    _cpu = CpuImpl(this);
    _output = OutputImpl(this);
    _input = InputImpl();

    MediaCollection<SoundEffect> sounds;
    MediaCollection<ZmppImage> pictures;
    int resourceRelease = 0;

    if (_resources != null) {
      sounds = _resources.getSounds();
      pictures = _resources.getImages();
      resourceRelease = _resources.getRelease();
    }

    _soundSystem = SoundSystemImpl(sounds);
    _pictureManager = PictureManagerImpl(resourceRelease, this, pictures);

    _resetState();
  }

  /// Resets the data.
  void resetGameData() {
    // Make a copy and initialize from the copy
    final ByteArray data = ByteArray.length(_storyfileData.length);
    arraycopy(_storyfileData, 0, data, 0, _storyfileData.length);

    _memory = DefaultMemory(data);
    _fileheader = DefaultStoryFileHeader(_memory);
    _checksum = _calculateChecksum();

    final DictionarySizes dictionarySizes = (_fileheader.getVersion() <= 3)
        ? DictionarySizesV1ToV3()
        : DictionarySizesV4ToV8();
    // Install the whole character code system here
    _initEncodingSystem(dictionarySizes);

    // The object tree and dictionaries depend on the code system
    if (_fileheader.getVersion() <= 3) {
      _objectTree = ClassicObjectTree(_memory,
          _memory.readUnsigned16(StoryFileHeader.OBJECT_TABLE).toInt());
    } else {
      _objectTree = ModernObjectTree(_memory,
          _memory.readUnsigned16(StoryFileHeader.OBJECT_TABLE).toInt());
    }
    // CAUTION: the current implementation of DefaultDictionary reads in all
    // entries into a hash table, so it will break when moving this statement
    // to a different position
    _dictionary = DefaultDictionary(
        _memory,
        _memory.readUnsigned16(StoryFileHeader.DICTIONARY).toInt(),
        _decoder,
        _encoder,
        dictionarySizes);
  }

  /// Initializes the encoding system.
  void _initEncodingSystem(DictionarySizes dictionarySizes) {
    final AccentTable accentTable =
        (_fileheader.getCustomAccentTable().toInt() == 0)
            ? DefaultAccentTable()
            : CustomAccentTable(
                _memory, _fileheader.getCustomAccentTable().toInt());
    _encoding = ZsciiEncoding(accentTable);

    // Configure the alphabet table
    int customAlphabetTable =
        _memory.readUnsigned16(StoryFileHeader.CUSTOM_ALPHABET).toInt();
    if (customAlphabetTable == 0) {
      if (_fileheader.getVersion() == 1) {
        _alphabetTable = AlphabetTableV1();
      } else if (_fileheader.getVersion() == 2) {
        _alphabetTable = AlphabetTableV2();
      } else {
        _alphabetTable = DefaultAlphabetTable();
      }
    } else {
      _alphabetTable = CustomAlphabetTable(_memory, customAlphabetTable);
    }

    final ZCharTranslator translator = DefaultZCharTranslator(_alphabetTable);

    final Abbreviations abbreviations = Abbreviations(
        _memory, _memory.readUnsigned16(StoryFileHeader.ABBREVIATIONS).toInt());
    _decoder = DefaultZCharDecoder(_encoding, translator, abbreviations);
    _encoder = ZCharEncoder(translator, dictionarySizes);
  }

  /// Calculates the checksum of the file.
  int _calculateChecksum() {
    final int filelen = _fileheader.getFileLength();
    int sum = 0;
    for (int i = 0x40; i < filelen; i++) {
      sum += _memory.readUnsigned8(i).toInt();
    }
    return (sum & 0xffff);
  }

  @override
  int getVersion() {
    return getFileHeader().getVersion();
  }

  @override
  int getRelease() {
    return _memory.readUnsigned16(StoryFileHeader.RELEASE).toInt();
  }

  @override
  bool hasValidChecksum() {
    return this._checksum == _getChecksum();
  }

  @override
  StoryFileHeader getFileHeader() {
    return _fileheader;
  }

  @override
  Resources getResources() {
    return _resources;
  }

  // **********************************************************************
  // ***** Memory interface functionality
  // **********************************************************************
  @override
  Char readUnsigned16(int address) {
    return _memory.readUnsigned16(address);
  }

  @override
  Char readUnsigned8(int address) {
    return _memory.readUnsigned8(address);
  }

  @override
  void writeUnsigned16(int address, Char value) {
    _memory.writeUnsigned16(address, value);
  }

  @override
  void writeUnsigned8(int address, Char value) {
    _memory.writeUnsigned8(address, value);
  }

  @override
  void copyBytesToArray(
      ByteArray dstData, int dstOffset, int srcOffset, int numBytes) {
    _memory.copyBytesToArray(dstData, dstOffset, srcOffset, numBytes);
  }

  @override
  void copyBytesFromArray(
      ByteArray srcData, int srcOffset, int dstOffset, int numBytes) {
    _memory.copyBytesFromArray(srcData, srcOffset, dstOffset, numBytes);
  }

  @override
  void copyBytesFromMemory(
      Memory srcMem, int srcOffset, int dstOffset, int numBytes) {
    _memory.copyBytesFromMemory(srcMem, srcOffset, dstOffset, numBytes);
  }

  @override
  void copyArea(int src, int dst, int numBytes) {
    _memory.copyArea(src, dst, numBytes);
  }

  // **********************************************************************
  // ***** Cpu interface functionality
  // **********************************************************************

  @override
  Char getVariable(Char varnum) {
    return _cpu.getVariable(varnum);
  }

  @override
  void setVariable(Char varnum, Char value) {
    _cpu.setVariable(varnum, value);
  }

  @override
  Char getStackTop() {
    return _cpu.getStackTop();
  }

  @override
  Char getStackElement(int index) {
    return _cpu.getStackElement(index);
  }

  @override
  void setStackTop(Char value) {
    _cpu.setStackTop(value);
  }

  @override
  void incrementPC(int length) {
    _cpu.incrementPC(length);
  }

  @override
  void setPC(int address) {
    _cpu.setPC(address);
  }

  @override
  int getPC() {
    return _cpu.getPC();
  }

  @override
  Char getSP() {
    return _cpu.getSP();
  }

  @override
  Char popStack(Char userstackAddress) {
    return _cpu.popStack(userstackAddress);
  }

  @override
  bool pushStack(Char stack, Char value) {
    return _cpu.pushStack(stack, value);
  }

  @override
  List<RoutineContext> getRoutineContexts() {
    return _cpu.getRoutineContexts();
  }

  @override
  void setRoutineContexts(List<RoutineContext> routineContexts) {
    _cpu.setRoutineContexts(routineContexts);
  }

  @override
  void returnWith(Char returnValue) {
    _cpu.returnWith(returnValue);
  }

  @override
  RoutineContext getCurrentRoutineContext() {
    return _cpu.getCurrentRoutineContext();
  }

  @override
  int unpackStringAddress(Char packedAddress) {
    return _cpu.unpackStringAddress(packedAddress);
  }

  @override
  RoutineContext call(
      Char packedAddress, int returnAddress, List<Char> args, Char returnVar) {
    return _cpu.call(packedAddress, returnAddress, args, returnVar);
  }

  @override
  void doBranch(int branchOffset, int instructionLength) {
    _cpu.doBranch(branchOffset, instructionLength);
  }

  // **********************************************************************
  // ***** Dictionary functionality
  // **********************************************************************

  @override
  int lookupToken(int dictionaryAddress, String token) {
    if (dictionaryAddress == 0) {
      return _dictionary.lookup(token);
    }
    return UserDictionary(_memory, dictionaryAddress, _decoder, _encoder)
        .lookup(token);
  }

  @override
  String getDictionaryDelimiters() {
    // Retrieve the defined separators
    final StringBuffer separators = StringBuffer();
    separators.write(_WHITESPACE);
    for (int i = 0, n = _dictionary.getNumberOfSeparators(); i < n; i++) {
      separators.write(_decoder.decodeZChar(Char(_dictionary.getSeparator(i))));
    }
    // The tokenizer will also return the delimiters
    return separators.toString();
  }

  // **********************************************************************
  // ***** Encoding functionality
  // **********************************************************************
  @override
  String convertToZscii(String str) {
    return _encoding.convertToZscii(str);
  }

  @override
  void encode(int source, int length, int destination) {
    _encoder.encode(_memory, source, length, destination);
  }

  @override
  int getNumZEncodedBytes(int address) {
    return _decoder.getNumZEncodedBytes(_memory, address);
  }

  @override
  String decode2Zscii(int address, int length) {
    return _decoder.decode2Zscii(_memory, address, length);
  }

  @override
  Char getUnicodeChar(Char zsciiChar) {
    return _encoding.getUnicodeChar(zsciiChar);
  }

  // **********************************************************************
  // ***** Output stream management, implemented by the OutputImpl object
  // **********************************************************************
  /// Sets the output stream to the specified number.
  void setOutputStream(int streamnumber, OutputStream stream) {
    _output.setOutputStream(streamnumber, stream);
  }

  @override
  void selectOutputStream(int streamnumber, bool flag) {
    _output.selectOutputStream(streamnumber, flag);
  }

  @override
  void selectOutputStream3(int tableAddress, int tableWidth) {
    _output.selectOutputStream3(tableAddress, tableWidth);
  }

  @override
  void printZString(int stringAddress) {
    _output.printZString(stringAddress);
  }

  @override
  void print(String str) {
    _output.print(str);
  }

  @override
  void newline() {
    _output.newline();
  }

  @override
  void printZsciiChar(Char zchar) {
    _output.printZsciiChar(zchar);
  }

  @override
  void printNumber(int num) {
    _output.printNumber(num);
  }

  @override
  void flushOutput() {
    _output.flushOutput();
  }

  @override
  void reset() {
    _output.reset();
  }

  // **********************************************************************
  // ***** Input stream management, implemented by the InputImpl object
  // ********************************************************************
  /// Sets an input stream to the specified number.
  void setInputStream(int streamNumber, InputStream stream) {
    _input.setInputStream(streamNumber, stream);
  }

  @override
  InputStream getSelectedInputStream() {
    return _input.getSelectedInputStream();
  }

  @override
  void selectInputStream(int streamNumber) {
    _input.selectInputStream(streamNumber);
  }

  @override
  Char random(final int range) {
    if (range < 0) {
      _random = PredictableRandomGenerator(-range);
      return Char(0);
    } else if (range == 0) {
      _random = UnpredictableRandomGenerator();
      return Char(0);
    }
    return Char((_random.next() % range) + 1);
  }

  // ************************************************************************
  // ****** Control functions
  // ************************************************
  @override
  MachineRunState getRunState() {
    return _runstate;
  }

  @override
  void setRunState(MachineRunState aRunstate) {
    this._runstate = aRunstate;
    if (_runstate != null && _runstate.isWaitingForInput()) {
      updateStatusLine();
      flushOutput();
    }
  }

  @override
  void halt(final String errormsg) {
    print(errormsg);
    _runstate = MachineRunState.STOPPED;
  }

  @override
  void warn(final String msg) {
    _LOG.warning("WARNING: " + msg);
  }

  @override
  void restart() {
    _restart(true);
  }

  @override
  void quit() {
    _runstate = MachineRunState.STOPPED;
    // On quit, close the streams
    _output.print("*Game ended*");
    _closeStreams();
  }

  @override
  void start() {
    _runstate = MachineRunState.RUNNING;
  }

  // ************************************************************************
  // ****** Machine services
  // ************************************************

  @override
  void tokenize(final int textbuffer, final int parsebuffer,
      final int dictionaryAddress, final bool flag) {
    _inputFunctions.tokenize(textbuffer, parsebuffer, dictionaryAddress, flag);
  }

  @override
  Char readLine(final int textbuffer) {
    return _inputFunctions.readLine(textbuffer);
  }

  @override
  Char readChar() {
    return _inputFunctions.readChar();
  }

  @override
  SoundSystem getSoundSystem() {
    return _soundSystem;
  }

  @override
  PictureManager getPictureManager() {
    return _pictureManager;
  }

  @override
  void setSaveGameDataStore(final SaveGameDataStore aDatastore) {
    this._datastore = aDatastore;
  }

  @override
  void updateStatusLine() {
    if (getFileHeader().getVersion() <= 3 && _statusLine != null) {
      final int objNum = _cpu.getVariable(Char(0x10)).toInt();
      final String objectName = _decoder.decode2Zscii(
          _memory, _objectTree.getPropertiesDescriptionAddress(objNum), 0);
      final int global2 = _cpu.getVariable(Char(0x11)).toInt();
      final int global3 = _cpu.getVariable(Char(0x12)).toInt();
      if (getFileHeader().isEnabled(Attribute.SCORE_GAME)) {
        _statusLine.updateStatusScore(objectName, global2, global3);
      } else {
        _statusLine.updateStatusTime(objectName, global2, global3);
      }
    }
  }

  @override
  void setStatusLine(final StatusLine statusLine) {
    this._statusLine = statusLine;
  }

  @override
  void setScreen(final ScreenModel screen) {
    this._screenModel = screen;
  }

  @override
  ScreenModel getScreen() {
    return _screenModel;
  }

  @override
  ScreenModel6 getScreen6() {
    return _screenModel as ScreenModel6;
  }

  @override
  bool save(final int savepc) {
    if (_datastore != null) {
      final PortableGameState gamestate = PortableGameState();
      gamestate.captureMachineState(this, savepc);
      final WritableFormChunk formChunk = gamestate.exportToFormChunk();
      return _datastore.saveFormChunk(formChunk);
    }
    return false;
  }

  @override
  bool save_undo(final int savepc) {
    final PortableGameState undoGameState = PortableGameState();
    undoGameState.captureMachineState(this, savepc);
    _undostates.add(undoGameState);
    return true;
  }

  @override
  PortableGameState restore() {
    if (_datastore != null) {
      final PortableGameState gamestate = PortableGameState();
      final FormChunk formchunk = _datastore.retrieveFormChunk();
      gamestate.readSaveGame(formchunk);

      // verification has to be here
      if (_verifySaveGame(gamestate)) {
        // do not reset screen model, since e.g. AMFV simply picks up the
        // current window state
        _restart(false);
        gamestate.transferStateToMachine(this);
        return gamestate;
      }
    }
    return null;
  }

  @override
  PortableGameState restore_undo() {
    // do not reset screen model, since e.g. AMFV simply picks up the
    // current window state
    if (_undostates.size() > 0) {
      final PortableGameState undoGameState =
          _undostates.remove(_undostates.size() - 1);
      _restart(false);
      undoGameState.transferStateToMachine(this);
      _LOG.info("restore(), pc is: ${toHexStrPad4Space(_cpu.getPC())}\n");
      return undoGameState;
    }
    return null;
  }

  // ***********************************************************************
  // ***** Private methods
  // **************************************
  /// Verifies the integrity of the save game.
  bool _verifySaveGame(final PortableGameState gamestate) {
    // Verify the game according to the standard
    int saveGameChecksum = _getChecksum();
    if (saveGameChecksum == 0) {
      saveGameChecksum = this._checksum;
    }
    return gamestate.getRelease() == getRelease() &&
        gamestate.getChecksum() == _checksum &&
        gamestate.getSerialNumber() == getFileHeader().getSerialNumber();
  }

  /// Returns the checksum.
  int _getChecksum() {
    return _memory.readUnsigned16(StoryFileHeader.CHECKSUM).toInt();
  }

  /// Close the streams.
  void _closeStreams() {
    _input.close();
    _output.close();
  }

  /// Resets all state to initial values, using the configuration object.
  void _resetState() {
    resetGameData();
    _output.reset();
    _soundSystem.reset();
    _cpu.reset();
    _setStandardRevision(1, 0);
    if (getFileHeader().getVersion() >= 4) {
      getFileHeader().setEnabled(Attribute.SUPPORTS_TIMED_INPUT, true);
      // IBM PC
      _memory.writeUnsigned8(StoryFileHeader.INTERPRETER_NUMBER, Char(6));
      getFileHeader().setInterpreterVersion(1);
    }
  }

  /// Sets standard revision.
  void _setStandardRevision(int major, int minor) {
    _memory.writeUnsigned8(StoryFileHeader.STD_REVISION_MAJOR, Char(major));
    _memory.writeUnsigned8(StoryFileHeader.STD_REVISION_MINOR, Char(minor));
  }

  /// Restarts the VM.
  void _restart(final bool resetScreenModel) {
    // Transcripting and fixed font bits survive the restart
    final StoryFileHeader fileHeader = getFileHeader();
    final bool fixedFontForced =
        fileHeader.isEnabled(Attribute.FORCE_FIXED_FONT);
    final bool transcripting = fileHeader.isEnabled(Attribute.TRANSCRIPTING);

    _resetState();

    if (resetScreenModel) {
      _screenModel.reset();
    }
    fileHeader.setEnabled(Attribute.TRANSCRIPTING, transcripting);
    fileHeader.setEnabled(Attribute.FORCE_FIXED_FONT, fixedFontForced);
  }

  // ***********************************************************************
  // ***** Object accesss
  // ************************************

  @override
  void insertObject(int parentNum, int objectNum) {
    _objectTree.insertObject(parentNum, objectNum);
  }

  @override
  void removeObject(int objectNum) {
    _objectTree.removeObject(objectNum);
  }

  @override
  void clearAttribute(int objectNum, int attributeNum) {
    _objectTree.clearAttribute(objectNum, attributeNum);
  }

  @override
  bool isAttributeSet(int objectNum, int attributeNum) {
    return _objectTree.isAttributeSet(objectNum, attributeNum);
  }

  @override
  void setAttribute(int objectNum, int attributeNum) {
    _objectTree.setAttribute(objectNum, attributeNum);
  }

  @override
  int getParent(int objectNum) {
    return _objectTree.getParent(objectNum);
  }

  @override
  void setParent(int objectNum, int parent) {
    _objectTree.setParent(objectNum, parent);
  }

  @override
  int getChild(int objectNum) {
    return _objectTree.getChild(objectNum);
  }

  @override
  void setChild(int objectNum, int child) {
    _objectTree.setChild(objectNum, child);
  }

  @override
  int getSibling(int objectNum) {
    return _objectTree.getSibling(objectNum);
  }

  @override
  void setSibling(int objectNum, int sibling) {
    _objectTree.setSibling(objectNum, sibling);
  }

  @override
  int getPropertiesDescriptionAddress(int objectNum) {
    return _objectTree.getPropertiesDescriptionAddress(objectNum);
  }

  @override
  int getPropertyAddress(int objectNum, int property) {
    return _objectTree.getPropertyAddress(objectNum, property);
  }

  @override
  int getPropertyLength(int propertyAddress) {
    return _objectTree.getPropertyLength(propertyAddress);
  }

  @override
  Char getProperty(int objectNum, int property) {
    return _objectTree.getProperty(objectNum, property);
  }

  @override
  void setProperty(int objectNum, int property, Char value) {
    _objectTree.setProperty(objectNum, property, value);
  }

  @override
  int getNextProperty(int objectNum, int property) {
    return _objectTree.getNextProperty(objectNum, property);
  }

  @override
  Resolution getResolution() {
    return getScreen6().getResolution();
  }
}

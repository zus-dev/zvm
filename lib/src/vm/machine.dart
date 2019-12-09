import '../../zvm.dart';

/// This interface acts as a central access point to the Z-Machine's components.
/// It is mainly provided as a service point for the instructions to manipulate
/// and read the VM's internal state.
abstract class Machine
    implements ObjectTree, Input, Output, Cpu, Memory, IZsciiEncoding {
  /// Initializes with the story [data] and Blorb [resources]
  void initialize(ByteArray data, Resources resources);

  /// Returns the story file version.
  int getVersion();

  /// Returns the release.
  int getRelease();

  /// Checks the check sum.
  bool hasValidChecksum();

  // **********************************************************************
  // **** Main machine objects
  // *******************************

  /// Returns the story file header.
  StoryFileHeader getFileHeader();

  /// Returns story resources.
  Resources getResources();

  // **********************************************************************
  // **** Tokenizing functions
  // **** We could refine this by exposing the tokenizers
  // **** instead of dictionary functionality
  // **********************************************************

  /// Looks up token in dictionary.
  int lookupToken(int dictionaryAddress, String token);

  /// Returns the dictionary delimiters.
  String getDictionaryDelimiters();

  // **********************************************************************
  // **** Encoding functions
  // **********************************************************

  /// Encode memory at [source] position to ZSCII and writes at the [destination] position.
  void encode(int source, int length, int destination);

  /// Decode specified [length] in bytes of the memory at the [address] to ZSCII.
  String decode2Zscii(int address, int length);

  /// Returns the number of Z-encoded bytes at the specified string [address].
  int getNumZEncodedBytes(int address);

  // ************************************************************************
  // ****** Control functions
  // ************************************************
  /// Returns the current run state of the machine
  MachineRunState getRunState();

  /// Sets the current run state of the machine
  void setRunState(MachineRunState runstate);

  /// Halts the machine with the specified error message.
  void halt(String errormsg);

  /// Restarts the virtual machine.
  void restart();

  /// Starts the virtual machine.
  void start();

  /// Exists the virtual machine.
  void quit();

  /// Outputs a warning message.
  void warn(String msg);

  // **********************************************************************
  // **** Services
  // *******************************

  /// Tokenizes the text in the text buffer using the specified parse buffer.
  /// Params:
  /// [dictionaryAddress] the dictionary address or 0 for the default
  /// dictionary;
  /// [flag] if set, unrecognized words are not written into the parse
  /// buffer and their slots are left unchanged;
  void tokenize(
      int textbuffer, int parsebuffer, int dictionaryAddress, bool flag);

  /// Reads a string from the currently selected input stream into
  /// the [textbuffer] address.
  Char readLine(int textbuffer);

  /// Reads a ZSCII char from the selected input stream.
  Char readChar();

  /// Returns the sound system.
  SoundSystem getSoundSystem();

  /// Returns the picture manager.
  PictureManager getPictureManager();

  /// Generates a number in the range between 1 and <i>range</i>. If range is
  /// negative, the random generator will be seeded to abs(range), if
  /// range is 0, the random generator will be initialized to a new
  /// random seed. In both latter cases, the result will be 0.
  Char random(int range);

  /// Updates the status line.
  void updateStatusLine();

  /// Sets the Z-machine's status line.
  void setStatusLine(StatusLine statusline);

  /// Sets the game screen.
  void setScreen(ScreenModel screen);

  /// Gets the game screen.
  ScreenModel getScreen();

  /// Returns screen model 6.
  ScreenModel6 getScreen6();

  /// Sets the save game data store.
  void setSaveGameDataStore(SaveGameDataStore datastore);

  /// Saves the current state.
  bool save(int savepc);

  /// Saves the current state in memory.
  bool save_undo(int savepc);

  /// Restores a previously saved state.
  PortableGameState restore();

  /// Restores a previously saved state from memory.
  PortableGameState restore_undo();
}

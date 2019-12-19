import '../../zvm.dart';

enum ReadMode { NONE, READ_CHAR, READ_LINE }

/// This class models a machine run state that also stores data for timed
/// input, so a client application can call an interrupt method on the machine.
class MachineRunState implements Serializable {
  /// Reading modes.
  int _time = 0;
  int _numLeftOverChars = 0;
  Char _routine = Char(0);
  Char _textbuffer = Char(0);
  ReadMode _readMode = ReadMode.NONE;

  /// Private constructor
  MachineRunState._();

  /// Constructor for reading modes.
  /// [readMode] the read mode
  /// [time] the interrupt routine time interval
  /// [routine] the packed interrupt routine address
  /// [numLeftOverChars] the number of characters indicated as left over
  /// [textbuffer] text buffer address
  MachineRunState.forRead(ReadMode readMode, int time, Char routine,
      int numLeftOverChars, Char textbuffer) {
    this._readMode = readMode;
    this._time = time;
    this._routine = routine;
    this._numLeftOverChars = numLeftOverChars;
    this._textbuffer = textbuffer;
  }

  /// Returns the interrupt interval.
  int getTime() {
    return _time;
  }

  /// Returns the packed address of the interrupt address.
  Char getRoutine() {
    return _routine;
  }

  /// Returns true if machine is waiting for input.
  bool isWaitingForInput() {
    return _readMode != ReadMode.NONE;
  }

  /// Returns true if machine is in read character mode.
  bool isReadChar() {
    return _readMode == ReadMode.READ_CHAR;
  }

  /// Returns true if machine is in read line mode.
  bool isReadLine() {
    return _readMode == ReadMode.READ_LINE;
  }

  /// Returns the number of characters left over from previous input.
  int getNumLeftOverChars() {
    return _numLeftOverChars;
  }

  /// Returns the address of the text buffer.
  Char getTextBuffer() {
    return _textbuffer;
  }

  /// Running state.
  static final MachineRunState RUNNING = MachineRunState._();

  /// Stopped state.
  static final MachineRunState STOPPED = MachineRunState._();

  /// Creates a read line mode object with the specified interrup data.
  /// [time] interrupt interval
  /// [routine] interrupt routine
  /// [numLeftOverChars] the number of characters left over
  /// [textbuffer] the address of the text buffer
  static MachineRunState createReadLine(
      int time, Char routine, int numLeftOverChars, Char textbuffer) {
    return MachineRunState.forRead(
        ReadMode.READ_LINE, time, routine, numLeftOverChars, textbuffer);
  }

  /// Creates a read character mode object with the specified interrupt data.
  /// [time] interrupt interval
  /// [routine] interrupt routine
  static MachineRunState createReadChar(int time, Char routine) {
    return MachineRunState.forRead(
        ReadMode.READ_CHAR, time, routine, 0, Char(0));
  }
}

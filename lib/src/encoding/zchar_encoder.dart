import 'dart:math';

import '../../zvm.dart';

///  This class encodes ZSCII strings into dictionary encoded strings.
///  Encoding is pretty difficult since there are several variables to
///  remember during the encoding process. We use the State pattern passing
///  around the encoding state for a target word until encoding is complete.
class ZCharEncoder {
  static final Char _PAD_CHAR = Char(5);
  static final int _SLOTS_PER_WORD16 = 3;
  ZCharTranslator _translator;
  DictionarySizes _dictionarySizes;

  ZCharEncoder(
      final ZCharTranslator aTranslator, final DictionarySizes dictSizes) {
    this._translator = aTranslator;
    this._dictionarySizes = dictSizes;
  }

  ///  Encodes the Z word at the specified memory address and writes the encoded
  ///  for to the target address, using the specified word length.
  void encode(final Memory memory, final int sourceAddress, final int length,
      final int targetAddress) {
    final int maxlen = min(length, _dictionarySizes.getMaxEntryChars());
    final EncodingState state = EncodingState();
    state.init(memory, sourceAddress, targetAddress,
        _dictionarySizes.getNumEntryBytes(), maxlen);
    _encode(state, _translator);
  }

  ///  Encodes the specified Z-word contained in the String and writes it to the
  ///  specified target address.
  void encodeString(
      final String str, final Memory memory, final int targetAddress) {
    final StringEncodingState state = StringEncodingState();
    state.initState(str, memory, targetAddress, _dictionarySizes);
    _encode(state, _translator);
  }

  ///  Encodes the string at the specified address and writes it to the target
  ///  address.
  static void _encode(EncodingState state, ZCharTranslator translator) {
    while (state.hasMoreInput()) {
      _processChar(translator, state);
    }
    // Padding
    // This pads the incomplete currently encoded word
    if (!state.currentWordWasProcessed() && !state.atLastWord16()) {
      int resultword = state.currentWord;
      for (int i = state.wordPosition; i < _SLOTS_PER_WORD16; i++) {
        resultword = _writeZcharToWord(resultword, _PAD_CHAR, i).toInt();
      }
      state.writeUnsigned16(toUnsigned16(resultword));
    }

    // If we did not encode 3 16-bit words, fill the remaining ones with
    // 0x14a5's (= 0-{5,5,5})
    while (state.getTargetOffset() < state.getNumEntryBytes()) {
      state.writeUnsigned16(toUnsigned16(0x14a5));
    }

    // Always mark the last word as such
    state.markLastWord();
  }

  ///  Processes the current character.
  static void _processChar(ZCharTranslator translator, EncodingState state) {
    final Char zsciiChar = state.nextChar();
    final AlphabetElement element = translator.getAlphabetElementFor(zsciiChar);
    if (element.getAlphabet() == null) {
      final Char zcharCode = element.getZCharCode();
      // This is a ZMPP specialty, we do not want to end the string
      // in the middle of encoding, so we only encode if there is
      // enough space in the target (4 5-bit slots are needed to do an
      // A2-escape).
      // We might want to reconsider this, let's see, if there are problems
      // with different dictionaries
      final int numRemainingSlots = _getNumRemainingSlots(state);
      if (numRemainingSlots >= 4) {
        // Escape A2
        _processWord(state, Char(AlphabetTable.SHIFT_5));
        _processWord(state, Char(AlphabetTable.A2_ESCAPE));
        _processWord(state, _getUpper5Bit(zcharCode));
        _processWord(state, _getLower5Bit(zcharCode));
      } else {
        // pad remaining slots with SHIFT_5's
        for (int i = 0; i < numRemainingSlots; i++) {
          _processWord(state, Char(AlphabetTable.SHIFT_5));
        }
      }
    } else {
      final Alphabet alphabet = element.getAlphabet();
      final Char zcharCode = element.getZCharCode();
      if (alphabet == Alphabet.A1) {
        _processWord(state, Char(AlphabetTable.SHIFT_4));
      } else if (alphabet == Alphabet.A2) {
        _processWord(state, Char(AlphabetTable.SHIFT_5));
      }
      _processWord(state, zcharCode);
    }
  }

  ///  Returns the number of remaining slots.
  static int _getNumRemainingSlots(final EncodingState state) {
    // TODO: check if floor is correct!
    final int currentWord = (state.getTargetOffset() / 2).floor();
    return ((2 - currentWord) * 3) + (3 - state.wordPosition);
  }

  ///  Processes the current word.
  static void _processWord(final EncodingState state, final Char value) {
    state.currentWord =
        _writeZcharToWord(state.currentWord, value, state.wordPosition++)
            .toInt();
    _writeWordIfNeeded(state);
  }

  ///  Writes the current word if needed.
  static void _writeWordIfNeeded(final EncodingState state) {
    if (state.currentWordWasProcessed() && !state.atLastWord16()) {
      // Write the result and increment the target position
      state.writeUnsigned16(toUnsigned16(state.currentWord));
      state.currentWord = 0;
      state.wordPosition = 0;
    }
  }

  ///  Retrieves the upper 5 bit of the specified ZSCII character.
  static Char _getUpper5Bit(final Char zsciiChar) {
    // TODO: return Char((zsciiChar.toInt() >>> 5) & 0x1f);
    return Char((zsciiChar.toInt() >> 5) & 0x1f);
  }

  ///  Retrieves the lower 5 bit of the specified ZSCII character.
  static Char _getLower5Bit(final Char zsciiChar) {
    return Char(zsciiChar & 0x1f);
  }

  ///  This function sets a zchar value to the specified position within
  ///  a word. There are three positions within a 16 bit word and the bytes
  ///  are truncated such that only the lower 5 bit are taken as values.
  static Char _writeZcharToWord(
      final int dataword, final Char zchar, final int pos) {
    final int shiftwidth = (2 - pos) * 5;
    return Char(dataword | ((zchar & 0x1f) << shiftwidth));
  }
}

class EncodingState {
  Memory _memory;
  int source; // protected
  int _sourceStart;
  int _maxLength;
  int _numEntryBytes;
  int _target;
  int _targetStart;

  // currently public
  // currentWord represents the state of the current word the encoder is
  // working on. The encoder attempts to fill the three slots contained in
  // this word and later writes it to the target memory address
  int currentWord;

  // The current slot position within currentWord, can be 0, 1 or 2
  int wordPosition;

  void init(
      Memory mem, int src, int trgt, int maxEntryBytes, int maxEntryChars) {
    _memory = mem;
    source = src;
    _sourceStart = src;
    _target = trgt;
    _targetStart = trgt;
    _numEntryBytes = maxEntryBytes;
    _maxLength = maxEntryChars;
  }

  ///  Indicates whether the current word was already processed.
  bool currentWordWasProcessed() {
    return wordPosition > 2;
  }

  ///  Returns the target offset.
  int getTargetOffset() {
    return _target - _targetStart;
  }

  ///  Returns the number of entry bytes.
  int getNumEntryBytes() {
    return _numEntryBytes;
  }

  ///  Determines whether we are already at the last 16-bit word.
  bool atLastWord16() {
    return _target > _targetStart + _getLastWord16Offset();
  }

  ///  Returns the offset of the last 16 bit word.
  int _getLastWord16Offset() {
    return _numEntryBytes - 2;
  }

  ///  Returns the next character.
  Char nextChar() {
    return _memory.readUnsigned8(source++);
  }

  ///  Marks the last word.
  void markLastWord() {
    final int lastword =
        _memory.readUnsigned16(_targetStart + _getLastWord16Offset()).toInt();
    _memory.writeUnsigned16(
        _targetStart + _getLastWord16Offset(), toUnsigned16(lastword | 0x8000));
  }

  ///  Writes the specified 16 bit value to the current memory address.
  void writeUnsigned16(Char value) {
    _memory.writeUnsigned16(_target, value);
    _target += 2;
  }

  ///  Determines whether there is more input.
  bool hasMoreInput() {
    return source < _sourceStart + _maxLength;
  }
}

///  Representation of StringEncodingState.
class StringEncodingState extends EncodingState {
  String _input;

  void initState(
      String inputStr, Memory mem, int trgt, DictionarySizes dictionarySizes) {
    super.init(mem, 0, trgt, dictionarySizes.getNumEntryBytes(),
        min(inputStr.length, dictionarySizes.getMaxEntryChars()));
    _input = inputStr;
  }

  ///  Retrieve to next character.
  Char nextChar() {
    return Char.at(_input, source++);
  }
}

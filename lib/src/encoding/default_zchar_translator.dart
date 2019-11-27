import '../../zvm.dart';

/// The default implementation of ZCharTranslator.
class DefaultZCharTranslator implements ZCharTranslator {
  AlphabetTable _alphabetTable;
  Alphabet _currentAlphabet;
  Alphabet _lockAlphabet;
  bool _shiftLock;

  DefaultZCharTranslator(final AlphabetTable alphabetTable) {
    this._alphabetTable = alphabetTable;
    reset();
  }

  @override
  void reset() {
    _currentAlphabet = Alphabet.A0;
    _lockAlphabet = null;
    _shiftLock = false;
  }

  /// Reset the translation to use the last alphabet used.
  void resetToLastAlphabet() {
    if (_lockAlphabet == null) {
      _currentAlphabet = Alphabet.A0;
    } else {
      _currentAlphabet = _lockAlphabet;
      _shiftLock = true;
    }
  }

  @override
  ZCharTranslator clone() {
    // TODO: clone alphabetTable ?
    DefaultZCharTranslator clone = DefaultZCharTranslator(_alphabetTable);
    clone.reset();
    return clone;
  }

  @override
  Alphabet getCurrentAlphabet() {
    return _currentAlphabet;
  }

  @override
  Char translate(final Char zchar) {
    if (_shift(zchar)) return Char.of('\u0000');

    Char result = Char(0);
    if (_isInAlphabetRange(zchar)) {
      switch (_currentAlphabet) {
        case Alphabet.A0:
          result = _alphabetTable.getA0Char(zchar.toInt());
          break;
        case Alphabet.A1:
          result = _alphabetTable.getA1Char(zchar.toInt());
          break;
        case Alphabet.A2:
        default:
          result = _alphabetTable.getA2Char(zchar.toInt());
          break;
      }
    } else {
      result = Char.of('?');
    }
    // Only reset if the shift lock flag is not set
    if (!_shiftLock) resetToLastAlphabet();
    return result;
  }

  @override
  bool willEscapeA2(final Char zchar) {
    return _currentAlphabet == Alphabet.A2 &&
        zchar.toInt() == AlphabetTable.A2_ESCAPE;
  }

  @override
  bool isAbbreviation(final Char zchar) {
    return _alphabetTable.isAbbreviation(zchar);
  }

  @override
  AlphabetElement getAlphabetElementFor(final Char zsciiChar) {
    // Special handling for newline !!
    if (zsciiChar == Char.of('\n')) {
      return AlphabetElement(Alphabet.A2, Char(7));
    }

    Alphabet alphabet;
    int zcharCode = _alphabetTable.getA0CharCode(zsciiChar);

    if (zcharCode >= 0) {
      alphabet = Alphabet.A0;
    } else {
      zcharCode = _alphabetTable.getA1CharCode(zsciiChar);
      if (zcharCode >= 0) {
        alphabet = Alphabet.A1;
      } else {
        zcharCode = _alphabetTable.getA2CharCode(zsciiChar);
        if (zcharCode >= 0) {
          alphabet = Alphabet.A2;
        }
      }
    }

    if (alphabet == null) {
      // It is not in any alphabet table, we are fine with taking the code
      // number for the moment
      zcharCode = zsciiChar.toInt();
    }
    return AlphabetElement(alphabet, Char(zcharCode));
  }

  /// Determines if the given byte value falls within the alphabet range.
  /// @param zchar the zchar value
  /// @return true if the value is in the alphabet range, false, otherwise
  static bool _isInAlphabetRange(final Char zchar) {
    return 0 <= zchar.toInt() && zchar.toInt() <= AlphabetTable.ALPHABET_END;
  }

  /// Performs a shift.
  /// @param zchar a z encoded character
  /// @return true if a shift was performed, false, otherwise
  bool _shift(final Char zchar) {
    if (_alphabetTable.isShift(zchar)) {
      _currentAlphabet = _shiftFrom(_currentAlphabet, zchar);

      // Sets the current lock alphabet
      if (_alphabetTable.isShiftLock(zchar)) {
        _lockAlphabet = _currentAlphabet;
      }
      return true;
    }
    return false;
  }

  /// This method contains the rules to shift the alphabets.
  /// @param alphabet the source alphabet
  /// @param shiftChar the shift character
  /// @return the resulting alphabet
  Alphabet _shiftFrom(final Alphabet alphabet, final Char shiftChar) {
    Alphabet result;

    if (_alphabetTable.isShift1(shiftChar)) {
      if (alphabet == Alphabet.A0) {
        result = Alphabet.A1;
      } else if (alphabet == Alphabet.A1) {
        result = Alphabet.A2;
      } else if (alphabet == Alphabet.A2) {
        result = Alphabet.A0;
      }
    } else if (_alphabetTable.isShift2(shiftChar)) {
      if (alphabet == Alphabet.A0) {
        result = Alphabet.A2;
      } else if (alphabet == Alphabet.A1) {
        result = Alphabet.A0;
      } else if (alphabet == Alphabet.A2) {
        result = Alphabet.A1;
      }
    } else {
      result = alphabet;
    }
    _shiftLock = _alphabetTable.isShiftLock(shiftChar);
    return result;
  }
}

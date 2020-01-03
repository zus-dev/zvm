import '../../zvm.dart';

/// This is the default implementation of the ZCharDecoder interface.
/// The central method is decode2Unicode which handles abbreviations,
/// 10 Bit escape characters and alphabet table characters. Alphabet
/// table characters and shift states are handled by the ZCharTranslator
/// object.
class DefaultZCharDecoder implements ZCharDecoder {
  ZCharTranslator _translator; // private
  ZsciiEncoding _encoding; // private
  AbbreviationsTable _abbreviations; // private
  ZCharDecoder _abbreviationDecoder; // private

  DefaultZCharDecoder(
      final ZsciiEncoding encoding,
      final ZCharTranslator translator,
      final AbbreviationsTable abbreviations) {
    this._abbreviations = abbreviations;
    this._translator = translator;
    this._encoding = encoding;
  }

  @override
  String decode2Zscii(Memory memory, int address, int length) {
    final builder = StringBuffer();
    _translator.reset();
    final zbytes = extractZbytes(memory, address, length);
    Char zchar;
    int i = 0, newpos;

    while (i < zbytes.length) {
      bool decoded = false;
      zchar = zbytes[i];
      newpos = _handleAbbreviation(builder, memory, zbytes, i);
      decoded = (newpos > i);
      i = newpos;

      if (!decoded) {
        newpos = _handleEscapeA2(builder, zbytes, i);
        decoded = newpos > i;
        i = newpos;
      }
      if (!decoded) {
        _decodeZchar(builder, zchar);
        i++;
      }
    }
    return builder.toString();
  }

  /// Process the abbreviation at the specified memory position.
  int _handleAbbreviation(final StringBuffer builder, final Memory memory,
      final List<Char> data, final int pos) {
    int position = pos;
    final zchar = data[position];

    if (_translator.isAbbreviation(zchar)) {
      // we need to check if we are at the end of the buffer, even if an
      // abbreviation is suggested. This happens e.g. in Zork I
      if (position < (data.length - 1)) {
        position++; // retrieve the next byte to determine the abbreviation

        // the abbreviations table could be null, simply skip that part in this
        // case
        if (_abbreviations != null) {
          final int x = data[position].toInt();
          final int entryNum = 32 * (zchar.toInt() - 1) + x;
          final int entryAddress = _abbreviations.getWordAddress(entryNum);
          _createAbbreviationDecoderIfNotExists();
          _appendAbbreviationAtAddress(memory, entryAddress, builder);
        }
      }
      position++;
    }
    return position;
  }

  /// Creates the abbreviation decoder if it does not exist.
  /// TODO: How can we do this in a more elegant way ?
  void _createAbbreviationDecoderIfNotExists() {
    if (_abbreviationDecoder == null) {
      // We only use one abbreviation decoder instance here, we need
      // to clone the alphabet table, so the abbreviation decoding
      // will not influence the continuation of the decoding process
      try {
        _abbreviationDecoder =
            DefaultZCharDecoder(_encoding, _translator.clone(), null);
      } catch (ex) {
        // should never happen
        assert(false);
      }
    }
  }

  /// Appends the abbreviation at the specified memory address to the
  /// StringBuffer.
  void _appendAbbreviationAtAddress(
      Memory memory, int entryAddress, StringBuffer builder) {
    if (_abbreviationDecoder != null) {
      final String abbrev =
          _abbreviationDecoder.decode2Zscii(memory, entryAddress, 0);
      builder.write(abbrev);
    }
  }

  /// Handles the escape character from alphabet 2 and appends the result
  /// to the [builder].
  int _handleEscapeA2(
      final StringBuffer builder, final List<Char> data, final int pos) {
    int position = pos;
    if (_translator.willEscapeA2(data[position])) {
      // If the data is truncated, do not continue (check if the
      // constant should be 2 or 3)
      if (position < data.length - 2) {
        _joinToZsciiChar(builder, data[position + 1], data[position + 2]);
        // skip the three characters read (including the loop increment)
        position += 2;
      }
      position++;
      _translator.resetToLastAlphabet();
    }
    return position;
  }

  @override
  Char decodeZChar(final Char zchar) {
    if (ZsciiEncoding.isAscii(zchar) || ZsciiEncoding.isAccent(zchar)) {
      return zchar;
    } else {
      return _translator.translate(zchar);
    }
  }

  /// Decodes an encoded character and adds it to the specified builder object.
  /// @param builder a ZsciiStringBuilder object
  /// @param zchar the encoded character to decode and add
  /// @return decoded character
  Char _decodeZchar(final StringBuffer builder, final Char zchar) {
    final Char c = decodeZChar(zchar);
    if (c.toInt() != 0) builder.write(c);
    return c;
  }

  @override
  ZCharTranslator getTranslator() {
    return _translator;
  }

  /// Determines the last word in a z sequence. The last word has the
  /// MSB set.
  static bool isEndWord(final Char zword) {
    return (zword & 0x8000) > 0;
  }

  /// This function unfortunately generates a List object on each invocation,
  /// the advantage is that it will return all the characters of the Z string.
  /// @param memory the memory access object
  /// @param address the address of the z string
  /// @param length the maximum length that the array should have or 0 for
  /// unspecified
  /// @return the z characters of the string
  static List<Char> extractZbytes(
      final Memory memory, final int address, final int length) {
    var zword = Char(0);
    int currentAddr = address;
    final List<List<Char>> byteList = List<List<Char>>();

    do {
      zword = memory.readUnsigned16(currentAddr);
      byteList.add(_extractZEncodedBytes(zword));
      currentAddr += 2; // increment pointer

      // if this is a dictionary entry, we need to provide the
      // length and cancel the loop earlier
      if (length > 0 && (currentAddr - address) >= length) {
        break;
      }
    } while (!isEndWord(zword));

    final result = FilledList.ofChar(byteList.length * 3);
    int i = 0;
    for (List<Char> triplet in byteList) {
      for (Char b in triplet) {
        result[i++] = b;
      }
    }
    return result;
  }

  @override
  int getNumZEncodedBytes(Memory memory, int address) {
    var zword = Char(0);
    int currentAddress = address;
    do {
      zword = memory.readUnsigned16(currentAddress);
      currentAddress += 2;
    } while (!isEndWord(zword));
    return currentAddress - address;
  }

  /// Extracts three 5 bit fields from the given 16 bit word and returns
  /// an array of three bytes containing these characters.
  /// @param zword a 16 bit word
  /// @return an array of three bytes containing the three 5-bit ZSCII characters
  /// encoded in the word
  static List<Char> _extractZEncodedBytes(final Char zword) {
    final List<Char> result = FilledList.ofChar(3);
    result[2] = Char(zword.toInt() & 0x1f);
    result[1] = Char((zword.toInt() >> 5) & 0x1f);
    result[0] = Char((zword.toInt() >> 10) & 0x1f);
    return result;
  }

  /// Joins the specified two bytes into a 10 bit ZSCII character.
  /// @param builder the StringBuffer to write to
  /// @param top the byte holding the top 5 bit of the zchar
  /// @param bottom the byte holding the bottom 5 bit of the zchar
  void _joinToZsciiChar(
      final StringBuffer builder, final Char top, final Char bottom) {
    builder.write(Char(top.toInt() << 5 | bottom.toInt()).toString());
  }
}

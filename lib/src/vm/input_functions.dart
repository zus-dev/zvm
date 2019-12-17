import 'dart:collection';
import 'dart:math';

import '../../zvm.dart';

/// This class contains functions that deal with user input.
/// Note: For version 1.5 a number of changes will be performed on this
/// class. Timed input will be eliminated completely, as well as leftover.
/// Command history might be left out as well
class InputFunctions {
  Machine _machine;

  InputFunctions(Machine machine) {
    this._machine = machine;
  }

  // *********************************************************************
  // ****** SREAD/AREAD - the most complex and flexible function within the
  // ****** Z-machine. This function takes input from the user and
  // ****** calls the tokenizer for lexical analysis. It also recognizes
  // ****** terminator characters and controls the output as well as
  // ****** calling an optional interrupt routine.
  // *********************************************************************

  /// By delegating responsibility for timed input to the user interface,
  /// reading input is strongly simplified.
  Char readLine(final int textbuffer) {
    String inputLine = _machine.getSelectedInputStream().readLine();
    _processInput(textbuffer, inputLine);
    return Char.at(inputLine, inputLine.length - 1);
  }

  /// Depending on the terminating character and the story file version,
  /// either write a 0 to the end of the text buffer or write the length
  /// of to the text buffer's first byte.
  void checkTermination(
      final Char terminateChar, final int textbuffer, final int textpointer) {
    final int version = _machine.getVersion();
    if (version >= 5) {
      // Check if was cancelled
      final Char numCharsTyped = (terminateChar.toInt() == IZsciiEncoding.NULL)
          ? Char(0)
          : Char(textpointer - 2);

      // Write the number of characters typed in byte 1
      _machine.writeUnsigned8(textbuffer + 1, numCharsTyped);
    } else {
      // Terminate with 0 byte in versions < 5
      // Check if input was cancelled
      int terminatepos = textpointer; // (textpointer - textbuffer + 2);
      if (terminateChar.toInt() == IZsciiEncoding.NULL) {
        terminatepos = 0;
      }
      _machine.writeUnsigned8(textbuffer + terminatepos, Char(0));
    }
  }

  /// Process input.
  void _processInput(final int textbuffer, String inputString) {
    int storeOffset = _machine.getVersion() <= 4 ? 1 : 2;
    for (int i = 0; i < inputString.length; i++) {
      _machine.writeUnsigned8(textbuffer + i + storeOffset,
          Char(Char.at(inputString, i).toInt() & 0xff));
    }
    Char terminateChar = Char.at(inputString, inputString.length - 1);
    checkTermination(terminateChar, textbuffer, inputString.length + 1);
  }

  /// Depending on the terminating character, return the terminator to
  /// the caller. We need this since aread stores the terminating character
  /// as a result. If a newline was typed as the terminator, a newline
  /// will be echoed, in all other cases, the terminator is simply returned.
  Char handleTerminateChar(final Char terminateChar) {
    if (terminateChar.toInt() == IZsciiEncoding.NEWLINE) {
      // Echo a newline into the streams
      // must be called with isInput == false since we are not
      // in input mode anymore when we receive NEWLINE
      _machine.printZsciiChar(Char(IZsciiEncoding.NEWLINE));
    }
    return terminateChar;
  }

  // **********************************************************************
  // ****** READ_CHAR
  // *******************************
  Char readChar() {
    String inputLine = _machine.getSelectedInputStream().readLine();
    return Char.at(inputLine, 0);
  }

  void tokenize(final int textbuffer, final int parsebuffer,
      final int dictionaryAddress, final bool flag) {
    final int version = _machine.getVersion();
    final int bufferlen = _machine.readUnsigned8(textbuffer).toInt();
    final int textbufferstart = _determineTextBufferStart(version);
    final int charsTyped =
        version >= 5 ? _machine.readUnsigned8(textbuffer + 1).toInt() : 0;

    // from version 5, text starts at position 2
    final String input =
        _bufferToZscii(textbuffer + textbufferstart, bufferlen, charsTyped);
    final List<String> tokens = _tokenize(input);
    final parsedTokens = HashMap<String, int>();
    final int maxTokens = _machine.readUnsigned8(parsebuffer).toInt();
    final int numTokens = min(maxTokens, tokens.length);

    // Write the number of parsed tokens into byte 1 of the parse buffer
    _machine.writeUnsigned8(parsebuffer + 1, Char(numTokens));

    int parseaddr = parsebuffer + 2;

    for (int i = 0; i < numTokens; i++) {
      String token = tokens[i];
      final int entryAddress = _machine.lookupToken(dictionaryAddress, token);
      int startIndex = 0;
      if (parsedTokens.containsKey(token)) {
        final int timesContained = parsedTokens[token];
        parsedTokens[token] = timesContained + 1;
        for (int j = 0; j < timesContained; j++) {
          final int found = input.indexOf(token, startIndex);
          startIndex = found + token.length;
        }
      } else {
        parsedTokens[token] = 1;
      }
      int tokenIndex = input.indexOf(token, startIndex);
      tokenIndex++; // adjust by the buffer length byte

      if (version >= 5) {
        // if version >= 5, there is also numbers typed byte
        tokenIndex++;
      }

      // if the tokenize flag is not set, write out the entry to the
      // parse buffer, if it is set then, only write the token position
      // if the token was recognized
      if (!flag || flag && entryAddress > 0) {
        // This is one slot
        _machine.writeUnsigned16(parseaddr, toUnsigned16(entryAddress));
        _machine.writeUnsigned8(parseaddr + 2, Char(token.length));
        _machine.writeUnsigned8(parseaddr + 3, Char(tokenIndex));
      }
      parseaddr += 4;
    }
  }

  /// Turns the buffer into a ZSCII string. This function reads at most
  /// |bufferlen| bytes and treats each byte as an ASCII character.
  /// The characters will be concatenated to the result string.
  /// @param address the buffer address
  /// @param bufferlen the buffer length
  /// @param charsTyped from version 5, this is the number of characters
  /// to include in the input
  String _bufferToZscii(
      final int address, final int bufferlen, final int charsTyped) {
    // If charsTyped is set, use that value as the limit
    final int numChars = (charsTyped > 0) ? charsTyped : bufferlen;

    // read input from text buffer
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < numChars; i++) {
      final Char charByte = _machine.readUnsigned8(address + i);
      if (charByte.toInt() == 0) {
        break;
      }
      buffer.write(charByte.toString());
    }
    return buffer.toString();
  }

  /// Turns the specified input string into tokens. It will take whitespace
  /// implicitly and dictionary separators explicitly to tokenize the
  /// stream, dictionary specified separators are included in the result list.
  /// @param input the input string
  /// @return the tokens
  List<String> _tokenize(final String input) {
    final List<String> result = List<String>();
    // The tokenizer will also return the delimiters
    final String delim = _machine.getDictionaryDelimiters();
    // include dictionary delimiters as tokens
    final StringTokenizer tok = StringTokenizer(input, delim, true);
    while (tok.hasMoreTokens()) {
      final String token = tok.nextToken();
      if (!Char.at(token, 0).isWhitespace()) {
        result.add(token);
      }
    }
    return result;
  }

  /// Depending on the version, this returns the offset where text starts in
  /// the text buffer. In versions up to 4 this is 1, since we have the
  /// buffer size in the first byte, from versions 5, we also have the
  /// number of typed characters in the second byte.
  /// @param version the story file version
  /// @return 1 if version &lt; 4, 2, otherwise
  int _determineTextBufferStart(final int version) {
    return (version < 5) ? 1 : 2;
  }
}

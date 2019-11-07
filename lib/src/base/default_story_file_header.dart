import 'helpers.dart';
import 'memory.dart';
import 'memory_util.dart';
import 'story_file_header.dart';

/// This is the default implementation of the StoryFileHeader interface.
class DefaultStoryFileHeader extends StoryFileHeader {
  final Memory memory;

  DefaultStoryFileHeader(this.memory);

  @override
  int getVersion() {
    return memory.readUnsigned8(0x00).toInt();
  }

  @override
  String getSerialNumber() {
    return extractAscii(0x12, 6);
  }

  @override
  int getFileLength() {
    // depending on the story file version we have to multiply the
    // file length in the header by a constant
    int fileLength = memory.readUnsigned16(0x1a).toInt();
    if (getVersion() <= 3) {
      fileLength *= 2;
    } else if (getVersion() <= 5) {
      fileLength *= 4;
    } else {
      fileLength *= 8;
    }
    return fileLength;
  }

  @override
  void setInterpreterVersion(final int version) {
    if (getVersion() == 4 || getVersion() == 5) {
      memory.writeUnsigned8(0x1f, Char.at(version.toString(), 0));
    } else {
      memory.writeUnsigned8(0x1f, Char(version));
    }
  }

  @override
  void setFontWidth(final int units) {
    if (getVersion() == 6) {
      memory.writeUnsigned8(0x27, Char(units));
    } else {
      memory.writeUnsigned8(0x26, Char(units));
    }
  }

  @override
  void setFontHeight(final int units) {
    if (getVersion() == 6) {
      memory.writeUnsigned8(0x26, Char(units));
    } else {
      memory.writeUnsigned8(0x27, Char(units));
    }
  }

  @override
  void setMouseCoordinates(final int x, final int y) {
    // check the extension table
    final int extTable = memory.readUnsigned16(0x36).toInt();
    if (extTable > 0) {
      final int numwords = memory.readUnsigned16(extTable).toInt();
      if (numwords >= 1) {
        memory.writeUnsigned16(extTable + 2, toUnsigned16(x));
      }
      if (numwords >= 2) {
        memory.writeUnsigned16(extTable + 4, toUnsigned16(y));
      }
    }
  }

  @override
  Char getCustomAccentTable() {
    // check the extension table
    var result = Char(0);
    final int extTable = memory.readUnsigned16(0x36).toInt();
    if (extTable > 0) {
      final int numwords = memory.readUnsigned16(extTable).toInt();
      if (numwords >= 3) {
        result = memory.readUnsigned16(extTable + 6);
      }
    }
    return result;
  }

  @override
  void setEnabled(final Attribute attribute, final bool flag) {
    switch (attribute) {
      case Attribute.DEFAULT_FONT_IS_VARIABLE:
        setDefaultFontIsVariablePitch(flag);
        break;
      case Attribute.TRANSCRIPTING:
        setTranscripting(flag);
        break;
      case Attribute.FORCE_FIXED_FONT:
        setForceFixedFont(flag);
        break;
      case Attribute.SUPPORTS_TIMED_INPUT:
        setTimedInputAvailable(flag);
        break;
      case Attribute.SUPPORTS_FIXED_FONT:
        setFixedFontAvailable(flag);
        break;
      case Attribute.SUPPORTS_BOLD:
        setBoldFaceAvailable(flag);
        break;
      case Attribute.SUPPORTS_ITALIC:
        setItalicAvailable(flag);
        break;
      case Attribute.SUPPORTS_SCREEN_SPLITTING:
        setScreenSplittingAvailable(flag);
        break;
      case Attribute.SUPPORTS_STATUSLINE:
        setStatusLineAvailable(flag);
        break;
      case Attribute.SUPPORTS_COLOURS:
        setSupportsColours(flag);
        break;
      default:
        break;
    }
  }

  @override
  bool isEnabled(final Attribute attribute) {
    switch (attribute) {
      case Attribute.TRANSCRIPTING:
        return isTranscriptingOn();
      case Attribute.FORCE_FIXED_FONT:
        return forceFixedFont();
      case Attribute.SCORE_GAME:
        return isScoreGame();
      case Attribute.DEFAULT_FONT_IS_VARIABLE:
        return defaultFontIsVariablePitch();
      case Attribute.USE_MOUSE:
        return useMouse();
      default:
        return false;
    }
  }

  @override
  String toString() {
    var builder = StringBuffer();
    for (int i = 0; i < 55; i++) {
      builder.write(
          'Addr: ${toHexStr(i)} Byte: ${toHexStr(memory.readUnsigned8(i).toInt())}\n');
    }
    return builder.toString();
  }

  // *******************************
  // ****** Private section
  // *******************************

  /// Extract an ASCII string of the specified [length] starting at the specified [address].
  String extractAscii(final int address, final int length) {
    final builder = StringBuffer();
    for (int i = address; i < address + length; i++) {
      builder.write(memory.readUnsigned8(i));
    }
    return builder.toString();
  }

  /// Sets the state of the transcript stream.
  void setTranscripting(final bool flag) {
    var flags = memory.readUnsigned16(0x10).toInt();
    flags = (flag ? (flags | 1) : (flags & 0xfe));
    memory.writeUnsigned16(0x10, Char(flags));
  }

  /// Returns the state of the transcript stream.
  bool isTranscriptingOn() {
    return (memory.readUnsigned16(0x10) & 1) > 0;
  }

  /// Returns state of the force fixed font flag.
  bool forceFixedFont() {
    return (memory.readUnsigned16(0x10) & 2) > 0;
  }

  /// Sets the force fixed font flag.
  void setForceFixedFont(final bool flag) {
    var flags = memory.readUnsigned16(0x10).toInt();
    flags = (flag ? (flags | 2) : (flags & 0xfd));
    memory.writeUnsigned16(0x10, Char(flags));
  }

  /// Sets the timed input availability flag.
  void setTimedInputAvailable(final bool flag) {
    int flags = memory.readUnsigned8(0x01).toInt();
    flags = flag ? (flags | 128) : (flags & 0x7f);
    memory.writeUnsigned8(0x01, Char(flags));
  }

  /// Determine whether this game is a "score" game or a "time" game.
  bool isScoreGame() {
    return (memory.readUnsigned8(0x01) & 2) == 0;
  }

  /// Sets the fixed font availability flag.
  void setFixedFontAvailable(final bool flag) {
    int flags = memory.readUnsigned8(0x01).toInt();
    flags = flag ? (flags | 16) : (flags & 0xef);
    memory.writeUnsigned8(0x01, Char(flags));
  }

  /// Sets the bold supported flag.
  void setBoldFaceAvailable(final bool flag) {
    int flags = memory.readUnsigned8(0x01).toInt();
    flags = flag ? (flags | 4) : (flags & 0xfb);
    memory.writeUnsigned8(0x01, Char(flags));
  }

  /// Sets the italic supported flag.
  void setItalicAvailable(final bool flag) {
    int flags = memory.readUnsigned8(0x01).toInt();
    flags = flag ? (flags | 8) : (flags & 0xf7);
    memory.writeUnsigned8(0x01, Char(flags));
  }

  /// Sets the screen splitting availability flag.
  void setScreenSplittingAvailable(final bool flag) {
    int flags = memory.readUnsigned8(0x01).toInt();
    flags = flag ? (flags | 32) : (flags & 0xdf);
    memory.writeUnsigned8(0x01, Char(flags));
  }

  /// Sets the flag whether a status line is available or not.
  void setStatusLineAvailable(final bool flag) {
    int flags = memory.readUnsigned8(0x01).toInt();
    flags = flag ? (flags | 16) : (flags & 0xef);
    memory.writeUnsigned8(0x01, Char(flags));
  }

  /// Sets the state whether the default font is variable or not.
  void setDefaultFontIsVariablePitch(final bool flag) {
    int flags = memory.readUnsigned8(0x01).toInt();
    flags = flag ? (flags | 64) : (flags & 0xbf);
    memory.writeUnsigned8(0x01, Char(flags));
  }

  /// Returns whether default font is variable pitch.
  bool defaultFontIsVariablePitch() {
    return (memory.readUnsigned8(0x01) & 64) > 0;
  }

  /// Returns the status of the supports color flag.
  void setSupportsColours(final bool flag) {
    int flags = memory.readUnsigned8(0x01).toInt();
    flags = flag ? (flags | 1) : (flags & 0xfe);
    memory.writeUnsigned8(0x01, Char(flags));
  }

  /// Returns the status of the use mouse flag.
  bool useMouse() {
    return (memory.readUnsigned8(0x10) & 32) > 0;
  }
}

import 'dart:math';
import 'package:zvm/z_screen.dart';
import 'package:zvm/style_region.dart';
import 'package:zvm/utils.dart';

class ZWindow {
  static const int ROMAN = 0;
  static const int BOLD = 2;
  static const int ITALIC = 4;
  static const int FIXED = 8;

  int top;
  int left;
  int width;
  int height;
  int cursorx;
  int cursory;

  ZScreen screen;

  bool upper;
  List<String> frameBuffer;
  StyleRegion regions;
  int cursor;
  int maxCursor;
  int endWindow;
  int startWindow;

  ZWindow(ZScreen screen, bool upper) {
    this.upper = upper;
    this.top = 0;
    this.left = 0;
    this.width = 10;
    this.height = 10;
    this.screen = screen;
    if (upper) {
      frameBuffer = new List<String>.filled(
          screen.getchars() * screen.getlines() * 2, ' ');
    } else {
      frameBuffer = new List<String>.filled(screen.getchars() * 255, ' ');
    }
  }

  void reset_line_count() {}

  void erase_line(int arg) {}

  void setwrapmode(bool wrapmode) {}

  void moveto(int newleft, int newtop) {
    left = newleft;
    top = newtop;
    startWindow = top * width + left;
    endWindow = startWindow + width * height;
  }

  void resize(int newwidth, int newheight) {
    width = newwidth;
    height = newheight;
    if (upper) {
      if ((cursorx >= newwidth) || (cursory >= newheight)) {
        cursorx = 0;
        cursory = 0;
        cursor = 0;
      }
    }
    startWindow = top * width + left;
    endWindow = startWindow + width * height;
  }

  int getlines() {
    return height;
  }

  int getx() {
    return cursorx;
  }

  int gety() {
    return cursory;
  }

  void movecursor(int x, int y) {
    if (upper) {
      cursorx = x;
      cursory = y;
      cursor = (y * width + x);
      maxCursor = max(cursor, maxCursor);
    }
  }

  /// Write a [ascii] character to the framebuffer at the current cursor position.
  void printzascii(int ascii) {
    printChar(ZScreen.zascii_to_unicode(ascii));
  }

  void flush() {}

  void newline() {
    printChar('\n');
  }

  void printChar(String ch) {
    frameBuffer[cursor] = ch;
    if (cursor < frameBuffer.length - 1) {
      cursor++;
      maxCursor = max(cursor, maxCursor);
      cursorx++;
      if ((cursorx > screen.getchars() - 2) || (ch == '\n')) {
        cursory++;
        cursorx = 0;
      }
    }
  }

  void clear() {
    if (upper) {
      cursor = top * width + left;
      frameBuffer.fillRange(startWindow, endWindow, ' ');
    } else {
      cursor = 0;
    }
    cursorx = 0;
    cursory = 0;
    maxCursor = cursor;
  }

  void set_color(int foreground, int background) {}

  void set_text_style(int style) {
    StyleRegion region = new StyleRegion();
    region.style = style;
    region.start = cursor;
    region.end = cursor;
    if (regions == null) {
      regions = region;
    } else {
      StyleRegion tmp = regions;
      while (tmp.next != null) {
        tmp = tmp.next;
      }
      tmp.end = cursor;
      tmp.next = region;
    }
  }

  int getHeight() {
    return height;
  }

  /// Tell the buffer that it got fetched and can be overwritten on the next turn.
  void retrieved() {
    if (upper) {
      // NOTE: The lower window doesn't support formatted text. Some games
      // (e.g. curses and anchorhead) work around that limitation by
      // temporarily expanding the upperwindow, printing formatted text there,
      // then collapsing it again. Whatever is in the upperwindow is suppose
      // to stay, the "overflow" technically becomes part of the lower window
      // and hence needs to be cleared.
      if (maxCursor > endWindow) {
        frameBuffer.fillRange(endWindow, maxCursor, ' ');
      }
      maxCursor = endWindow;
    } else {
      cursorx = 0;
      cursory = 0;
      cursor = 0;
    }
    regions = null;
  }

  /// Transform a portion of the framebuffer into a string, add newline characters as required by the window width.
  String stringyfy(int start, int end) {
    if (width < 1 || start >= end) {
      return "";
    }
    int len = width;
    int total = end - start;
    var tmp = new List<String>.filled(total + total ~/ len, '\u0000');
    int i = start;
    int o = 0;
    while (i < total - len) {
      arrayCopy(frameBuffer, i, tmp, o, len);
      i += len;
      o += (len + 1);
      tmp[o - 1] = '\n';
    }
    // copy rest
    if (i < total) {
      arrayCopy(frameBuffer, i, tmp, o, total - i);
    }

    return tmp.join();
  }

  /// Dirty hack! Calculate the length of the text in the framebuffer excluding the last line
  /// containing the prompt.
  int noPrompt() {
    int ret = cursor - 1; // Put ret on the last character.
    if (ret < 0) {
      return cursor;
    }
    while (ret > 0 && frameBuffer[ret] == ' ') {
      ret--;
    }
    if (ret > 1 && frameBuffer[ret] == '>') {
      ret--;
    } else {
      // No idea what this is ... better safe than sorry.
      return cursor;
    }
    while (ret > 0 && frameBuffer[ret] == '\n') {
      // Remove all trailing newlines.
      ret--;
    }
    ret++; // Because we x-ed the last real character.
    return ret;
  }
}

import 'package:zvm/z_color.dart';

class ZScreen {
  static final List<String> accent_table = [
    '\u00e4', // a-umlaut
    '\u00f6', // o-umlaut
    '\u00fc', // u-umlaut
    '\u00c4', // A-umlaut
    '\u00d6', // O-umlaut
    '\u00dc', // U-umlaut
    '\u00df', // sz-ligature
    '\u00bb', // right-pointing quote
    '\u00ab', // left-pointing quote
    '\u00eb', // e-umlaut
    '\u00ef', // i-umlaut
    '\u00ff', // y-umlaut
    '\u00cb', // E-umlaut
    '\u00cf', // I-umlaut
    '\u00e1', // a-acute
    '\u00e9', // e-acute
    '\u00ed', // i-acute
    '\u00f3', // o-acute
    '\u00fa', // u-acute
    '\u00fd', // y-acute
    '\u00c1', // A-acute
    '\u00c9', // E-acute
    '\u00cd', // I-acute
    '\u00d3', // O-acute
    '\u00da', // U-acute
    '\u00dd', // Y-acute
    '\u00e0', // a-grave
    '\u00e8', // e-grave
    '\u00ec', // i-grave
    '\u00f2', // o-grave
    '\u00f9', // u-grave
    '\u00c0', // A-grave
    '\u00c8', // E-grave
    '\u00cc', // I-grave
    '\u00d2', // O-grave
    '\u00d9', // U-grave
    '\u00e2', // a-circumflex
    '\u00ea', // e-circumflex
    '\u00ee', // i-circumflex
    '\u00f4', // o-circumflex
    '\u00fb', // u-circumflex
    '\u00c2', // A-circumflex
    '\u00ca', // E-circumflex
    '\u00ce', // I-circumflex
    '\u00d4', // O-circumflex
    '\u00da', // U-circumflex
    '\u00e5', // a-ring
    '\u00c5', // A-ring
    '\u00f8', // o-slash
    '\u00d8', // O-slash
    '\u00e3', // a-tilde
    '\u00f1', // n-tilde
    '\u00f5', // o-tilde
    '\u00c3', // A-tilde
    '\u00d1', // N-tilde
    '\u00d5', // O-tilde
    '\u00e6', // ae-ligature
    '\u00c6', // AE-ligature
    '\u00e7', // c-cedilla
    '\u00c7', // C-cedilla
    '\u00fe', // Icelandic thorn
    '\u00f0', // Icelandic eth
    '\u00de', // Icelandic Thorn
    '\u00d0', // Icelandic Eth
    '\u00a3', // UK pound symbol
    '\u0153', // oe ligature
    '\u0152', // OE ligature
    '\u00a1', // inverse-!
    '\u00bf', // inverse-?
  ];

  static String zascii_to_unicode(int zascii) {
    // TODO: Simplify the method

    if (zascii == 0) {
      return '';
    } else if (zascii == 9) {
      return '\t';
    } else if (zascii == 11) {
      return ' ';
    } else if (zascii == 13) {
      return '\n';
    } else if (zascii == 127) {
      return '\b';
    } else if (zascii == 27) {
      return '\u001b';
    }

    if ((zascii >= 32) && (zascii <= 126)) {
      // normal ascii
      return String.fromCharCode(zascii);
    } else if ((zascii >= 155) && (zascii <= 251)) {
      if ((zascii - 155) < accent_table.length) {
        return accent_table[zascii - 155];
      } else {
        return '\ufffd';
      }
    } else if (zascii >= 256) {
      return String.fromCharCode(zascii);
    } else {
      //System.err.println("Illegal character code: " + zascii);
      return '\ufffd';
    }
  }

  static int unicode_to_zascii(String unicode) {
    if (unicode.isEmpty || unicode.length != 1) {
      throw Exception('String must be length of 1');
    }

    if (unicode == '\n') {
      return 13;
    }
    if (unicode == '\b') {
      // Backspace
      return 127;
    }
    if (unicode == '\t') {
      return 9;
    }

    // TODO: Simplify the method by avoiding the loop, and hex values
    int cc = unicode.codeUnitAt(0);
    if ((cc < 0x20) && (unicode != '\r') && (unicode != '\u001b')) {
      throw new Exception("Illegal character input: " + cc.toString());
    } else if (cc < 0x80) {
      // normal ascii, including DELETE
      return cc;
    } else {
      for (int i = 0; i < accent_table.length; i++) {
        if (accent_table[i] == unicode) {
          return (155 + i);
        }
      }
      throw new Exception("Illegal character input: " + cc.toString());
    }
  }

  int getlines() {
    return 80;
  }

  int getchars() {
    return 80;
  }

  void clear() {}

  int getZForeground() {
    return ZColor.Z_BLACK;
  }

  int getZBackground() {
    return ZColor.Z_WHITE;
  }
}

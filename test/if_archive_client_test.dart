import 'dart:io';

import 'package:test/test.dart';

class IfdbClient {}

class IfArchiveItem {
  String link;
  String ifdbEntry;
  String description;
}

class IfArchiveParser {
  static List<IfArchiveItem> getItems(String doc) {
    final items = List<IfArchiveItem>();

    final itemListStr = _getItemListStr(doc);
    final itemMatches = _getItemMatches(itemListStr);
    for (final itemMatch in itemMatches) {
      final itemStr = itemMatch.group(0);
      final item = _getItem(itemStr);
      if (item != null) {
        items.add(item);
      }
    }

    return items;
  }

  /// <dl id="itemlist">...</dl>
  static String _getItemListStr(String doc) {
    final itemListExp = _exp(r"<dl.+?itemlist.+?>.+?<\/dl.*?>");
    final itemListMatch = itemListExp.firstMatch(doc);
    return itemListMatch?.group(0);
  }

  /// <dt>...</dt>... till the next <dt> or </dl>
  static Iterable<RegExpMatch> _getItemMatches(String itemListStr) {
    if (itemListStr == null) {
      return [];
    }

    final itemExp = _exp(r"<dt.+?(?=<dt|<\/dl)");
    Iterable<RegExpMatch> matches = itemExp.allMatches(itemListStr);
    return matches;
  }

  static IfArchiveItem _getItem(String itemStr) {
    if (itemStr == null) {
      return null;
    }

    final linkExp = _exp(r'<dt.+?href.+?"(.+?)"');
    // TODO: multiple IFDB entries
    final ifdbEntryExp = _exp(r'<dd.+?FileData.+?href.+?"(.+?)"');
    // TODO: multiple paragraph/tags description
    final descriptionExp = _exp(r'<dd.+?<p>(.+?)<\/p>');

    final item = IfArchiveItem();
    item.link = linkExp.firstMatch(itemStr)?.group(1)?.trim();
    item.ifdbEntry = ifdbEntryExp.firstMatch(itemStr)?.group(1)?.trim();
    item.description = descriptionExp
        .firstMatch(itemStr)
        ?.group(1)
        ?.trim()
        ?.replaceAll('\n', ' ');

    return item;
  }

  static RegExp _exp(String source) {
    return RegExp(
      source,
      multiLine: false,
      caseSensitive: false,
      dotAll: true,
    );
  }
}

void main() {
  test('if-archive-zcode', () {
    final file = File('./testfiles/if-archiveXgamesXzcode.html');
    final doc = file.readAsStringSync();
    final items = IfArchiveParser.getItems(doc);
    expect(items, isNotNull);
    expect(items.length, equals(728));
    expect(items[0].link,
        equals("../if-archive/games/zcode/404-Life_not_found.zblorb"));
    expect(items[0].ifdbEntry,
        equals('https://ifdb.tads.org/viewgame?id=y5j1fy2h9azhurt1'));
    expect(
        items[0].description,
        equals(
            '404- Life not found, by Evan Derby. Release 1 / Serial number 110524'));

    int zipCounter = 0;
    int ifdbCounter = 0;
    items.forEach((item) {
      if (item.link.endsWith('.zip')) {
        zipCounter++;
      }
      if (item.ifdbEntry != null) {
        ifdbCounter++;
      }
    });
    expect(zipCounter, equals(85));
    expect(ifdbCounter, equals(620));
  });
}

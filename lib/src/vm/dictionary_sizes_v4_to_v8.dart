import '../../zvm.dart';

/// The dictionary size definitions for the story file versions 4-8.
class DictionarySizesV4ToV8 implements DictionarySizes {
  @override
  int getNumEntryBytes() {
    return 6;
  }

  @override
  int getMaxEntryChars() {
    return 9;
  }
}

import '../../zvm.dart';

/// The dictionary size definitions for the story file versions 1-3.
class DictionarySizesV1ToV3 implements DictionarySizes {
  @override
  int getNumEntryBytes() {
    return 4;
  }

  @override
  int getMaxEntryChars() {
    return 6;
  }
}

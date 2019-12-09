import '../../zvm.dart';

/// This class holds Inform meta information.
class InformMetadata {
  StoryMetadata _storyinfo;

  InformMetadata(StoryMetadata storyinfo) {
    this._storyinfo = storyinfo;
  }

  /// Returns story meta data object.
  StoryMetadata getStoryInfo() {
    return _storyinfo;
  }
}

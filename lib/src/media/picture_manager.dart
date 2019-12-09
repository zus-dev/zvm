import '../../zvm.dart';

/// Interface for managing pictures.
abstract class PictureManager {
  /// Returns the size of the specified picture or null if the picture does not
  /// exist.
  Resolution getPictureSize(int picturenum);

  /// Returns the data of the specified picture. If it is not available, this
  /// method returns null.
  ZmppImage getPicture(int picturenum);

  /// Returns the number of pictures.
  int getNumPictures();

  /// Preloads the specified picture numbers.
  void preload(List<int> picnumbers);

  /// Returns the release number of the picture file.
  int getRelease();

  /// Resets the picture manager.
  void reset();
}

import '../../zvm.dart';

/// This interface defines access to the Z-machine's media resources.
abstract class Resources {
  /// The release number of the resource file.
  int getRelease();

  /// Returns the images of this file.
  MediaCollection<ZmppImage> getImages();

  /// Returns the sounds of this file.
  MediaCollection<SoundEffect> getSounds();

  /// Returns the number of the cover art picture.
  /// @return the number of the cover art picture
  int getCoverArtNum();

  /// Returns the inform meta data if available.
  InformMetadata getMetadata();

  /// Returns true if the resource file has information.
  bool hasInfo();
}

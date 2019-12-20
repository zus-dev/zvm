import '../../zvm.dart';

/// This class encapsulates a Blorb file and offers access to the sound
/// and graphics media collections.
class BlorbResources implements Resources {
  /// The file's images.
  MediaCollection<BlorbImage> _images;

  /// The file's sounds.
  MediaCollection<SoundEffect> _sounds;

  /// The cover art.
  BlorbCoverArt _coverart;

  /// The meta data.
  BlorbMetadataHandler _metadata;

  /// The release number.
  int _release;

  BlorbResources(NativeImageFactory imageFactory,
      SoundEffectFactory soundEffectFactory, FormChunk formchunk) {
    _images = BlorbImages(imageFactory, formchunk);
    _sounds = BlorbSounds(soundEffectFactory, formchunk);
    _coverart = BlorbCoverArt(formchunk);
    _metadata = BlorbMetadataHandler(formchunk);
  }

  @override
  MediaCollection<ZmppImage> getImages() {
    return _images;
  }

  @override
  MediaCollection<SoundEffect> getSounds() {
    return _sounds;
  }

  @override
  int getCoverArtNum() {
    return _coverart.getCoverArtNum();
  }

  @override
  InformMetadata getMetadata() {
    return _metadata.getMetadata();
  }

  @override
  int getRelease() {
    return _release;
  }

  @override
  bool hasInfo() {
    return _metadata.getMetadata() != null;
  }
}

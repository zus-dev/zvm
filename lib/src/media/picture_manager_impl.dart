import '../../zvm.dart';

/// PictureManager implementation.
class PictureManagerImpl implements PictureManager {
  int _release = 0;
  MediaCollection<ZmppImage> _pictures;
  DrawingArea _drawingArea;

  PictureManagerImpl(int release, DrawingArea drawingArea,
      MediaCollection<ZmppImage> pictures) {
    _release = release;
    _pictures = pictures;
    _drawingArea = drawingArea;
  }

  @override
  Resolution getPictureSize(final int picturenum) {
    final ZmppImage img = _pictures.getResource(picturenum);
    if (img != null) {
      Resolution reso = _drawingArea.getResolution();
      return img.getSize(reso.getWidth(), reso.getHeight());
    }
    return null;
  }

  @override
  ZmppImage getPicture(final int picturenum) {
    return _pictures.getResource(picturenum);
  }

  @override
  int getNumPictures() {
    return _pictures.getNumResources();
  }

  @override
  void preload(final List<int> picnumbers) {
    // no pre-loading at the moment
  }

  @override
  int getRelease() {
    return _release;
  }

  @override
  void reset() {
    // no resetting supported
  }
}

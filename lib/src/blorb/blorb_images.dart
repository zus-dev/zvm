import '../../zvm.dart';

/// This class implements the Image collection.
class BlorbImages extends BlorbMediaCollection<BlorbImage> {
  /// This map implements the image database.
  Map<int, BlorbImage> _images;

  BlorbImages(NativeImageFactory imageFactory, FormChunk formchunk)
      : super(imageFactory, null, formchunk) {
    _handleResoChunk();
  }

  @override
  void clear() {
    super.clear();
    _images.clear();
  }

  @override
  void initDatabase() {
    _images = Map<int, BlorbImage>();
  }

  @override
  bool isHandledResource(final ByteArray usageId) {
    return usageId[0] == codeOf('P') &&
        usageId[1] == codeOf('i') &&
        usageId[2] == codeOf('c') &&
        usageId[3] == codeOf('t');
  }

  @override
  BlorbImage getResource(final int resourcenumber) {
    return _images[resourcenumber];
  }

  @override
  bool putToDatabase(final Chunk chunk, final int resnum) {
    if (!_handlePlaceholder(chunk, resnum)) {
      return _handlePicture(chunk, resnum);
    }
    return true;
  }

  /// Handles a placeholder image.
  bool _handlePlaceholder(final Chunk chunk, final int resnum) {
    if ("Rect" == chunk.getId()) {
      // Place holder
      Memory memory = chunk.getMemory();
      int width = readUnsigned32(memory, Chunk.CHUNK_HEADER_LENGTH);
      int height = readUnsigned32(memory, Chunk.CHUNK_HEADER_LENGTH + 4);
      _images[resnum] = BlorbImage.resolution(width, height);

      return true;
    }
    return false;
  }

  /// Processes the picture contained in the specified chunk.
  bool _handlePicture(final Chunk chunk, final int resnum) {
    final inputStream = MemoryInputStream(chunk.getMemory(),
        Chunk.CHUNK_HEADER_LENGTH, chunk.getSize() + Chunk.CHUNK_HEADER_LENGTH);
    try {
      _images[resnum] = BlorbImage(imageFactory.createImage(inputStream));
      return true;
    } on Exception catch (ex) {
      // TODO: ex.printStackTrace()
      print("ERROR: ${ex}");
    }
    return false;
  }

  /// Process the Reso chunk.
  void _handleResoChunk() {
    Chunk resochunk = getFormChunk().getSubChunk("Reso");
    if (resochunk != null) {
      _adjustResolution(resochunk);
    }
  }

  /// Adjusts the resolution of the image.
  void _adjustResolution(Chunk resochunk) {
    Memory memory = resochunk.getMemory();
    int offset = Chunk.CHUNK_ID_LENGTH;
    int size = readUnsigned32(memory, offset);
    offset += Chunk.CHUNK_SIZEWORD_LENGTH;
    int px = readUnsigned32(memory, offset);
    offset += 4;
    int py = readUnsigned32(memory, offset);
    offset += 4;
    int minx = readUnsigned32(memory, offset);
    offset += 4;
    int miny = readUnsigned32(memory, offset);
    offset += 4;
    int maxx = readUnsigned32(memory, offset);
    offset += 4;
    int maxy = readUnsigned32(memory, offset);
    offset += 4;

    ResolutionInfo resinfo = ResolutionInfo(
        Resolution(px, py), Resolution(minx, miny), Resolution(maxx, maxy));

    for (int i = 0; i < getNumResources(); i++) {
      if (offset >= size) break;
      int imgnum = readUnsigned32(memory, offset);
      offset += 4;
      int ratnum = readUnsigned32(memory, offset);
      offset += 4;
      int ratden = readUnsigned32(memory, offset);
      offset += 4;
      int minnum = readUnsigned32(memory, offset);
      offset += 4;
      int minden = readUnsigned32(memory, offset);
      offset += 4;
      int maxnum = readUnsigned32(memory, offset);
      offset += 4;
      int maxden = readUnsigned32(memory, offset);
      offset += 4;
      ScaleInfo scaleinfo = ScaleInfo(resinfo, Ratio(ratnum, ratden),
          Ratio(minnum, minden), Ratio(maxnum, maxden));
      BlorbImage img = _images[imgnum];

      if (img != null) {
        img.setScaleInfo(scaleinfo);
      }
    }
  }
}

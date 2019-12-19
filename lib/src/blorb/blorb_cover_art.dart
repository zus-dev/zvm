import '../../zvm.dart';

/// This class extracts the Frontispiece chunk.
class BlorbCoverArt {
  int _coverartnum;

  BlorbCoverArt(FormChunk formchunk) {
    _readFrontispiece(formchunk);
  }

  /// Reads the frontiscpiece image from the specified FORM chunk.
  void _readFrontispiece(final FormChunk formchunk) {
    final Chunk fspcchunk = formchunk.getSubChunk("Fspc");
    if (fspcchunk != null) {
      _coverartnum =
          readUnsigned32(fspcchunk.getMemory(), Chunk.CHUNK_HEADER_LENGTH);
    }
  }

  /// Returns the number of the cover art.
  int getCoverArtNum() {
    return _coverartnum;
  }
}

import '../../zvm.dart';

/// This class extracts story data from a Blorb file.
class BlorbFile {
  FormChunk _formChunk;

  BlorbFile(final FormChunk formchunk) {
    this._formChunk = formchunk;
  }

  /// Returns the story data contained in the Blorb.
  ByteArray getStoryData() {
    final Chunk chunk = _formChunk.getSubChunk("ZCOD");
    final int size = chunk.getSize();
    final ByteArray data = ByteArray.length(size);
    chunk
        .getMemory()
        .copyBytesToArray(data, 0, Chunk.CHUNK_HEADER_LENGTH, size);
    return data;
  }
}

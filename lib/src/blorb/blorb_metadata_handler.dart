import '../../zvm.dart';

/// This class parses the metadata chunk in the Blorb file and converts
/// it into a Treaty of Babel metadata object.
class BlorbMetadataHandler extends DefaultHandler {
  static final Logger _LOG = Logger.getLogger("org.zmpp");
  StoryMetadata _story;
  StringBuffer _buffer;
  bool _processAux;
  
  BlorbMetadataHandler(FormChunk formchunk) {
    _extractMetadata(formchunk);
  }

  /// Returns the meta data object.
  InformMetadata getMetadata() {
    return (_story == null) ? null : InformMetadata(_story);
  }

  /// Extracts inform meta data from the specified FORM chunk.
  void _extractMetadata(final FormChunk formchunk) {
    final Chunk chunk = formchunk.getSubChunk("IFmd");
    if (chunk != null) {
      final Memory chunkmem = chunk.getMemory();
      final MemoryInputStream meminput = MemoryInputStream(chunkmem, Chunk.CHUNK_HEADER_LENGTH,
          chunk.getSize() + Chunk.CHUNK_HEADER_LENGTH);

      try {
        final SAXParser parser = SAXParserFactory.newInstance().newSAXParser();
        parser.parse(meminput, this);
      } catch (ex) {
        // TODO: printStackTrace
        print("Exception: ${ex}");
      }
    }
  }

  // **********************************************************************
  // **** Parsing meta data
  // *********************************

  @override
  void startElement(final String uri, final String localName,
      final String qname, final Attributes attributes) {
    if ("story" == qname) {
      _story = StoryMetadata();
    }
    if ("title" == qname) {
      _buffer = StringBuffer();
    }
    if ("headline" == qname) {
      _buffer = StringBuffer();
    }
    if ("author" == qname) {
      _buffer = StringBuffer();
    }
    if ("genre" == qname) {
      _buffer = StringBuffer();
    }
    if ("description" == qname) {
      _buffer = StringBuffer();
    }
    if (_isPublishYear(qname)) {
      _buffer = StringBuffer();
    }
    if ("auxiliary" == qname) {
      _processAux = true;
    }
    if ("coverpicture" == qname) {
      _buffer = StringBuffer();
    }
    if ("group" == qname) {
      _buffer = StringBuffer();
    }
  }

  @override
  void endElement(final String uri, final String localName,
      final String qname) {
    if ("title" == qname) {
      _story.setTitle(_buffer.toString());
    }
    if ("headline" == qname) {
      _story.setHeadline(_buffer.toString());
    }
    if ("author" == qname) {
      _story.setAuthor(_buffer.toString());
    }
    if ("genre" == qname) {
      _story.setGenre(_buffer.toString());
    }
    if ("description" == qname && !_processAux) {
      _story.setDescription(_buffer.toString());
    }
    if (_isPublishYear(qname)) {
      _story.setYear(_buffer.toString());
    }
    if ("group" == qname) {
      _story.setGroup(_buffer.toString());
    }
    if ("coverpicture" == qname) {
      final String val = _buffer.toString().trim();
      try {
        _story.setCoverPicture(int.parse(val));
      } on FormatException catch (ex) {
        _LOG.throwing("BlorbMetadataHandler", "endElement", ex);
      }
    }
    if ("auxiliary" == qname) {
      _processAux = false;
    }
    if ("br" == qname && _buffer != null) {
      _buffer.write("\n");
    }
  }

  @override
  void characters(final List<Char> ch, final int start, final int length) {
    if (_buffer != null) {
      final StringBuffer partbuilder = StringBuffer();
      for (int i = start; i < start + length; i++) {
        partbuilder.write(ch[i]);
      }
      _buffer.write(partbuilder.toString().trim());
    }
  }
  
  /// Unfortunately, year was renamed to firstpublished between the preview
  /// metadata version of Inform 7 and the Treaty of Babel version, so
  /// we handle both here.
  bool _isPublishYear(String str) {
    return "year" == str || "firstpublished" == str;
  }
}

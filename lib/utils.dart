void arrayCopy<T>(
    List<T> src, int srcOffset, List<T> dest, int destOffset, int length) {
  for (var i = 0; i < length; i++) {
    dest[destOffset + i] = src[srcOffset + i];
  }
}

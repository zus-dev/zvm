/// This interfaces defines the common functions of a media resource
/// collection. A MediaCollection manages one specific type of media,
/// e.g. sound effects or pictures.
/// Resources might be loaded lazily and cached in an internal cache.
abstract class MediaCollection<T> {
  /// Clears the collection.
  void clear();

  /// Accesses the resource by the [number] of the resource.
  T getResource(int number);

  /// Loads a resource into the internal cache if this collection supports
  /// caching.
  void loadResource(int number);

  /// Throws the resource out of the internal cache if this collection
  /// supports caching.
  void unloadResource(int number);

  /// Returns the number of resources.
  int getNumResources();
}

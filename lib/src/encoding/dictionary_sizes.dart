/// Z-code compilers seem to truncate dictionary string pretty
/// sloppy (i.e. multibyte sequences such as A2 escape) so that in
/// dictionary entries, the end bit does not always exist. Unfortunately,
/// the entry size given in the dictionary header is not reliable either.
/// Therefore we need to provide a size to the dictionary that is taken
/// from the Standard Specification Document. The specification specifies
/// both the number of bytes and the number of maximum characters
/// per entry which we access here. By defining a dictionary
/// size object, we avoid keep dictionary classes clean of version
/// dependency.
abstract class DictionarySizes {
  /// The number of bytes for an entry.
  int getNumEntryBytes();

  /// The maximum number of characters for an entry.
  int getMaxEntryChars();
}

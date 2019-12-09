/// This class holds information about a story.
class StoryMetadata {
  static final String _NEWLINE = '\n';

  String _title;
  String _headline;
  String _author;
  String _genre;
  String _description;
  String _year;
  int _coverpicture = 0;
  String _group;

  /// Returns the story title.
  String getTitle() {
    return _title;
  }

  /// Sets the story title.
  void setTitle(final String title) {
    this._title = title;
  }

  /// Returns the headline.
  String getHeadline() {
    return _headline;
  }

  /// Sets the headline.
  void setHeadline(final String headline) {
    this._headline = headline;
  }

  /// Returns the author.
  String getAuthor() {
    return _author;
  }

  /// Sets the author.
  void setAuthor(final String author) {
    this._author = author;
  }

  /// Returns the genre.
  String getGenre() {
    return _genre;
  }

  /// Sets the genre.
  void setGenre(final String genre) {
    this._genre = genre;
  }

  /// Returns the description.
  String getDescription() {
    return _description;
  }

  /// Sets the description.
  void setDescription(final String description) {
    this._description = description;
  }

  /// Returns the year.
  String getYear() {
    return _year;
  }

  /// Sets the year.
  void setYear(final String year) {
    this._year = year;
  }

  /// Returns the cover picture number.
  int getCoverPicture() {
    return _coverpicture;
  }

  /// Sets the cover picture number.
  void setCoverPicture(final int picnum) {
    this._coverpicture = picnum;
  }

  /// Returns the group.
  String getGroup() {
    return _group;
  }

  /// Sets the group.
  void setGroup(final String group) {
    this._group = group;
  }

  @override
  String toString() {
    final builder = StringBuffer();
    builder.write("Title: '" + _title + _NEWLINE);
    builder.write("Headline: '" + _headline + _NEWLINE);
    builder.write("Author: '" + _author + _NEWLINE);
    builder.write("Genre: '" + _genre + _NEWLINE);
    builder.write("Description: '" + _description + _NEWLINE);
    builder.write("Year: '" + _year + _NEWLINE);
    builder.write("Cover picture: " + _coverpicture.toString() + _NEWLINE);
    builder.write("Group: '" + _group + _NEWLINE);
    return builder.toString();
  }
}
